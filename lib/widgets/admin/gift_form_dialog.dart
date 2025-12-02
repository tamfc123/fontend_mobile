import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/gift_model.dart';
import 'package:mobile/domain/repositories/upload_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class GiftFormDialog extends StatefulWidget {
  final GiftModel? gift; // Nếu null là tạo mới, có data là sửa

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
        withData: true, // Quan trọng cho Web
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() => _isUploading = true);

        final bytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        // Gọi Upload Repo (đã có sẵn trong project)
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
        id: widget.gift?.id ?? '', // ID rỗng nếu tạo mới
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
    return AlertDialog(
      title: Text(
        widget.gift == null ? 'Thêm Quà Tặng Mới' : 'Cập Nhật Quà Tặng',
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500, // Cố định chiều rộng cho đẹp trên Web
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Ảnh đại diện
                GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
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
                            ? const Center(child: CircularProgressIndicator())
                            : _imageUrl == null
                            ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Chọn ảnh',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Tên quà
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên quà tặng *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên quà' : null,
                ),
                const SizedBox(height: 16),

                // 3. Giá & Tồn kho (Nằm cùng hàng)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Giá Coin *',
                          suffixText: 'Xu',
                          border: OutlineInputBorder(),
                        ),
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
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Tồn kho *',
                          suffixText: 'cái',
                          border: OutlineInputBorder(),
                        ),
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
                const SizedBox(height: 16),

                // 4. Mô tả
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả chi tiết',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _submit,
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
