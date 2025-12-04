import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/domain/repositories/common/upload_repository.dart';
import 'package:mobile/screens/admin/manage_lesson/manage_lesson_view_model.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class LessonFormDialog extends StatefulWidget {
  final String? lessonId;
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
  late TextEditingController _orderController;
  late QuillController _quillController;

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _orderController = TextEditingController();
    _initializeQuillController();

    if (widget.lessonId != null) {
      _loadLessonData();
    }
  }

  Future<void> _loadLessonData() async {
    setState(() => _isLoading = true);
    try {
      final viewModel = context.read<ManageLessonViewModel>();
      final lesson = await viewModel.fetchLessonById(widget.lessonId!);

      if (lesson != null) {
        _fullLessonData = lesson;
        _titleController.text = lesson.title;
        _orderController.text = lesson.order.toString();

        if (lesson.content != null && lesson.content!.isNotEmpty) {
          try {
            final jsonContent = jsonDecode(lesson.content!);
            _quillController.document = Document.fromJson(jsonContent);
          } catch (e) {
            debugPrint('Load content error: $e');
          }
        }
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initializeQuillController() {
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
    _orderController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_isUploading) {
        ToastHelper.showError('Đang tải ảnh lên, vui lòng đợi...');
        return;
      }

      setState(() => _isLoading = true);

      try {
        final title = _titleController.text;
        final order =
            int.tryParse(_orderController.text) ?? _fullLessonData?.order ?? 0;

        final jsonContent = jsonEncode(
          _quillController.document.toDelta().toJson(),
        );

        final lessonDto = LessonModifyModel(
          moduleId: widget.moduleId,
          title: title,
          order: order,
          content: _quillController.document.isEmpty() ? '[]' : jsonContent,
        );

        final viewModel = context.read<ManageLessonViewModel>();
        bool success;

        if (widget.lessonId == null) {
          success = await viewModel.createLesson(lessonDto);
        } else {
          success = await viewModel.updateLesson(widget.lessonId!, lessonDto);
        }

        if (success && mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        ToastHelper.showError('Lỗi: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
        return url;
      } else {
        ToastHelper.showError('Upload thất bại');
        return null;
      }
    } catch (e) {
      ToastHelper.showError('Lỗi chi tiết: $e');
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
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
      title: Text(
        widget.lessonId == null ? 'Tạo Bài học mới' : 'Cập nhật Bài học',
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                                    if (url != null) {
                                                      _insertImage(url);
                                                    }
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
                                  color: Colors.white.withValues(alpha: 0.7),
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
          onPressed: _isLoading ? null : _submit,
          child: Text(widget.lessonId == null ? 'Tạo mới' : 'Cập nhật'),
        ),
      ],
    );
  }
}
