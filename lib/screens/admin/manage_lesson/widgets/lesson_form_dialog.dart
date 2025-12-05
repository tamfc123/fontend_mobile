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

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

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
    final isEditing = widget.lessonId != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.85,
        constraints: const BoxConstraints(maxWidth: 900),
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
                    isEditing ? Icons.edit : Icons.article,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEditing ? 'Cập nhật bài học' : 'Tạo bài học mới',
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
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: primaryBlue),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Title and Order Row
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _buildModernInputField(
                                      controller: _titleController,
                                      label: 'Tên bài học',
                                      hint: 'Nhập tên bài học...',
                                      icon: Icons.title,
                                      validator:
                                          (value) =>
                                              (value == null || value.isEmpty)
                                                  ? 'Vui lòng nhập tên bài học'
                                                  : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: _buildModernInputField(
                                      controller: _orderController,
                                      label: 'Thứ tự',
                                      hint: 'Số TT',
                                      icon: Icons.numbers,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nhập STT';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Phải là số';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Rich Text Editor Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nội dung bài học',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 400,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: surfaceBlue),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryBlue.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            // Toolbar
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: surfaceBlue,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    QuillSimpleToolbar(
                                                      controller:
                                                          _quillController,
                                                      config: QuillSimpleToolbarConfig(
                                                        embedButtons: [],
                                                        showClipboardPaste:
                                                            true,
                                                        showAlignmentButtons:
                                                            true,
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
                                                                _insertImage(
                                                                  url,
                                                                );
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
                                            // Editor
                                            Expanded(
                                              child: QuillEditor(
                                                focusNode: _editorFocusNode,
                                                scrollController:
                                                    _editorScrollController,
                                                controller: _quillController,
                                                config: QuillEditorConfig(
                                                  placeholder:
                                                      'Bắt đầu viết nội dung bài học...',
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  embedBuilders: [
                                                    ...FlutterQuillEmbeds.editorBuilders(
                                                      imageEmbedConfig:
                                                          QuillEditorImageEmbedConfig(
                                                            imageProviderBuilder: (
                                                              context,
                                                              imageUrl,
                                                            ) {
                                                              if (imageUrl
                                                                  .startsWith(
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
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const CircularProgressIndicator(
                                                  color: primaryBlue,
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Đang tải ảnh...',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
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
                      onPressed: _isLoading ? null : _submit,
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditing ? Icons.save : Icons.add,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEditing ? 'Lưu' : 'Tạo',
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
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
