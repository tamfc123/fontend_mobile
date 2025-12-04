import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/vocabulary_model.dart';

import 'package:mobile/screens/admin/manage_vocabulary/manage_vocabulary_view_model.dart';
import 'package:mobile/screens/admin/manage_vocabulary/widgets/manage_vocabulary_content.dart';
import 'package:mobile/screens/admin/manage_vocabulary/widgets/vocabulary_form_dialog.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageVocabularyViewModel>().fetchVocabularies(
        lessonId: widget.lesson.id,
        pageNumber: 1,
        searchQuery: '',
      );
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ManageVocabularyViewModel>().fetchVocabularies(
          lessonId: widget.lesson.id,
          pageNumber: 1,
          searchQuery: _searchController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _showVocabularyForm({VocabularyModel? vocab}) async {
    final result = await showDialog<VocabularyModifyModel>(
      context: context,
      builder:
          (_) => VocabularyFormDialog(vocab: vocab, lessonId: widget.lesson.id),
    );
    if (result != null && mounted) {
      final viewModel = context.read<ManageVocabularyViewModel>();
      if (vocab == null) {
        await viewModel.addVocabulary(result);
      } else {
        await viewModel.updateVocabulary(vocab.id, result);
      }
    }
  }

  void _confirmDelete(VocabularyModel vocab) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Chuyển vào thùng rác?'),
          content: Text(
            'Bạn có chắc muốn ẩn từ vựng "${vocab.referenceText}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await context
                    .read<ManageVocabularyViewModel>()
                    .deleteVocabulary(vocab.id, vocab.lessonId);
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

  void _confirmRestore(VocabularyModel vocab) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Khôi phục từ vựng'),
          content: Text(
            'Bạn muốn khôi phục "${vocab.referenceText}" trở lại danh sách bài học?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await context
                    .read<ManageVocabularyViewModel>()
                    .restoreVocabulary(vocab.id, vocab.lessonId);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageVocabularyViewModel>(
      builder: (context, viewModel, child) {
        final isLoading = viewModel.isLoading;
        final showDeleted = viewModel.showDeleted;

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
              viewModel.toggleShowDeleted(widget.lesson.id);
            }
            _showVocabularyForm();
          },
          onBackPressed: () => Navigator.of(context).pop(),
          searchController: _searchController,
          searchHint: 'Tìm kiếm từ vựng...',
          isLoading: isLoading,
          totalCount: viewModel.totalCount,
          countLabel: 'từ',
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth =
                  constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
              return ManageVocabularyContent(
                viewModel: viewModel,
                lessonId: widget.lesson.id,
                maxWidth: tableWidth,
                onShowForm: () {
                  if (showDeleted) {
                    viewModel.toggleShowDeleted(widget.lesson.id);
                  }
                  _showVocabularyForm();
                },
                onEdit: (vocab) => _showVocabularyForm(vocab: vocab),
                onDelete: (vocab) => _confirmDelete(vocab),
                onRestore: (vocab) => _confirmRestore(vocab),
              );
            },
          ),
          paginationControls: PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalCount: viewModel.totalCount,
            isLoading: isLoading,
            onPageChanged:
                (page) => viewModel.fetchVocabularies(
                  lessonId: widget.lesson.id,
                  pageNumber: page,
                  searchQuery: viewModel.currentSearchQuery,
                ),
          ),
        );
      },
    );
  }
}
