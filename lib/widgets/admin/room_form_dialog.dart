import 'package:flutter/material.dart';
import 'package:mobile/data/models/room_model.dart';
import 'package:mobile/services/admin/admin_room_service.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class RoomFormDialog extends StatefulWidget {
  final RoomModel? room;

  const RoomFormDialog({super.key, this.room});

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  String _status = "active";

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room?.name ?? '');
    _capacityController = TextEditingController(
      text: widget.room?.capactity.toString() ?? '',
    );
    _status = widget.room?.status ?? "active";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final capactity = int.tryParse(_capacityController.text.trim());
    final status = _status;

    if (name.isEmpty) {
      ToastHelper.showError('Tên phòng không được để trống');
      return;
    }
    if (capactity == null || capactity <= 0) {
      ToastHelper.showError('Sức chứa phải là số nguyên dương');
      return;
    }

    final roomService = context.read<AdminRoomService>();
    bool success = false;

    final room = RoomModel(
      id: widget.room?.id ?? '',
      name: name,
      capactity: capactity,
      status: status,
    );

    if (widget.room == null) {
      success = await roomService.addRoom(room);
    } else {
      success = await roomService.updateRoom(widget.room!.id, room);
    }

    if (success && context.mounted) {
      Navigator.of(context).pop();
    } else {
      ToastHelper.showError('Xảy ra lỗi khi lưu phòng');
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
                      widget.room == null ? Icons.add_circle : Icons.edit,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.room == null
                          ? 'Thêm phòng học mới'
                          : 'Chỉnh sửa phòng học',
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
                      label: 'Tên phòng học',
                      hint: 'Nhập tên phòng...',
                      icon: Icons.meeting_room,
                    ),
                    const SizedBox(height: 20),

                    _buildModernInputField(
                      controller: _capacityController,
                      label: 'Sức chứa',
                      hint: 'Nhập số lượng chỗ ngồi...',
                      icon: Icons.people,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    _buildModernDropdown<String>(
                      label: 'Trạng thái',
                      value: _status,
                      hint: 'Chọn trạng thái',
                      icon: Icons.check_circle,
                      items: const [
                        DropdownMenuItem(
                          value: "active",
                          child: Text("Hoạt động"),
                        ),
                        DropdownMenuItem(
                          value: "inactive",
                          child: Text("Ngưng hoạt động"),
                        ),
                      ],
                      onChanged:
                          (value) =>
                              setState(() => _status = value ?? "active"),
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
                              widget.room == null ? Icons.add : Icons.save,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.room == null ? 'Thêm' : 'Lưu',
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
