import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/shared_widgets/comfirm_delete_dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/vocabulary_model.dart';
import 'package:mobile/services/admin/admin_vocabulary_service.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/widgets/admin/vocabulary_form_dialog.dart';
import 'package:provider/provider.dart';

class ManageVocabularyScreen extends StatefulWidget {
  final LessonModel lesson;
  const ManageVocabularyScreen({super.key, required this.lesson});

  @override
  State<ManageVocabularyScreen> createState() => _ManageVocabularyScreenState();
}

class _ManageVocabularyScreenState extends State<ManageVocabularyScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;

  // MÀU CHỦ ĐẠO
  static const Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    final vocabService = context.read<AdminVocabularyService>();
    _searchController.text = vocabService.currentSearchQuery ?? '';
    Future.microtask(() => _triggerFetch(pageNumber: 1));
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _triggerFetch(pageNumber: 1);
      }
    });
  }

  void _triggerFetch({int? pageNumber}) {
    final service = context.read<AdminVocabularyService>();
    final page = pageNumber ?? service.currentPage;
    final search = _searchController.text;
    service.fetchVocabularies(
      lessonId: widget.lesson.id,
      pageNumber: page,
      searchQuery: search,
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // (Hàm _showVocabularyForm, _confirmDelete, _playAudio giữ nguyên)
  void _showVocabularyForm({VocabularyModel? vocab}) async {
    final result = await showDialog<VocabularyModifyModel>(
      context: context,
      builder:
          (_) => VocabularyFormDialog(vocab: vocab, lessonId: widget.lesson.id),
    );
    if (result != null) {
      final service = context.read<AdminVocabularyService>();
      if (vocab == null) {
        await service.addVocabulary(result);
      } else {
        await service.updateVocabulary(vocab.id, result);
      }
    }
  }

  void _confirmDelete(VocabularyModel vocab) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xác nhận xóa',
            content: 'Bạn có chắc muốn xóa từ vựng "${vocab.referenceText}"?',
            itemName: vocab.referenceText,
            onConfirm: () async {
              await context.read<AdminVocabularyService>().deleteVocabulary(
                vocab.id,
                vocab.lessonId,
              );
            },
          ),
    );
  }

  Future<void> _playAudio(String url) async {
    if (_currentlyPlayingUrl == url && _audioPlayer.playing) {
      await _audioPlayer.stop();
      setState(() => _currentlyPlayingUrl = null);
    } else {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
      try {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        setState(() => _currentlyPlayingUrl = url);
      } catch (e) {
        debugPrint('Lỗi phát audio: $e');
        ToastHelper.showError('Không thể phát file audio này');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocabService = context.watch<AdminVocabularyService>();
    final vocabularies = vocabService.vocabularies;
    final isLoading = vocabService.isLoading;

    // ✅ 3. XÂY DỰNG BODYCONTENT
    Widget bodyContent;
    if (isLoading && vocabularies.isEmpty) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (vocabularies.isEmpty) {
      bodyContent = _buildEmptyState(vocabService.currentSearchQuery);
    } else {
      bodyContent = LayoutBuilder(
        builder:
            (context, constraints) =>
                _buildResponsiveTable(vocabularies, constraints.maxWidth),
      );
    }

    // ✅ 4. SỬ DỤNG BaseAdminScreen
    return BaseAdminScreen(
      title: 'Quản lý Từ vựng',
      subtitle: 'Bài học: ${widget.lesson.title}',
      headerIcon: Icons.menu_book,
      addLabel: 'Thêm Từ vựng',
      onAddPressed: () => _showVocabularyForm(),
      onBackPressed: () => Navigator.of(context).pop(),
      searchController: _searchController,
      searchHint: 'Tìm kiếm từ vựng, nghĩa...',
      isLoading: isLoading,
      totalCount: vocabService.totalCount,
      countLabel: 'từ', // 👈 Sửa label
      body: bodyContent,
      paginationControls: PaginationControls(
        currentPage: vocabService.currentPage,
        totalPages: vocabService.totalPages,
        totalCount: vocabService.totalCount,
        isLoading: isLoading,
        onPageChanged: (page) => _triggerFetch(pageNumber: page),
      ),
    );
  }

  // ✅ 5. SỬ DỤNG CommonEmptyState
  Widget _buildEmptyState(String? searchQuery) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;
    return CommonEmptyState(
      icon: Icons.library_books_outlined,
      title: isSearching ? 'Không tìm thấy kết quả' : 'Chưa có từ vựng nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Nhấn "Thêm Từ vựng" để bắt đầu',
    );
  }

  // ✅ 6. SỬ DỤNG BaseAdminTable
  Widget _buildResponsiveTable(
    List<VocabularyModel> vocabularies,
    double maxWidth,
  ) {
    final colWidths = {
      0: maxWidth * 0.06,
      1: maxWidth * 0.20,
      2: maxWidth * 0.25,
      3: maxWidth * 0.20,
      4: maxWidth * 0.10,
      5: maxWidth * 0.19,
    };
    final colHeaders = [
      'STT',
      'Từ vựng',
      'Nghĩa',
      'Phiên âm',
      'Audio',
      'Hành động',
    ];

    final int startingIndex =
        (context.read<AdminVocabularyService>().currentPage - 1) * 5;

    final dataRows =
        vocabularies.asMap().entries.map((entry) {
          final index = entry.key + startingIndex + 1;
          final vocab = entry.value;
          final isPlaying = _currentlyPlayingUrl == vocab.sampleAudioUrl;

          return TableRow(
            children: [
              // ✅ 7. SỬ DỤNG CommonTableCell
              CommonTableCell('$index', align: TextAlign.center, bold: true),
              CommonTableCell(
                vocab.referenceText,
                bold: true,
                color: const Color(0xFF1E3A8A),
                align: TextAlign.center,
              ),
              CommonTableCell(
                vocab.meaning ?? '-',
                color: Colors.grey.shade700,
                align: TextAlign.center,
              ),
              CommonTableCell(
                vocab.phonetic ?? '-',
                color: Colors.grey.shade700,
                align: TextAlign.center,
              ),
              CommonTableCell(
                // 👈 Dùng CommonTableCell
                vocab.sampleAudioUrl != null
                    ? _buildPlayButton(vocab.sampleAudioUrl!, isPlaying)
                    : const Icon(Icons.close, color: Colors.grey, size: 22),
                align: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ 8. SỬ DỤNG ActionIconButton
                    ActionIconButton(
                      icon: Icons.edit,
                      color: Colors.orange.shade600,
                      tooltip: 'Sửa',
                      onPressed: () => _showVocabularyForm(vocab: vocab),
                    ),
                    const SizedBox(width: 12),
                    ActionIconButton(
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      tooltip: 'Xóa',
                      onPressed: () => _confirmDelete(vocab),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList();

    return BaseAdminTable(
      columnWidths: colWidths.map((k, v) => MapEntry(k, FixedColumnWidth(v))),
      columnHeaders: colHeaders,
      dataRows: dataRows,
    );
  }

  Widget _buildPlayButton(String url, bool isPlaying) {
    return Container(
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.volume_up,
          color: primaryBlue,
          size: 22,
        ),
        tooltip: isPlaying ? 'Dừng' : 'Nghe phát âm',
        onPressed: () => _playAudio(url),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}
