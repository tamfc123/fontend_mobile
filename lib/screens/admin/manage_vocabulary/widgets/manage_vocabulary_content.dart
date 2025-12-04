import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile/data/models/vocabulary_model.dart';
import 'package:mobile/screens/admin/manage_vocabulary/manage_vocabulary_view_model.dart';
import 'package:mobile/shared_widgets/admin/action_icon_button.dart';
import 'package:mobile/shared_widgets/admin/base_admin_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';
import 'package:mobile/shared_widgets/admin/common_table_cell.dart';
import 'package:mobile/utils/toast_helper.dart';

class ManageVocabularyContent extends StatefulWidget {
  final ManageVocabularyViewModel viewModel;
  final String lessonId;
  final VoidCallback onShowForm;
  final Function(VocabularyModel) onEdit;
  final Function(VocabularyModel) onDelete;
  final Function(VocabularyModel) onRestore;

  const ManageVocabularyContent({
    super.key,
    required this.viewModel,
    required this.lessonId,
    required this.onShowForm,
    required this.onEdit,
    required this.onDelete,
    required this.onRestore,
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  State<ManageVocabularyContent> createState() =>
      _ManageVocabularyContentState();
}

class _ManageVocabularyContentState extends State<ManageVocabularyContent> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    if (_currentlyPlayingUrl == url && _audioPlayer.playing) {
      await _audioPlayer.stop();
      if (mounted) setState(() => _currentlyPlayingUrl = null);
    } else {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
      try {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        if (mounted) setState(() => _currentlyPlayingUrl = url);
      } catch (e) {
        debugPrint('Lỗi phát audio: $e');
        ToastHelper.showError('Không thể phát file audio này');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocabularies = widget.viewModel.vocabularies;
    final isLoading = widget.viewModel.isLoading;
    final showDeleted = widget.viewModel.showDeleted;

    Widget mainContent;

    if (isLoading && vocabularies.isEmpty) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (vocabularies.isEmpty) {
      mainContent = _buildEmptyState(
        widget.viewModel.currentSearchQuery,
        showDeleted,
      );
    } else {
      mainContent = _buildResponsiveTable(
        context,
        vocabularies,
        widget.maxWidth,
        showDeleted,
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: showDeleted ? Colors.red.shade50 : Colors.blue.shade50,
          child: Row(
            children: [
              Icon(
                showDeleted ? Icons.delete_sweep : Icons.check_circle,
                color: showDeleted ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 12),
              Text(
                showDeleted ? 'Đang xem Thùng Rác' : 'Danh sách Hiển thị',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: showDeleted ? Colors.red : Colors.blue,
                ),
              ),
              const Spacer(),
              const Text('Xem Thùng rác', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Switch(
                value: showDeleted,
                activeColor: Colors.red,
                onChanged: (value) {
                  widget.viewModel.toggleShowDeleted(widget.lessonId);
                },
              ),
            ],
          ),
        ),
        Expanded(child: mainContent),
      ],
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
    BuildContext context,
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

    final int startingIndex = (widget.viewModel.currentPage - 1) * 5;

    final dataRows =
        vocabularies.asMap().entries.map((entry) {
          final index = entry.key + startingIndex + 1;
          final vocab = entry.value;
          final isPlaying = _currentlyPlayingUrl == vocab.sampleAudioUrl;

          return TableRow(
            children: [
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
                        onPressed: () => widget.onRestore(vocab),
                      ),
                    ] else ...[
                      ActionIconButton(
                        icon: Icons.edit,
                        color: Colors.orange.shade600,
                        tooltip: 'Sửa',
                        onPressed: () => widget.onEdit(vocab),
                      ),
                      const SizedBox(width: 12),
                      ActionIconButton(
                        icon: Icons.delete,
                        color: Colors.redAccent,
                        tooltip: 'Xóa',
                        onPressed: () => widget.onDelete(vocab),
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
        color: Colors.blue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.volume_up,
          color: Colors.blue,
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
