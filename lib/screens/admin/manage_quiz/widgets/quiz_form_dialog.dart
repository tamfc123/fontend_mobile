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
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

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

    try {
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();

      if (kIsWeb) {
        // Web: Download using blob
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        ToastHelper.showSuccess('Đã tải file: $fileName');
      } else {
        // Mobile: Save to Downloads folder
        if (Platform.isAndroid) {
          // Request storage permission for Android
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
            if (!status.isGranted) {
              ToastHelper.showError('Cần quyền truy cập bộ nhớ để tải file');
              return;
            }
          }
        }

        // Get Downloads directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          ToastHelper.showSuccess('Đã lưu file vào: ${directory.path}');
        } else {
          ToastHelper.showError('Không thể truy cập thư mục Downloads');
        }
      }
    } catch (e) {
      ToastHelper.showError('Lỗi tải mẫu: $e');
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
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
                child: const Column(
                  children: [
                    Icon(Icons.quiz_outlined, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Tạo bài tập mới',
                      style: TextStyle(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('1. Thông tin chung'),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildModernInputField(
                              controller: _titleController,
                              label: 'Tiêu đề bài tập',
                              hint: 'VD: Unit 1 Listening',
                              icon: Icons.title,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Bắt buộc'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: _buildModernInputField(
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
                      _buildModernInputField(
                        controller: _descriptionController,
                        label: 'Mô tả (Tùy chọn)',
                        hint: 'Hướng dẫn làm bài...',
                        icon: Icons.description_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('2. Cấu hình nội dung'),
                      const SizedBox(height: 12),
                      _buildModernDropdown(),
                      if (_selectedSkillType == 'READING') ...[
                        const SizedBox(height: 16),
                        _buildModernInputField(
                          controller: _readingPassageController,
                          label: 'Đoạn văn (Reading Passage)',
                          hint: 'Dán đoạn văn vào đây...',
                          icon: Icons.article_outlined,
                          maxLines: 5,
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildSectionTitle('3. Ngân hàng câu hỏi'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: surfaceBlue),
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
                                    label: const Text('Tải file mẫu'),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: primaryBlue.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
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
                                    icon: const Icon(
                                      Icons.upload_file,
                                      size: 18,
                                    ),
                                    label: const Text('Chọn file'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
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
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: surfaceBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
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
                                          fontWeight: FontWeight.w600,
                                          color: primaryBlue,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed:
                                          () => setState(
                                            () => _selectedFile = null,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
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
                        onPressed:
                            _isCreating ? null : () => Navigator.pop(context),
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
                        onPressed: _isCreating ? null : _submit,
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
                                : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Tạo bài tập',
                                      style: TextStyle(
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: primaryBlue,
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
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
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: icon != null ? Icon(icon, color: lightBlue) : null,
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

  Widget _buildModernDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại kỹ năng',
          style: TextStyle(
            fontSize: 13,
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
          child: DropdownButtonFormField<String>(
            value: _selectedSkillType,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.category_outlined, color: lightBlue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'READING',
                child: Text('Reading - Đọc hiểu'),
              ),
              DropdownMenuItem(
                value: 'GRAMMAR',
                child: Text('Grammar - Ngữ pháp'),
              ),
              DropdownMenuItem(
                value: 'LISTENING',
                child: Text('Listening - Nghe'),
              ),
              DropdownMenuItem(value: 'WRITING', child: Text('Writing - Viết')),
              DropdownMenuItem(
                value: 'ESSAY',
                child: Text('Essay - Viết luận'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedSkillType = value);
              }
            },
          ),
        ),
      ],
    );
  }
}
