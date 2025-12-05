import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile/data/models/media_file_model.dart';

import 'package:mobile/screens/admin/manage_media/manage_media_view_model.dart';
import 'package:mobile/screens/admin/manage_media/widgets/manage_media_content.dart';
import 'package:mobile/shared_widgets/admin/base_admin_screen.dart';
import 'package:mobile/shared_widgets/admin/pagination_controls.dart';
import 'package:mobile/shared_widgets/admin/comfirm_delete_dialog.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class ManageMediaScreen extends StatefulWidget {
  const ManageMediaScreen({super.key});

  @override
  State<ManageMediaScreen> createState() => _ManageMediaScreenState();
}

class _ManageMediaScreenState extends State<ManageMediaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile(BuildContext context) async {
    final viewModel = context.read<ManageMediaViewModel>();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
        withData: true,
      );

      if (result != null) {
        await viewModel.uploadAudio(result.files.first);
      }
    } catch (e) {
      ToastHelper.showError('Lỗi chọn file: $e');
    }
  }

  void _copyToClipboard(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ToastHelper.showSuccess('Đã sao chép link!');
  }

  void _confirmDelete(BuildContext context, MediaFileModel file) {
    showDialog(
      context: context,
      builder:
          (_) => ConfirmDeleteDialog(
            title: 'Xóa file media',
            content:
                'Bạn có chắc muốn xóa file "${file.fileName}"?\n(Cảnh báo: Nếu file đang dùng trong bài thi, bạn sẽ không thể xóa)',
            itemName: file.fileName,
            onConfirm: () async {
              await context.read<ManageMediaViewModel>().deleteMedia(file.id);
            },
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageMediaViewModel>().fetchMedia(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageMediaViewModel>(
      builder: (context, viewModel, child) {
        return BaseAdminScreen(
          title: 'Quản lý Media',
          subtitle: 'Danh sách file audio',
          headerIcon: Icons.audio_file,
          addLabel: 'Upload Audio',
          onAddPressed: () => _pickAndUploadFile(context),
          onBackPressed: null,
          searchController: _searchController,
          searchHint: 'Tìm kiếm file media...',
          isLoading: viewModel.isLoading,
          totalCount: viewModel.totalCount,
          countLabel: 'file',
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth =
                  constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
              return ManageMediaContent(
                viewModel: viewModel,
                maxWidth: tableWidth,
                onCopyToClipboard: _copyToClipboard,
                onConfirmDelete: (file) => _confirmDelete(context, file),
              );
            },
          ),
          paginationControls: PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalCount: viewModel.totalCount,
            isLoading: viewModel.isLoading,
            onPageChanged: (page) => viewModel.goToPage(page),
          ),
        );
      },
    );
  }
}
