import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart'; // ← CHO IMAGE EMBED
import 'package:image_picker/image_picker.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/domain/repositories/upload_repository.dart';
import 'package:provider/provider.dart';

class LessonFormDialog extends StatefulWidget {
  final LessonModel? lesson;
  final int moduleId;

  const LessonFormDialog({super.key, this.lesson, required this.moduleId});

  @override
  State<LessonFormDialog> createState() => _LessonFormDialogState();
}

class _LessonFormDialogState extends State<LessonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lesson?.title ?? '');
    _initializeQuillController();
  }

  void _initializeQuillController() {
    _quillController = QuillController.basic(
      config: QuillControllerConfig(
        // Xử lý paste ảnh từ clipboard
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
          onImagePaste: (imageBytes) async {
            // Trên web, nếu trả về null thì Quill có thể chèn blob:// URL
            // Thay vì trả về null, cố gắng upload bytes và trả về URL mạng
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

    if (widget.lesson != null && (widget.lesson!.content ?? '').isNotEmpty) {
      try {
        final jsonContent = jsonDecode(widget.lesson!.content!);
        _quillController.document = Document.fromJson(jsonContent);
      } catch (e) {
        debugPrint('Load content error: $e');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_isUploading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tải ảnh lên, vui lòng đợi...')),
        );
        return; // NGĂN NGƯỜI DÙNG ĐÓNG DIALOG
      }
      final title = _titleController.text;
      final order = widget.lesson?.order ?? 0;
      final jsonContent = jsonEncode(
        _quillController.document.toDelta().toJson(),
      );

      final result = LessonModifyModel(
        moduleId: widget.moduleId,
        title: title,
        order: order,
        content: jsonContent,
      );
      Navigator.of(context).pop(result);
    }
  }

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
    // imageUrl ở đây là: https://res.cloudinary.com/... (từ API)
    final index = _quillController.selection.baseOffset;
    final length = _quillController.selection.extentOffset - index;
    final safeIndex = (index >= 0) ? index : _quillController.document.length;

    // DÙNG replaceText → CHUẨN VÀ KÍCH HOẠT REBUILD
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
      title: Text(
        widget.lesson == null ? 'Tạo Bài học mới' : 'Cập nhật Bài học',
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Form(
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

              // Quill Editor + Toolbar
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
                          // Toolbar – THEO EXAMPLE
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
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
                                      // Không dùng nút embed mặc định (mặc định sẽ chèn blob:// trên web)
                                      // Thay vào đó dùng custom button bên dưới để upload trước rồi insert URL
                                      embedButtons: [],
                                      showClipboardPaste: true,
                                      customButtons: [
                                        QuillToolbarCustomButtonOptions(
                                          icon: const Icon(
                                            Icons.image,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            final url = await _onImageInsert(
                                              context,
                                            );
                                            if (url != null) _insertImage(url);
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

                          // Editor – THEO EXAMPLE
                          Expanded(
                            child: QuillEditor(
                              focusNode: _editorFocusNode,
                              scrollController: _editorScrollController,
                              controller: _quillController,
                              config: QuillEditorConfig(
                                placeholder: 'Bắt đầu viết nội dung...',
                                padding: const EdgeInsets.all(8),

                                embedBuilders: [
                                  // Image embed – THEO EXAMPLE
                                  ...FlutterQuillEmbeds.editorBuilders(
                                    imageEmbedConfig: QuillEditorImageEmbedConfig(
                                      imageProviderBuilder: (
                                        context,
                                        imageUrl,
                                      ) {
                                        // Nếu là asset, dùng AssetImage; còn lại NetworkImage
                                        if (imageUrl.startsWith('assets/')) {
                                          return AssetImage(imageUrl);
                                        }
                                        return null; // Sẽ dùng NetworkImage mặc định
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Loading overlay
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
          child: Text(widget.lesson == null ? 'Tạo mới' : 'Cập nhật'),
        ),
      ],
    );
  }
}
