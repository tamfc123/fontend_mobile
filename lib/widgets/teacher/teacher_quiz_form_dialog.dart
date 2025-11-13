// import 'dart:io'; // 👈 [XÓA] Dòng này không cần thiết cho web và gây lỗi
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
// 🔹 Giả sử tên class trong file này là QuizService
import 'package:mobile/services/teacher/teacher_quiz_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile/dart_helpers/html_helper.dart'
    if (dart.library.html) 'dart:html'
    as html;

class TeacherQuizFormDialog extends StatefulWidget {
  final int classId;
  const TeacherQuizFormDialog({super.key, required this.classId});

  @override
  State<TeacherQuizFormDialog> createState() => _TeacherQuizFormDialogState();
}

class _TeacherQuizFormDialogState extends State<TeacherQuizFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeLimitController = TextEditingController();

  // ✅ 1. THÊM STATE MỚI
  final _readingPassageController = TextEditingController(); // Cho đoạn văn
  String _selectedSkillType = 'READING'; // Giá trị mặc định

  PlatformFile? _selectedFile; // File Excel đã chọn
  bool _isCreating = false; // Trạng thái đang gọi API

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    _readingPassageController.dispose(); // ✅ Nhớ dispose controller mới
    super.dispose();
  }

  // ✅ 2. CẬP NHẬT HÀM TẢI FILE MẪU (Rất quan trọng)
  Future<void> _downloadTemplate() async {
    // ❗️ LƯU Ý: Bạn cần tạo 3 file mẫu này và thêm vào assets
    // assets/templates/quiz_template_reading.xlsx
    // assets/templates/quiz_template_listening.xlsx
    // assets/templates/quiz_template_writing.xlsx

    String assetPath;
    String fileName;

    // Lấy đúng file mẫu dựa trên kỹ năng đã chọn
    switch (_selectedSkillType) {
      case 'LISTENING':
        assetPath = 'assets/templates/quiz_template_listening.xlsx';
        fileName = 'quiz_template_listening.xlsx';
        break;
      case 'WRITING':
        assetPath = 'assets/templates/quiz_template_writing.xlsx';
        fileName = 'quiz_template_writing.xlsx';
        break;
      case 'READING':
      default:
        assetPath = 'assets/templates/quiz_template_reading.xlsx';
        fileName = 'quiz_template_reading.xlsx';
        break;
    }

    if (kIsWeb) {
      try {
        final ByteData data = await rootBundle.load(
          assetPath,
        ); // 👈 Dùng path động
        final List<int> bytes = data.buffer.asUint8List();

        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute("download", fileName) // 👈 Dùng tên file động
              ..click();

        html.Url.revokeObjectUrl(url);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi tải file mẫu: $e')));
        }
      }
    } else {
      // (Bỏ qua logic cho mobile/desktop)
    }
  }

  Future<void> _pickFile() async {
    // (Hàm này giữ nguyên, không cần sửa)
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
      // ... (xử lý lỗi)
    }
  }

  // ✅ 3. CẬP NHẬT HÀM SUBMIT
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn file Excel .xlsx')),
        );
        return;
      }

      setState(() => _isCreating = true);

      final quizService = context.read<QuizService>();

      // ✅ Gọi hàm createQuiz đã được nâng cấp
      final success = await quizService.createQuiz(
        classId: widget.classId,
        title: _titleController.text,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        timeLimitMinutes: int.parse(_timeLimitController.text),
        platformFile: _selectedFile!,

        // ✅ TRUYỀN CÁC TRƯỜNG MỚI
        skillType: _selectedSkillType,
        readingPassage:
            _selectedSkillType == 'READING'
                ? _readingPassageController
                    .text // Chỉ gửi nếu là bài Reading
                : null,
      );

      if (!mounted) return;
      setState(() => _isCreating = false);

      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo bài tập mới'),
      content: Form(
        key: _formKey,
        // ✅ 4. CẬP NHẬT UI
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (không bắt buộc)',
                ),
              ),
              TextFormField(
                controller: _timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'Thời gian (phút)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  // ... (validator giữ nguyên)
                  if (value == null || value.isEmpty)
                    return 'Không được để trống';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Phải là số phút hợp lệ';
                  }
                  return null;
                },
              ),

              // ✅ THÊM MỚI: CHỌN LOẠI KỸ NĂNG
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSkillType,
                decoration: const InputDecoration(
                  labelText: 'Loại kỹ năng',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'READING',
                    child: Text('📖 Đọc / Ngữ pháp'),
                  ),
                  DropdownMenuItem(value: 'LISTENING', child: Text('🎧 Nghe')),
                  DropdownMenuItem(
                    value: 'WRITING',
                    child: Text('✍️ Viết (Điền từ)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSkillType = value;
                    });
                  }
                },
              ),

              // ✅ THÊM MỚI: HIỂN THỊ CÓ ĐIỀU KIỆN
              // (Chỉ hiển thị ô này nếu là bài Đọc)
              if (_selectedSkillType == 'READING') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _readingPassageController,
                  decoration: const InputDecoration(
                    labelText: 'Đoạn văn (Reading Passage)',
                    hintText: 'Dán đoạn văn vào đây (nếu có)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ],

              const SizedBox(height: 20),

              // ✅ SỬA LẠI TEXT CỦA NÚT TẢI
              TextButton.icon(
                icon: const Icon(Icons.download, color: Colors.blue),
                label: Text(
                  // Text động dựa trên kỹ năng
                  'Tải mẫu Excel (${_selectedSkillType.toLowerCase()})',
                  style: const TextStyle(color: Colors.blue),
                ),
                onPressed: _downloadTemplate,
              ),

              const SizedBox(height: 10),
              // --- Nút chọn File ---
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Chọn file (.xlsx)'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedFile == null
                          ? 'Chưa chọn file'
                          : _selectedFile!.name,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_isCreating)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
        else ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(onPressed: _submit, child: const Text('Tạo')),
        ],
      ],
    );
  }
}
