import 'package:flutter/material.dart';
import 'package:mobile/services/student/student_profile_service.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditProfileStudentScreen extends StatefulWidget {
  const EditProfileStudentScreen({super.key});

  @override
  State<EditProfileStudentScreen> createState() =>
      _EditProfileStudentScreenState();
}

class _EditProfileStudentScreenState extends State<EditProfileStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  DateTime? _birthday;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<StudentProfileService>().profile;
    _nameController = TextEditingController(text: profile?.name ?? "");
    _phoneController = TextEditingController(text: profile?.phone ?? "");
    _birthday = profile?.birthday;

    // Listen for changes
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = context.read<StudentProfileService>().profile;

    await context.read<StudentProfileService>().updateProfile(
      name:
          _nameController.text.isNotEmpty
              ? _nameController.text
              : profile?.name,
      phone:
          _phoneController.text.isNotEmpty
              ? _phoneController.text
              : profile?.phone,
      birthday: _birthday ?? profile?.birthday,
    );

    final error = context.read<StudentProfileService>().error;
    if (error == null) {
      if (!mounted) return;
      ToastHelper.showSuccess("Cập nhật hồ sơ thành công");
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ToastHelper.showError(error);
    }
  }

  Future<void> _showDiscardDialog() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Hủy thay đổi?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Bạn có những thay đổi chưa được lưu. Bạn có chắc muốn hủy?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tiếp tục chỉnh sửa'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hủy bỏ'),
              ),
            ],
          ),
    );

    if (shouldDiscard == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<StudentProfileService>().isLoading;

    return PopScope(
      canPop: false, // chặn pop mặc định
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // nếu đã pop thì thôi

        await _showDiscardDialog();
        // trong dialog nếu user chọn Đồng ý -> Navigator.pop(context)
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),

        // Modern AppBar
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          centerTitle: true,
          title: const Text(
            "Chỉnh sửa thông tin",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _showDiscardDialog,
          ),
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header illustration
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 56,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cập nhật thông tin cá nhân',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Điền đầy đủ thông tin để chúng tôi hỗ trợ bạn tốt hơn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Form card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field
                      _buildTextField(
                        controller: _nameController,
                        label: "Họ và tên",
                        hint: "Nhập họ và tên của bạn",
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập họ tên";
                          }
                          if (value.length < 2) {
                            return "Họ tên phải có ít nhất 2 ký tự";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Phone field
                      _buildTextField(
                        controller: _phoneController,
                        label: "Số điện thoại",
                        hint: "Nhập số điện thoại",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            // Basic phone validation
                            final phoneRegex = RegExp(r'^[0-9]{10}$');
                            if (!phoneRegex.hasMatch(value)) {
                              return "Số điện thoại không hợp lệ (10 chữ số)";
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Birthday field
                      _buildBirthdayField(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade100, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.amber.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Thông tin của bạn sẽ được bảo mật và chỉ sử dụng cho mục đích học tập',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save button (full width at bottom)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Lưu thay đổi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.blue.shade600, size: 22),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Birthday field builder
  Widget _buildBirthdayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ngày sinh",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _birthday ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue.shade600,
                      onPrimary: Colors.white,
                      onSurface: const Color(0xFF1F2937),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              setState(() {
                _birthday = DateTime.utc(picked.year, picked.month, picked.day);
                _hasChanges = true;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cake_outlined,
                  color: Colors.blue.shade600,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _birthday != null
                        ? DateFormat('dd/MM/yyyy').format(_birthday!)
                        : "Chọn ngày sinh",
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          _birthday != null
                              ? const Color(0xFF1F2937)
                              : Colors.grey.shade400,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.grey.shade600,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
