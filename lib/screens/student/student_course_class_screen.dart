import 'package:flutter/material.dart';
import 'package:mobile/data/models/course_model.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/services/student/student_class_service.dart';
import 'package:mobile/services/student/student_course_class_service.dart';
import 'package:mobile/utils/color_helper.dart';
import 'package:mobile/utils/toast_helper.dart'; // ✅ Import ToastHelper
import 'package:mobile/widgets/student/confirm_join_class_dialog.dart'; // ✅ Import Dialog mới
import 'package:provider/provider.dart';
import 'dart:math' as math;

class CourseClassesScreen extends StatefulWidget {
  final CourseModel course;

  const CourseClassesScreen({super.key, required this.course});

  @override
  State<CourseClassesScreen> createState() => _CourseClassesScreenState();
}

class _CourseClassesScreenState extends State<CourseClassesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StudentCourseClassService>().fetchClasses(widget.course.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseClassService = context.watch<StudentCourseClassService>();
    final colorHelper = ColorHelper();
    final levelConfig = colorHelper.getLevelConfig(widget.course.requiredLevel);
    final levelColor = levelConfig['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chọn lớp học",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // --- HEADER THÔNG TIN KHÓA HỌC (Giữ nguyên) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  levelColor.withValues(alpha: 0.15),
                  levelColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'course_icon_${widget.course.id}',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: levelColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          levelConfig['icon'] as IconData,
                          color: levelColor,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.course.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: levelColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: levelColor.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: levelColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Yêu cầu Level ${widget.course.requiredLevel}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: levelColor,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildCourseStatChip(
                      icon: Icons.access_time_rounded,
                      label: '${widget.course.durationInWeeks} tuần',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildCourseStatChip(
                      icon: Icons.monetization_on_rounded,
                      label: '${widget.course.rewardCoins} xu',
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    _buildCourseStatChip(
                      icon: Icons.star_rounded,
                      label: '${widget.course.rewardExp} XP',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- DANH SÁCH LỚP ---
          Expanded(
            child: Builder(
              builder: (_) {
                if (courseClassService.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: levelColor),
                        const SizedBox(height: 16),
                        Text(
                          'Đang tải danh sách lớp...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (courseClassService.error != null) {
                  return _buildErrorState(courseClassService, levelColor);
                }

                if (courseClassService.classes.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Text(
                        '${courseClassService.classes.length} lớp học có sẵn',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await courseClassService.fetchClasses(
                            widget.course.id!,
                          );
                        },
                        color: levelColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: courseClassService.classes.length,
                          itemBuilder: (context, index) {
                            final cls = courseClassService.classes[index];

                            return _AnimatedListItem(
                              index: index,
                              child: _ClassCard(
                                classData: cls,
                                levelColor: levelColor,
                                onJoin: () async {
                                  // 1. Check khóa
                                  if (cls.isLocked) {
                                    // ✅ Sử dụng ToastHelper thay cho SnackBar
                                    ToastHelper.showError(
                                      "Bạn cần đạt Level ${cls.requiredLevel} để tham gia!",
                                    );
                                    return;
                                  }

                                  // 2. Hiện Dialog xác nhận (Custom Dialog)
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    // ✅ Sử dụng Widget Dialog mới tách ra
                                    builder:
                                        (context) => ConfirmJoinClassDialog(
                                          className: cls.className,
                                          levelColor: levelColor,
                                        ),
                                  );

                                  // 3. Xử lý nếu đồng ý
                                  if (confirmed == true) {
                                    final success = await context
                                        .read<StudentClassService>()
                                        .joinClass(cls.classId);

                                    if (success && context.mounted) {
                                      // Có thể pop về hoặc reload list tùy logic
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // (Các widget helper cũ giữ nguyên hoặc tách ra nếu muốn gọn file hơn)
  Widget _buildCourseStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(StudentCourseClassService service, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "Có lỗi xảy ra",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              service.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => service.fetchClasses(widget.course.id!),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Chưa có lớp học nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Các lớp học sẽ sớm được mở",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ... (Giữ nguyên _AnimatedListItem và _ClassCard, _ClassDetailsSheet từ code cũ nếu chưa tách) ...
// Để file gọn hơn, tôi khuyến khích bạn tách _ClassCard và _ClassDetailsSheet ra file riêng trong folder widgets/student/
// Nhưng nếu để chung thì copy lại các class đó ở dưới này (như phiên bản trước).

// ✅ ANIMATION WIDGET
class _AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedListItem({required this.index, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(padding: const EdgeInsets.only(bottom: 0), child: child),
    );
  }
}

// ✅ CLASS CARD
class _ClassCard extends StatefulWidget {
  final StudentClassModel classData;
  final Color levelColor;
  final VoidCallback onJoin;

  const _ClassCard({
    required this.classData,
    required this.levelColor,
    required this.onJoin,
  });

  @override
  State<_ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<_ClassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _shakeOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shakeCard() async {
    for (int i = 0; i < 3; i++) {
      setState(() => _shakeOffset = 5.0);
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() => _shakeOffset = -5.0);
      await Future.delayed(const Duration(milliseconds: 50));
    }
    setState(() => _shakeOffset = 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = widget.classData.isLocked;
    final Color cardColor = isLocked ? Colors.grey : widget.levelColor;
    final scale = 1.0 - _controller.value;

    return Transform.translate(
      offset: Offset(_shakeOffset, 0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              if (isLocked) _shakeCard();

              if (isLocked) {
                widget.onJoin();
              } else {
                Future.delayed(const Duration(milliseconds: 100), () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder:
                        (context) => _ClassDetailsSheet(
                          classData: widget.classData,
                          levelColor: cardColor,
                          onJoin: widget.onJoin,
                          isLocked: isLocked,
                        ),
                  );
                });
              }
            },
            onTapCancel: () => _controller.reverse(),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline : Icons.class_rounded,
                      color: cardColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.classData.className,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isLocked
                                    ? Colors.grey
                                    : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.classData.teacherName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Lv ${widget.classData.requiredLevel}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Icon(Icons.chevron_right, color: Colors.grey.shade300),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Class Details Bottom Sheet
class _ClassDetailsSheet extends StatelessWidget {
  final StudentClassModel classData;
  final Color levelColor;
  final VoidCallback onJoin;
  final bool isLocked;

  const _ClassDetailsSheet({
    required this.classData,
    required this.levelColor,
    required this.onJoin,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    // ... (Giữ nguyên nội dung BottomSheet như cũ, chỉ lưu ý chỗ nút bấm gọi onJoin)
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isLocked
                          ? Colors.grey.withValues(alpha: 0.1)
                          : levelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLocked ? Icons.lock : Icons.class_rounded,
                  color: isLocked ? Colors.grey : levelColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classData.className,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Giảng viên: ${classData.teacherName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLocked)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_clock, color: Colors.red.shade400, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lớp học này yêu cầu Level ${classData.requiredLevel}. Bạn chưa đủ điều kiện tham gia.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: levelColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sau khi tham gia, bạn sẽ có thể truy cập tất cả tài liệu và bài học của lớp.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Đóng'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      isLocked
                          ? null
                          : () {
                            Navigator.pop(context);
                            onJoin();
                          }, // ✅ Gọi onJoin ở đây
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked ? Colors.grey : levelColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLocked ? 'Bị khóa' : 'Tham gia ngay',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
