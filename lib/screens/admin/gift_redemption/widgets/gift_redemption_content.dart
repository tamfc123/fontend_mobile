import 'package:flutter/material.dart';
import 'package:mobile/screens/admin/gift_redemption/gift_redemption_view_model.dart';
import 'package:mobile/screens/admin/gift_redemption/widgets/student_table.dart';
import 'package:mobile/shared_widgets/admin/common_empty_state.dart';

class GiftRedemptionContent extends StatelessWidget {
  final GiftRedemptionViewModel viewModel;
  final double maxWidth;

  const GiftRedemptionContent({
    super.key,
    required this.viewModel,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoadingStudents && viewModel.students.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (viewModel.students.isEmpty && viewModel.searchQuery.isNotEmpty) {
      return const CommonEmptyState(
        icon: Icons.person_search,
        title: 'Không tìm thấy học viên',
        subtitle: 'Thử tìm kiếm bằng từ khóa khác',
      );
    }

    if (viewModel.students.isEmpty) {
      return const CommonEmptyState(
        icon: Icons.person_off_outlined,
        title: 'Chưa có học viên nào',
        subtitle: 'Nhập tên hoặc email để tìm kiếm học viên',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth =
            constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;
        return StudentTable(
          students: viewModel.students,
          maxWidth: tableWidth,
          onViewRedemptions: (student) {
            viewModel.selectStudent(student);
          },
        );
      },
    );
  }
}
