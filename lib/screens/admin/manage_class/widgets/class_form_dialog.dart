import 'package:flutter/material.dart';
import 'package:mobile/data/models/class_model.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/user_model.dart';

class ClassFormDialog extends StatefulWidget {
  final ClassModel? classModel;
  final List<CourseModel> courses;
  final List<UserModel> teachers;
  final Future<bool> Function(String name, String courseId, String? teacherId)
  onSave;

  const ClassFormDialog({
    super.key,
    this.classModel,
    required this.courses,
    required this.teachers,
    required this.onSave,
  });

  @override
  State<ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends State<ClassFormDialog> {
  late TextEditingController _nameController;
  String? _selectedCourseId;
  String? _selectedTeacherId;
  bool _isSaving = false;

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
      // ToastHelper.showError('Tên lớp không được để trống');
      // Should show error in UI or Toast. Using ScaffoldMessenger for now or just return.
      // Since we are in a dialog, ToastHelper works if it uses a global context or overlay.
      // Assuming ToastHelper works.
      return;
    }
    if (courseId == null) {
      // ToastHelper.showError('Vui lòng chọn khóa học');
      return;
    }

    setState(() => _isSaving = true);

    final success = await widget.onSave(name, courseId, teacherId);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
      }
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
                    _buildModernDropdown<String>(
                      label: 'Khóa học',
                      value: _selectedCourseId,
                      hint: 'Chọn khóa học',
                      icon: Icons.book,
                      items:
                          widget.courses
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
                          widget.teachers
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
                        onPressed: _isSaving ? null : _handleSubmit,
                        child:
                            _isSaving
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Row(
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
                                      widget.classModel == null
                                          ? 'Thêm'
                                          : 'Lưu',
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
            icon: const Icon(Icons.arrow_drop_down, color: lightBlue),
          ),
        ),
      ],
    );
  }
}
