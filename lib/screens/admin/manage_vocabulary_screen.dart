import 'dart:async';
import 'package:flutter/material.dart';
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
    // Reset về chế độ xem mặc định (không xem rác) khi vào màn hình
    if (vocabService.showDeleted) {
      Future.microtask(() => vocabService.toggleShowDeleted(widget.lesson.id));
    } else {
      Future.microtask(() => _triggerFetch(pageNumber: 1));
    }

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

  // ✅ [ĐÃ SỬA] Sử dụng dialogContext trực tiếp, bỏ Builder không cần thiết
  void _confirmDelete(VocabularyModel vocab) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Chuyển vào thùng rác?'),
          content: Text(
            'Bạn có chắc muốn ẩn từ vựng "${vocab.referenceText ?? ''}"?',
          ),
          actions: [
            TextButton(
              // Dùng Navigator.of(dialogContext) để chắc chắn pop đúng dialog
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                // 1. Đóng dialog trước
                Navigator.of(dialogContext).pop();

                // 2. Gọi API xóa
                // Lưu ý: Dùng 'context' của State (ManageVocabularyScreen) để gọi Provider
                await context.read<AdminVocabularyService>().deleteVocabulary(
                  vocab.id,
                  vocab.lessonId,
                );
              },
              child: const Text(
                'Đồng ý',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ [ĐÃ SỬA] Fix lỗi dialog không đóng hoặc đóng nhầm màn hình
  void _confirmRestore(VocabularyModel vocab) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Khôi phục từ vựng'),
          content: Text(
            'Bạn muốn khôi phục "${vocab.referenceText ?? ''}" trở lại danh sách bài học?',
          ),
          actions: [
            TextButton(
              // Dùng Navigator.of(dialogContext) là an toàn nhất
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                // 1. Đóng dialog NGAY LẬP TỨC bằng dialogContext
                Navigator.of(dialogContext).pop();

                // 2. Gọi API khôi phục sau khi dialog đã đóng
                await context.read<AdminVocabularyService>().restoreVocabulary(
                  vocab.id,
                  vocab.lessonId,
                );
              },
              child: const Text(
                'Khôi phục',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
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
    final showDeleted = vocabService.showDeleted;

    Widget bodyContent;

    Widget mainContent;
    if (isLoading && vocabularies.isEmpty) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (vocabularies.isEmpty) {
      mainContent = _buildEmptyState(
        vocabService.currentSearchQuery,
        showDeleted,
      );
    } else {
      mainContent = LayoutBuilder(
        builder:
            (context, constraints) => _buildResponsiveTable(
              vocabularies,
              constraints.maxWidth,
              showDeleted,
            ),
      );
    }

    bodyContent = Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: showDeleted ? Colors.red.shade50 : Colors.blue.shade50,
          child: Row(
            children: [
              Icon(
                showDeleted ? Icons.delete_sweep : Icons.check_circle,
                color: showDeleted ? Colors.red : primaryBlue,
              ),
              const SizedBox(width: 12),
              Text(
                showDeleted ? 'Đang xem Thùng Rác' : 'Danh sách Hiển thị',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: showDeleted ? Colors.red : primaryBlue,
                ),
              ),
              const Spacer(),
              const Text('Xem Thùng rác', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Switch(
                value: showDeleted,
                activeColor: Colors.red,
                onChanged: (value) {
                  context.read<AdminVocabularyService>().toggleShowDeleted(
                    widget.lesson.id,
                  );
                },
              ),
            ],
          ),
        ),

        Expanded(child: mainContent),
      ],
    );

    return BaseAdminScreen(
      title: 'Quản lý Từ vựng',
      subtitle:
          showDeleted
              ? 'THÙNG RÁC - ${widget.lesson.title}'
              : 'Bài học: ${widget.lesson.title}',
      headerIcon: showDeleted ? Icons.delete_outline : Icons.menu_book,

      addLabel: 'Thêm Từ vựng',
      onAddPressed: () {
        if (showDeleted) {
          context.read<AdminVocabularyService>().toggleShowDeleted(
            widget.lesson.id,
          );
        }
        _showVocabularyForm();
      },

      onBackPressed: () => Navigator.of(context).pop(),
      searchController: _searchController,
      searchHint: 'Tìm kiếm từ vựng...',
      isLoading: isLoading,
      totalCount: vocabService.totalCount,
      countLabel: 'từ',
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

  Widget _buildEmptyState(String? searchQuery, bool showDeleted) {
    bool isSearching = searchQuery != null && searchQuery.isNotEmpty;

    if (showDeleted) {
      return CommonEmptyState(
        icon: Icons.delete_sweep_outlined,
        title:
            isSearching ? 'Không tìm thấy trong thùng rác' : 'Thùng rác trống',
        subtitle:
            isSearching
                ? 'Thử từ khóa khác'
                : 'Các từ vựng bị xóa sẽ xuất hiện ở đây',
      );
    }

    return CommonEmptyState(
      icon: Icons.library_books_outlined,
      title: isSearching ? 'Không tìm thấy kết quả' : 'Chưa có từ vựng nào',
      subtitle:
          isSearching
              ? 'Thử tìm kiếm bằng từ khóa khác'
              : 'Nhấn "Thêm Từ vựng" để bắt đầu',
    );
  }

  Widget _buildResponsiveTable(
    List<VocabularyModel> vocabularies,
    double maxWidth,
    bool showDeleted,
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
      showDeleted ? 'Khôi phục' : 'Hành động',
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
              CommonTableCell('$index', align: TextAlign.center, bold: true),
              CommonTableCell(
                vocab.referenceText ?? '',
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
                    if (showDeleted) ...[
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.restore,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Khôi phục',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () => _confirmRestore(vocab),
                      ),
                    ] else ...[
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
