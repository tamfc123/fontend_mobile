import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:mobile/screens/admin/manage_quiz/manage_quiz_view_model.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';
import 'package:mobile/dart_helpers/html_helper.dart'
    if (dart.library.html) 'dart:html'
    as html;

class AdminQuizFormDialog extends StatefulWidget {
  final String courseId;

  const AdminQuizFormDialog({super.key, required this.courseId});

  @override
  State<AdminQuizFormDialog> createState() => _AdminQuizFormDialogState();
}

class _AdminQuizFormDialogState extends State<AdminQuizFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final _readingPassageController = TextEditingController();

  String _selectedSkillType = 'READING';
  PlatformFile? _selectedFile;
  bool _isCreating = false;

  static const Color primaryBlue = Colors.blue;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    _readingPassageController.dispose();
    super.dispose();
  }

  Future<void> _downloadTemplate() async {
    String assetPath;
    String fileName;

    switch (_selectedSkillType) {
      case 'LISTENING':
        assetPath = 'assets/templates/quiz_template_listening.xlsx';
        fileName = 'mau_listening.xlsx';
        break;
      case 'WRITING':
        assetPath = 'assets/templates/quiz_template_writing.xlsx';
        fileName = 'mau_writing.xlsx';
        break;
      case 'ESSAY':
        assetPath = 'assets/templates/writing_essay_template.xlsx';
        fileName = 'mau_writing_essay.xlsx';
        break;
      case 'READING':
      case 'GRAMMAR':
      default:
        assetPath = 'assets/templates/quiz_template_reading.xlsx';
        fileName = 'mau_reading_grammar.xlsx';
        break;
    }

    if (kIsWeb) {
      try {
        final ByteData data = await rootBundle.load(assetPath);
        final List<int> bytes = data.buffer.asUint8List();
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } catch (e) {
        ToastHelper.showError('Lỗi tải mẫu: $e');
      }
    } else {
      ToastHelper.showError('Tính năng tải mẫu chỉ hỗ trợ trên Web');
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      debugPrint('Lỗi pick file: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null) {
      ToastHelper.showError('Vui lòng tải lên file Excel câu hỏi');
      return;
    }

    setState(() => _isCreating = true);

    final viewModel = context.read<ManageQuizViewModel>();

    final success = await viewModel.createQuiz(
      courseId: widget.courseId,
      title: _titleController.text,
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      timeLimitMinutes: int.parse(_timeLimitController.text),
      platformFile: _selectedFile!,
      skillType: _selectedSkillType,
      readingPassage:
          _selectedSkillType == 'READING'
              ? _readingPassageController.text
              : null,
    );

    if (!mounted) return;
    setState(() => _isCreating = false);

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: const BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_task_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Tạo Bài Tập Mới',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSectionTitle('1. Thông tin chung'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _titleController,
                        label: 'Tiêu đề bài tập',
                        hint: 'VD: Unit 1 Listening',
                        icon: Icons.title,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        controller: _timeLimitController,
                        label: 'Thời gian (phút)',
                        hint: '0 = Không GH',
                        icon: Icons.timer,
                        isNumber: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Bắt buộc';
                          if (int.tryParse(v) == null) return 'Sai số';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Mô tả (Tùy chọn)',
                  hint: 'Hướng dẫn làm bài...',
                  icon: Icons.description_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('2. Cấu hình nội dung'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedSkillType,
                  decoration: InputDecoration(
                    labelText: 'Loại kỹ năng',
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      color: primaryBlue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'READING',
                      child: Text('Reading (Đọc hiểu đoạn văn)'),
                    ),
                    DropdownMenuItem(
                      value: 'GRAMMAR',
                      child: Text('Grammar (Ngữ pháp / Từ vựng)'),
                    ),
                    DropdownMenuItem(
                      value: 'LISTENING',
                      child: Text('Listening (Nghe)'),
                    ),
                    DropdownMenuItem(
                      value: 'WRITING',
                      child: Text('Writing (Viết / Điền từ)'),
                    ),
                    DropdownMenuItem(
                      value: 'ESSAY',
                      child: Text('Writing Essay (Viết luận - AI Chấm)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null)
                      setState(() => _selectedSkillType = value);
                  },
                ),
                if (_selectedSkillType == 'READING') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _readingPassageController,
                    label: 'Đoạn văn (Reading Passage)',
                    hint: 'Dán đoạn văn vào đây...',
                    icon: Icons.article_outlined,
                    maxLines: 5,
                  ),
                ],
                const SizedBox(height: 24),
                _buildSectionTitle('3. Ngân hàng câu hỏi'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _downloadTemplate,
                              icon: const Icon(
                                Icons.download_rounded,
                                size: 18,
                              ),
                              label: const Text('Tải file mẫu Excel'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Chọn file tải lên'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Đã chọn: ${_selectedFile!.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 18,
                              ),
                              onPressed:
                                  () => setState(() => _selectedFile = null),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
          child: const Text('Hủy bỏ'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isCreating ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              _isCreating
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text('Tạo bài tập'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryBlue,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            icon != null
                ? Icon(icon, color: Colors.grey.shade600, size: 22)
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }
}
