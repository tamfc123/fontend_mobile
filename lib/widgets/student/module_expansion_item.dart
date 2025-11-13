// widgets/student/module_expansion_item.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:mobile/data/models/lesson_model.dart';
import 'package:mobile/data/models/module_model.dart';
import 'package:mobile/services/student/student_lesson_service.dart';
import 'package:provider/provider.dart';

class ModuleExpansionItem extends StatefulWidget {
  final ModuleModel module;
  final int index;

  const ModuleExpansionItem({
    super.key,
    required this.module,
    required this.index,
  });

  @override
  State<ModuleExpansionItem> createState() => _ModuleExpansionItemState();
}

class _ModuleExpansionItemState extends State<ModuleExpansionItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _hasFetchedLessons = false;

  // SỬA: Không dùng late → Khởi tạo trong initState
  AnimationController? _animationController;
  Animation<double>? _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonService = Provider.of<StudentLessonService>(
      context,
      listen: false,
    );
    final moduleId = widget.module.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // === TIÊU ĐỀ + NÚT MỞ RỘNG ===
            InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded) {
                    _animationController!.forward();
                  } else {
                    _animationController!.reverse();
                  }

                  if (_isExpanded && !_hasFetchedLessons) {
                    lessonService.fetchLessons(moduleId);
                    _hasFetchedLessons = true;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.module.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // === "XEM CHI TIẾT" + MŨI TÊN XOAY ===
                    AnimatedBuilder(
                      animation: _animationController!,
                      builder: (context, child) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isExpanded ? 'Ẩn bớt' : 'Xem chi tiết',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            RotationTransition(
                              turns: _rotateAnimation!,
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // === MÔ TẢ CHƯƠNG ===
            if (widget.module.description?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  widget.module.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // === NỘI DUNG MỞ RỘNG ===
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child:
                    _isExpanded
                        ? Container(
                          width: double.infinity,
                          color: Colors.grey.shade50,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Consumer<StudentLessonService>(
                            builder: (context, service, child) {
                              if (service.isLoading(moduleId)) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (service.error(moduleId) != null) {
                                return Center(
                                  child: Text(
                                    'Lỗi: ${service.error(moduleId)}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              final lessons = service.getLessons(moduleId);
                              if (lessons.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Chương này chưa có bài học.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }

                              return _buildLessonList(lessons);
                            },
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonList(List<LessonModel> lessons) {
    return Column(
      children:
          lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            final isLast = index == lessons.length - 1;

            return Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _QuillViewer(content: lesson.content),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

// === QUILL VIEWER RIÊNG ===
class _QuillViewer extends StatefulWidget {
  final String? content;
  const _QuillViewer({required this.content});

  @override
  State<_QuillViewer> createState() => _QuillViewerState();
}

class _QuillViewerState extends State<_QuillViewer> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: _loadDocument(),
      selection: const TextSelection.collapsed(offset: 0),
    )..readOnly = true;
  }

  Document _loadDocument() {
    if (widget.content == null || widget.content!.isEmpty) {
      return Document();
    }
    try {
      final decoded = jsonDecode(widget.content!);
      return Document.fromJson(decoded);
    } catch (e) {
      return Document()..insert(0, 'Nội dung lỗi định dạng.');
    }
  }

  @override
  void didUpdateWidget(covariant _QuillViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _controller.document = _loadDocument();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      controller: _controller,
      focusNode: FocusNode()..canRequestFocus = false,
      scrollController: ScrollController(),
      config: QuillEditorConfig(
        padding: EdgeInsets.zero,
        embedBuilders: [
          ...FlutterQuillEmbeds.editorBuilders(
            imageEmbedConfig: QuillEditorImageEmbedConfig(
              imageProviderBuilder: (context, imageUrl) {
                if (imageUrl.startsWith('http')) return NetworkImage(imageUrl);
                if (imageUrl.startsWith('assets/')) return AssetImage(imageUrl);
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
