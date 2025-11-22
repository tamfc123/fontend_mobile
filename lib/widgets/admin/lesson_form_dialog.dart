import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/domain/repositories/upload_repository.dart';
import 'package:mobile/services/admin/admin_lesson_service.dart';
import 'package:provider/provider.dart';

class LessonFormDialog extends StatefulWidget {
  final String? lessonId; // là null nếu THÊM, có giá trị nếu SỬA
  final String moduleId;

  const LessonFormDialog({super.key, this.lessonId, required this.moduleId});

  @override
  State<LessonFormDialog> createState() => _LessonFormDialogState();
}

class _LessonFormDialogState extends State<LessonFormDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  LessonModel? _fullLessonData;

  late TextEditingController _titleController;
  late TextEditingController _orderController; // ✅ Thêm controller cho Order
  late QuillController _quillController;

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  bool _isUploading = false; // (State upload ảnh của bạn đã đúng)

  @override
  void initState() {
    super.initState();

    // Khởi tạo controller rỗng
    _titleController = TextEditingController();
    _orderController = TextEditingController(); // Khởi tạo
    _initializeQuillController(); // Gọi hàm của bạn

    // ✅ 3. LOGIC TẢI DỮ LIỆU KHI SỬA
    if (widget.lessonId != null) {
      _loadLessonData();
    }
  }

  // ✅ 4. HÀM TẢI DỮ LIỆU MỚI
  Future<void> _loadLessonData() async {
    setState(() => _isLoading = true);
    try {
      final lesson = await context.read<AdminLessonService>().fetchLessonById(
        widget.lessonId!,
      );

      // Gán dữ liệu vào state
      _fullLessonData = lesson;

      // Gán dữ liệu vào controllers
      _titleController.text = lesson.title;
      _orderController.text = lesson.order.toString();

      // Gán nội dung cho Quill (lấy từ code cũ của bạn)
      if (lesson.content != null && lesson.content!.isNotEmpty) {
        try {
          final jsonContent = jsonDecode(lesson.content!);
          _quillController.document = Document.fromJson(jsonContent);
        } catch (e) {
          debugPrint('Load content error: $e');
        }
      }
    } catch (e) {
      // Nếu lỗi, đóng dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _initializeQuillController() {
    // (Toàn bộ logic config Quill của bạn giữ nguyên - Rất tốt)
    _quillController = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
          onImagePaste: (imageBytes) async {
            try {
              final filename =
                  'pasted_${DateTime.now().millisecondsSinceEpoch}.png';
              return await _uploadBytesAndGetUrl(imageBytes, filename);
            } catch (e) {
              debugPrint('Upload pasted image failed: $e');
              return null;
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose(); // ✅ dispose
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_isUploading) {
        _showError('Đang tải ảnh lên, vui lòng đợi...');
        return;
      }
      final title = _titleController.text;
      // ✅ 5. SỬA LẠI LOGIC LẤY ORDER
      final order =
          int.tryParse(_orderController.text) ??
          _fullLessonData?.order ?? // Lấy order cũ (nếu đang sửa)
          0; // Mặc định là 0 (nếu đang thêm)

      final jsonContent = jsonEncode(
        _quillController.document.toDelta().toJson(),
      );

      final result = LessonModifyModel(
        moduleId: widget.moduleId,
        title: title,
        order: order,
        // (Nếu Content rỗng, gửi '[]' để DB biết là đã lưu)
        content: _quillController.document.isEmpty() ? '[]' : jsonContent,
      );
      Navigator.of(context).pop(result);
    }
  }

  // (Các hàm _uploadBytesAndGetUrl, _onImageInsert, _showError, _insertImage của bạn giữ nguyên)
  Future<String?> _uploadBytesAndGetUrl(
    Uint8List bytes,
    String filename,
  ) async {
    final uploadRepository = Provider.of<UploadRepository?>(
      context,
      listen: false,
    );
    if (uploadRepository == null) {
      throw Exception('UploadRepository chưa được cung cấp.');
    }
    final response = await uploadRepository.uploadFileWeb(bytes, filename);
    return response?.url?.isNotEmpty == true ? response!.url : null;
  }

  Future<String?> _onImageInsert(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (imageFile == null) return null;

    setState(() => _isUploading = true);
    try {
      final bytes = await imageFile.readAsBytes();
      final url = await _uploadBytesAndGetUrl(bytes, imageFile.name);
      if (url != null && url.startsWith('http')) {
        return url; // ← Trả về URL
      } else {
        _showError('Upload thất bại');
        return null;
      }
    } catch (e) {
      _showError('Lỗi chi tiết: $e');
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _insertImage(String imageUrl) {
    final index = _quillController.selection.baseOffset;
    final length = _quillController.selection.extentOffset - index;
    final safeIndex = (index >= 0) ? index : _quillController.document.length;

    _quillController.replaceText(
      safeIndex,
      length,
      BlockEmbed.image(imageUrl),
      null,
    );
    _quillController.updateSelection(
      TextSelection.collapsed(offset: safeIndex + 1),
      ChangeSource.local,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // ✅ 6. SỬA LẠI CHECK
      title: Text(
        widget.lessonId == null ? 'Tạo Bài học mới' : 'Cập nhật Bài học',
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        // ✅ 7. THÊM CHECK LOADING
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tiêu đề
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tên Bài học',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Vui lòng nhập tên bài học'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // ✅ 8. THÊM LẠI Ô NHẬP ORDER
                      TextFormField(
                        controller: _orderController,
                        decoration: const InputDecoration(
                          labelText: 'Thứ tự (Order)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập thứ tự';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Vui lòng nhập số';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quill Editor + Toolbar (Code của bạn giữ nguyên)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          QuillSimpleToolbar(
                                            controller: _quillController,
                                            config: QuillSimpleToolbarConfig(
                                              embedButtons: [],
                                              showClipboardPaste: true,
                                              showAlignmentButtons: true,
                                              customButtons: [
                                                QuillToolbarCustomButtonOptions(
                                                  icon: const Icon(
                                                    Icons.image,
                                                    size: 20,
                                                  ),
                                                  onPressed: () async {
                                                    final url =
                                                        await _onImageInsert(
                                                          context,
                                                        );
                                                    if (url != null)
                                                      _insertImage(url);
                                                  },
                                                ),
                                              ],
                                              buttonOptions:
                                                  const QuillSimpleToolbarButtonOptions(
                                                    base:
                                                        QuillToolbarBaseButtonOptions(),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: QuillEditor(
                                      focusNode: _editorFocusNode,
                                      scrollController: _editorScrollController,
                                      controller: _quillController,
                                      config: QuillEditorConfig(
                                        placeholder: 'Bắt đầu viết nội dung...',
                                        padding: const EdgeInsets.all(8),
                                        embedBuilders: [
                                          ...FlutterQuillEmbeds.editorBuilders(
                                            imageEmbedConfig:
                                                QuillEditorImageEmbedConfig(
                                                  imageProviderBuilder: (
                                                    context,
                                                    imageUrl,
                                                  ) {
                                                    if (imageUrl.startsWith(
                                                      'assets/',
                                                    )) {
                                                      return AssetImage(
                                                        imageUrl,
                                                      );
                                                    }
                                                    return null;
                                                  },
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_isUploading)
                                Container(
                                  alignment: Alignment.center,
                                  color: Colors.white.withOpacity(0.7),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 12),
                                      Text(
                                        'Đang tải ảnh...',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
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
          // ✅ 9. SỬA LẠI CHECK
          child: Text(widget.lessonId == null ? 'Tạo mới' : 'Cập nhật'),
        ),
      ],
    );
  }
}
