import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/domain/repositories/common/upload_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class GiftFormDialog extends StatefulWidget {
  final GiftModel? gift;

  const GiftFormDialog({super.key, this.gift});

  @override
  State<GiftFormDialog> createState() => _GiftFormDialogState();
}

class _GiftFormDialogState extends State<GiftFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  String? _imageUrl;
  bool _isUploading = false;

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    final g = widget.gift;
    _nameController = TextEditingController(text: g?.name ?? '');
    _descController = TextEditingController(text: g?.description ?? '');
    _priceController = TextEditingController(
      text: g?.coinPrice.toString() ?? '0',
    );
    _stockController = TextEditingController(
      text: g?.stockQuantity.toString() ?? '0',
    );
    _imageUrl = g?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() => _isUploading = true);

        final bytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        final url = await context.read<UploadRepository>().uploadImage(
          bytes,
          fileName,
        );

        setState(() {
          _imageUrl = url;
          _isUploading = false;
        });
        ToastHelper.showSuccess('Upload ảnh thành công');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ToastHelper.showError('Lỗi upload ảnh: $e');
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final gift = GiftModel(
        id: widget.gift?.id ?? '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        coinPrice: int.tryParse(_priceController.text) ?? 0,
        stockQuantity: int.tryParse(_stockController.text) ?? 0,
        imageUrl: _imageUrl,
      );
      Navigator.of(context).pop(gift);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
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
              // Gradient Header
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
                      widget.gift == null ? Icons.card_giftcard : Icons.edit,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.gift == null
                          ? 'Thêm quà tặng mới'
                          : 'Chỉnh sửa quà tặng',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Image Picker
                      GestureDetector(
                        onTap: _isUploading ? null : _pickImage,
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: surfaceBlue, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withValues(alpha: 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            image:
                                _imageUrl != null
                                    ? DecorationImage(
                                      image: NetworkImage(_imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              _isUploading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryBlue,
                                    ),
                                  )
                                  : _imageUrl == null
                                  ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Chọn ảnh quà tặng',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name Field
                      _buildModernInputField(
                        controller: _nameController,
                        label: 'Tên quà tặng',
                        hint: 'Nhập tên quà tặng...',
                        icon: Icons.card_giftcard_outlined,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Vui lòng nhập tên quà'
                                    : null,
                      ),
                      const SizedBox(height: 20),

                      // Price and Stock Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernInputField(
                              controller: _priceController,
                              label: 'Giá Coin',
                              hint: 'Số coin...',
                              icon: Icons.monetization_on_outlined,
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      int.tryParse(v ?? '') == null
                                          ? 'Phải là số'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildModernInputField(
                              controller: _stockController,
                              label: 'Tồn kho',
                              hint: 'Số lượng...',
                              icon: Icons.inventory_2_outlined,
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      int.tryParse(v ?? '') == null
                                          ? 'Phải là số'
                                          : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description Field
                      _buildModernInputField(
                        controller: _descController,
                        label: 'Mô tả chi tiết',
                        hint: 'Nhập mô tả...',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
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
                        onPressed: _isUploading ? null : _submit,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.gift == null ? Icons.add : Icons.save,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.gift == null ? 'Thêm' : 'Lưu',
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
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
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
