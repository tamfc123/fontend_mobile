import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/services/admin/class_service.dart';
import 'package:mobile/services/admin/user_service.dart';
import 'package:mobile/services/admin/course_service.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class ClassFormDialog extends StatefulWidget {
  final ClassModel? classModel;

  const ClassFormDialog({super.key, this.classModel});

  @override
  State<ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends State<ClassFormDialog> {
  late TextEditingController _nameController;
  int? _selectedCourseId;
  String? _selectedTeacherId;

  // Màu sắc chủ đạo
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.classModel?.name ?? '',
    );
    _selectedCourseId = widget.classModel?.courseId;
    _selectedTeacherId = widget.classModel?.teacherId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final courseId = _selectedCourseId;
    final teacherId = _selectedTeacherId;

    if (name.isEmpty) {
      ToastHelper.showError('Tên lớp không được để trống');
      return;
    }
    if (courseId == null) {
      ToastHelper.showError('Vui lòng chọn khóa học');
      return;
    }

    final classService = context.read<ClassService>();
    bool success = false;

    if (widget.classModel == null) {
      success = await classService.addClass(name, courseId, teacherId);
    } else {
      success = await classService.updateClass(
        widget.classModel!.id,
        name,
        courseId,
        teacherId,
      );
    }
    if (success) {
      Navigator.of(context).pop();
    } else {
      ToastHelper.showError('Xảy ra lỗi khi lưu lớp học');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final teachers = userService.teachers;

    final courseService = context.watch<CourseService>();
    final courses = courseService.courses;

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
                      widget.classModel == null ? Icons.add_circle : Icons.edit,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.classModel == null
                          ? 'Thêm lớp học mới'
                          : 'Chỉnh sửa lớp học',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildModernInputField(
                      controller: _nameController,
                      label: 'Tên lớp học',
                      hint: 'Nhập tên lớp học...',
                      icon: Icons.class_,
                    ),
                    const SizedBox(height: 20),

                    // Khóa học
                    _buildModernDropdown<int>(
                      label: 'Khóa học',
                      value: _selectedCourseId,
                      hint: 'Chọn khóa học',
                      icon: Icons.book,
                      items:
                          courses
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => _selectedCourseId = value),
                    ),
                    const SizedBox(height: 20),

                    // Giảng viên
                    _buildModernDropdown<String>(
                      label: 'Giảng viên',
                      value: _selectedTeacherId,
                      hint: 'Chọn giảng viên (tùy chọn)',
                      icon: Icons.person,
                      items:
                          teachers
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.name),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => _selectedTeacherId = value),
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
                        onPressed: _handleSubmit,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.classModel == null
                                  ? Icons.add
                                  : Icons.save,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.classModel == null ? 'Thêm' : 'Lưu',
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

  Widget _buildModernDropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
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
          child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: Icon(icon, color: lightBlue),
            ),
            hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
            items: items,
            onChanged: onChanged,
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: lightBlue),
          ),
        ),
      ],
    );
  }
}
