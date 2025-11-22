import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile/data/models/flashcard_session_model.dart';
import 'package:mobile/domain/repositories/student_flashcard_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:mobile/data/models/pronunciation_result_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

enum FlashcardStatus { loading, loaded, error }

class StudentFlashcardService extends ChangeNotifier {
  final StudentFlashcardRepository _repository;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecorderInitialized = false;
  String _audioPath = 'temp_audio.wav';
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  final Map<String, PronunciationResultModel> _sessionResults = {};

  PronunciationResultModel? get lastResult {
    if (currentCard == null) return null;
    return _sessionResults[currentCard!.vocabularyId];
  }

  bool _isAssessing = false;
  bool get isAssessing => _isAssessing;

  FlashcardStatus _status = FlashcardStatus.loading;
  FlashcardStatus get status => _status;

  String? _error;
  String? get error => _error;

  FlashcardSessionModel? _session;
  FlashcardSessionModel? get session => _session;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  FlashcardItemModel? get currentCard =>
      _session?.flashcards.isNotEmpty == true &&
              _currentIndex < _session!.flashcards.length
          ? _session!.flashcards[_currentIndex]
          : null;

  int get totalCards => _session?.flashcards.length ?? 0;

  StudentFlashcardService(this._repository) {
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ToastHelper.showError("Cần cấp quyền thu âm để sử dụng tính năng này.");
      return;
    }
    _isRecorderInitialized = true;
    final tempDir = await getTemporaryDirectory();
    _audioPath = '${tempDir.path}/$_audioPath';
  }

  Future<void> fetchFlashcards(String lessonId) async {
    _status = FlashcardStatus.loading;
    _error = null;
    _currentIndex = 0;
    _sessionResults.clear();

    notifyListeners();
    try {
      _session = await _repository.getFlashcards(lessonId);
      if (_session != null) {
        for (var card in _session!.flashcards) {
          if (card.lastPronunciationJson != null &&
              card.lastPronunciationJson!.isNotEmpty) {
            try {
              var decodedJson = jsonDecode(card.lastPronunciationJson!);
              _sessionResults[card.vocabularyId] =
                  PronunciationResultModel.fromJson(decodedJson);
            } catch (e) {
              debugPrint("Lỗi parse JSON kết quả cũ: $e");
            }
          }
        }
      }
      _status = FlashcardStatus.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = FlashcardStatus.error;
      ToastHelper.showError(_error!);
    } finally {
      notifyListeners();
    }
  }

  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // 4. Phát âm thanh
  Future<void> playAudio() async {
    if (currentCard?.sampleAudioUrl != null &&
        currentCard!.sampleAudioUrl!.isNotEmpty) {
      try {
        await _audioPlayer.setUrl(currentCard!.sampleAudioUrl!);
        await _audioPlayer.play();
      } catch (e) {
        print("Lỗi just_audio: $e");
        ToastHelper.showError("Không thể phát âm thanh.");
      }
    }
  }

  // ✅ HÀM BẮT ĐẦU/DỪNG THU ÂM
  Future<PronunciationResultModel?> toggleRecording() async {
    if (!_isRecorderInitialized || _isAssessing) return null;

    if (_isRecording) {
      // Dừng thu âm
      await _recorder.stop();
      _isRecording = false;
      notifyListeners();
      return await assessPronunciation();
    } else {
      if (currentCard != null) {
        _sessionResults.remove(currentCard!.vocabularyId);
      }

      _isRecording = true;
      notifyListeners();

      try {
        final config = RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        );
        final tempDir = await getTemporaryDirectory();
        _audioPath =
            '${tempDir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _recorder.start(config, path: _audioPath);
      } catch (e) {
        print("Lỗi bắt đầu thu âm: $e");
        ToastHelper.showError("Lỗi bắt đầu thu âm: $e");
        _isRecording = false;
        notifyListeners();
      }
    }
    return null;
  }

  // ✅ HÀM MỚI: Gửi đi chấm điểm
  Future<PronunciationResultModel?> assessPronunciation() async {
    final file = File(_audioPath);
    if (currentCard == null ||
        _isAssessing ||
        !await file.exists() ||
        await file.length() == 0) {
      if (!await file.exists() || await file.length() == 0) {
        ToastHelper.showError("Thu âm thất bại, vui lòng thử lại.");
      }
      return null;
    }

    _isAssessing = true;
    notifyListeners();

    try {
      final vocabId = currentCard!.vocabularyId;
      final result = await _repository.assessPronunciation(vocabId, _audioPath);
      _sessionResults[vocabId] = result;
      currentCard!.currentStrength = result.newStrength;
      return result;
    } catch (e) {
      ToastHelper.showError("Lỗi chấm điểm: $e");
      return null;
    } finally {
      _isAssessing = false;
      notifyListeners();
    }
  }

  void clear() {
    _session = null;
    _currentIndex = 0;
    _status = FlashcardStatus.loading;
    _audioPlayer.stop();
    if (_isRecording) {
      _recorder.stop();
    }
    _sessionResults.clear();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recorder.dispose();
    // clear();
    super.dispose();
  }
}
