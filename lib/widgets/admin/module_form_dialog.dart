import 'package:flutter/material.dart';
import 'package:mobile/data/models/module_model.dart';

class ModuleFormDialog extends StatefulWidget {
  final ModuleModel? module; // Nếu null là TẠO MỚI, có là SỬA
  final int courseId; // Bắt buộc phải có để biết tạo cho course nào

  const ModuleFormDialog({super.key, this.module, required this.courseId});

  @override
  State<ModuleFormDialog> createState() => _ModuleFormDialogState();
}

class _ModuleFormDialogState extends State<ModuleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _order;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.module != null;
    _titleController = TextEditingController(text: widget.module?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.module?.description ?? '',
    );
    _order = widget.module?.order ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Tạo một ModuleModel (dù là Thêm hay Sửa)
      // Service sẽ tự biết cách xử lý
      final result = ModuleModel(
        id: widget.module?.id ?? 0, // 0 nếu tạo mới
        courseId: widget.courseId, // Luôn dùng courseId được truyền vào
        title: _titleController.text,
        description: _descriptionController.text,
        order: _order, // Giữ nguyên order khi sửa
      );
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Cập nhật Chương' : 'Tạo Chương mới'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên Chương',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên chương';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEdit ? 'Cập nhật' : 'Tạo mới'),
        ),
      ],
    );
  }
}
