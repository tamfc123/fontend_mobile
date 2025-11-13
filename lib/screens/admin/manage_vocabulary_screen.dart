import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/vocabulary_model.dart';
import 'package:mobile/services/admin/admin_vocabulary_service.dart';
import 'package:mobile/widgets/admin/comfirm_delete_dialog.dart';
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
  String _searchQuery = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;

  // MÀU CHỦ ĐẠO
  static const Color primaryBlue = Colors.blue;
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AdminVocabularyService>().fetchVocabularies(
        widget.lesson.id,
      ),
    );
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
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
      // DỪNG NẾU ĐANG PHÁT TỪ KHÁC
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
      // LOAD VÀ PHÁT TỪ MỚI
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      setState(() => _currentlyPlayingUrl = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocabService = context.watch<AdminVocabularyService>();
    final vocabularies = vocabService.vocabularies;

    final filteredVocabularies =
        vocabularies.where((v) {
          return v.referenceText.toLowerCase().contains(_searchQuery) ||
              (v.meaning?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER + BACK + TÌM KIẾM ===
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            // NÚT QUAY LẠI
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                              ),
                              label: const Text(
                                'Quay lại',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // ICON + TIÊU ĐỀ
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.menu_book,
                                color: primaryBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quản lý Từ vựng',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bài học: ${widget.lesson.title}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // NÚT THÊM
                            ElevatedButton.icon(
                              onPressed: () => _showVocabularyForm(),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              label: const Text(
                                'Thêm Từ vựng',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // TÌM KIẾM
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: surfaceBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm từ vựng, nghĩa, phiên âm...',
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              prefixIcon: Icon(
                                Icons.search,
                                color: primaryBlue,
                              ),
                              suffixIcon:
                                  _searchQuery.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: _searchController.clear,
                                      )
                                      : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === BẢNG TỪ VỰNG VỚI NÚT PLAY AUDIO ===
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child:
                              vocabService.isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryBlue,
                                    ),
                                  )
                                  : filteredVocabularies.isEmpty
                                  ? _buildEmptyState()
                                  : _buildResponsiveTable(
                                    filteredVocabularies,
                                    constraints.maxWidth,
                                  ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Chưa có từ vựng nào'
                : 'Không tìm thấy kết quả',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Nhấn "Thêm Từ vựng" để bắt đầu'
                : 'Thử tìm kiếm bằng từ khóa khác',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

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

    return SingleChildScrollView(
      child: IntrinsicWidth(
        child: Table(
          columnWidths: colWidths.map(
            (k, v) => MapEntry(k, FixedColumnWidth(v)),
          ),
          border: TableBorder(
            bottom: BorderSide(color: surfaceBlue),
            horizontalInside: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(color: surfaceBlue),
              children:
                  ['STT', 'Từ vựng', 'Nghĩa', 'Phiên âm', 'Audio', 'Hành động']
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      .toList(),
            ),
            ...vocabularies.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final vocab = entry.value;
              final isPlaying = _currentlyPlayingUrl == vocab.sampleAudioUrl;

              return TableRow(
                children: [
                  _buildCell('$index', align: TextAlign.center, bold: true),
                  _buildCell(
                    vocab.referenceText,
                    bold: true,
                    color: const Color(0xFF1E3A8A),
                  ),
                  _buildCell(vocab.meaning ?? '-', color: Colors.grey.shade700),
                  _buildCell(
                    vocab.phonetic ?? '-',
                    color: Colors.grey.shade700,
                  ),
                  _buildCell(
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
                        _buildActionButton(
                          Icons.edit,
                          Colors.orange.shade600,
                          'Sửa',
                          () => _showVocabularyForm(vocab: vocab),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          Icons.delete,
                          Colors.redAccent,
                          'Xóa',
                          () => _confirmDelete(vocab),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
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

  Widget _buildCell(
    dynamic content, {
    TextAlign align = TextAlign.left,
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child:
          content is Widget
              ? content
              : Text(
                content.toString(),
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                  color: color ?? Colors.black87,
                  fontSize: 14.5,
                ),
                textAlign: align,
              ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}
