import 'package:flutter/material.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/screens/admin/manage_course/manage_course_view_model.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class CourseFormDialog extends StatefulWidget {
  final CourseModel? course; // nếu null => thêm mới, nếu khác null => sửa

  const CourseFormDialog({super.key, this.course});

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _rewardCoinsController;
  int _requiredLevel = 1; // mặc định cấp độ 1
  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.course?.description ?? '',
    );
    _durationController = TextEditingController(
      text: widget.course?.durationInWeeks.toString() ?? '',
    );
    _rewardCoinsController = TextEditingController(
      text: widget.course?.rewardCoins.toString() ?? '',
    );
    _requiredLevel = widget.course?.requiredLevel ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _rewardCoinsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ToastHelper.showError("Tên khóa học không được để trống");
      return;
    }
    if (_durationController.text.trim().isEmpty ||
        int.tryParse(_durationController.text.trim()) == null) {
      ToastHelper.showError("Thời lượng phải là số nguyên");
      return;
    }
    if (_rewardCoinsController.text.trim().isEmpty ||
        int.tryParse(_rewardCoinsController.text.trim()) == null) {
      ToastHelper.showError("Coin thưởng phải là số nguyên");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final course = CourseModel(
        id: widget.course?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        durationInWeeks: int.parse(_durationController.text.trim()),
        requiredLevel: _requiredLevel,
        rewardCoins: int.parse(_rewardCoinsController.text.trim()),
        // rewardExp sẽ để backend tính, không nhập ở đây
      );

      bool success;
      final viewModel = context.read<ManageCourseViewModel>();

      if (widget.course == null) {
        success = await viewModel.createCourse(course);
      } else {
        success = await viewModel.updateCourse(widget.course!.id!, course);
      }

      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ToastHelper.showError('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: backgroundBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.course == null ? Icons.add_circle : Icons.edit,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.course == null
                          ? 'Thêm khóa học mới'
                          : 'Chỉnh sửa khóa học',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Form content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildModernInputField(
                      controller: _nameController,
                      label: 'Tên khóa học',
                      hint: 'Nhập tên khóa học...',
                      icon: Icons.book,
                    ),
                    const SizedBox(height: 20),
                    _buildModernInputField(
                      controller: _descriptionController,
                      label: 'Mô tả',
                      hint: 'Nhập mô tả...',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildModernInputField(
                      controller: _durationController,
                      label: 'Thời lượng (tuần)',
                      hint: 'Nhập số tuần...',
                      icon: Icons.timer,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // Required Level
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Cấp độ yêu cầu",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _requiredLevel,
                          items: List.generate(
                            6,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text("Level ${i + 1}"),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null)
                              setState(() => _requiredLevel = value);
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: surfaceBlue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Reward coins
                    _buildModernInputField(
                      controller: _rewardCoinsController,
                      label: 'Coin thưởng',
                      hint: 'Nhập số coin thưởng...',
                      icon: Icons.stars,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: primaryBlue.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.course == null
                                          ? Icons.add
                                          : Icons.save,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.course == null ? 'Thêm' : 'Lưu',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: surfaceBlue),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: lightBlue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
