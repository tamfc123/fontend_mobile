// file: widgets/admin/vocabulary_form_dialog.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/vocabulary_model.dart';
import 'package:mobile/domain/repositories/upload_repository.dart';
import 'package:mobile/utils/toast_helper.dart';
import 'package:provider/provider.dart';

class VocabularyFormDialog extends StatefulWidget {
  final VocabularyModel? vocab;
  final int lessonId;

  const VocabularyFormDialog({super.key, this.vocab, required this.lessonId});

  @override
  State<VocabularyFormDialog> createState() => _VocabularyFormDialogState();
}

class _VocabularyFormDialogState extends State<VocabularyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late TextEditingController _meaningController;
  late TextEditingController _phoneticController;
  late TextEditingController _audioUrlController;
  bool _isEdit = false;
  bool _isUploadingAudio = false;

  // MÀU CHỦ ĐẠO (ĐỒNG NHẤT VỚI ClassFormDialog)
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _isEdit = widget.vocab != null;
    _textController = TextEditingController(
      text: widget.vocab?.referenceText ?? '',
    );
    _meaningController = TextEditingController(
      text: widget.vocab?.meaning ?? '',
    );
    _phoneticController = TextEditingController(
      text: widget.vocab?.phonetic ?? '',
    );
    _audioUrlController = TextEditingController(
      text: widget.vocab?.sampleAudioUrl ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _meaningController.dispose();
    _phoneticController.dispose();
    _audioUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final result = VocabularyModifyModel(
        lessonId: widget.lessonId,
        referenceText: _textController.text.trim(),
        meaning: _meaningController.text.trim(),
        phonetic: _phoneticController.text.trim(),
        sampleAudioUrl: _audioUrlController.text.trim(),
      );
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _handleUploadAudio() async {
    setState(() => _isUploadingAudio = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'ogg'],
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        final uploadRepo = context.read<UploadRepository>();
        final response = await uploadRepo.uploadAudioFileWeb(
          file.bytes!,
          file.name,
        );

        if (response?.url != null) {
          setState(() => _audioUrlController.text = response!.url!);
          if (mounted) {
            ToastHelper.showSucess('Tải lên thành công!');
          }
        } else {
          throw Exception('Không nhận được URL');
        }
      }
    } catch (e) {
      if (mounted) {
        print('e: $e');
        ToastHelper.showError('Lỗi: $e');
      }
    } finally {
      setState(() => _isUploadingAudio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: backgroundBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // === HEADER GRADIENT ===
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
                      _isEdit ? Icons.edit : Icons.add_circle,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEdit ? 'Cập nhật Từ vựng' : 'Thêm Từ vựng mới',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // === FORM CONTENT ===
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildModernInputField(
                        controller: _textController,
                        label: 'Từ vựng',
                        hint: 'Nhập từ vựng...',
                        icon: Icons.text_fields,
                        validator:
                            (v) =>
                                v?.trim().isEmpty == true
                                    ? 'Vui lòng nhập từ vựng'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      _buildModernInputField(
                        controller: _meaningController,
                        label: 'Nghĩa',
                        hint: 'Nhập nghĩa...',
                        icon: Icons.translate,
                      ),
                      const SizedBox(height: 20),
                      _buildModernInputField(
                        controller: _phoneticController,
                        label: 'Phiên âm',
                        hint: 'Ví dụ: /həˈloʊ/',
                        icon: Icons.record_voice_over,
                      ),
                      const SizedBox(height: 20),
                      _buildAudioField(),
                    ],
                  ),
                ),
              ),

              // === ACTIONS ===
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryBlue.withOpacity(0.5)),
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
                        onPressed: _submit,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isEdit ? Icons.save : Icons.add, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _isEdit ? 'Lưu' : 'Thêm',
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

  // === INPUT FIELD ===
  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
                color: primaryBlue.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
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
            validator: validator,
          ),
        ),
      ],
    );
  }

  // === AUDIO FIELD ===
  Widget _buildAudioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Audio',
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
            border: Border.all(
              color:
                  _audioUrlController.text.isNotEmpty
                      ? Colors.green.shade400
                      : surfaceBlue,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _audioUrlController,
            readOnly: true,
            decoration: InputDecoration(
              hintText:
                  _audioUrlController.text.isEmpty
                      ? 'Chưa chọn file'
                      : 'Đã chọn file',
              hintStyle: TextStyle(
                color:
                    _audioUrlController.text.isEmpty
                        ? Colors.grey[400]
                        : Colors.green.shade700,
              ),
              prefixIcon: Icon(Icons.audiotrack, color: lightBlue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon:
                  _isUploadingAudio
                      ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryBlue,
                          ),
                        ),
                      )
                      : IconButton(
                        icon: Icon(
                          _audioUrlController.text.isNotEmpty
                              ? Icons.check_circle
                              : Icons.upload_file,
                          color:
                              _audioUrlController.text.isNotEmpty
                                  ? Colors.green.shade600
                                  : lightBlue,
                        ),
                        tooltip: 'Tải lên file âm thanh',
                        onPressed: _handleUploadAudio,
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
