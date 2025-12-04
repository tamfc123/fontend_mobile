import 'package:flutter/material.dart';
import 'package:mobile/data/models/student_class_model.dart';

class ClassCard extends StatelessWidget {
  final StudentClassModel classModel;
  final Map<String, dynamic>
  levelConfig; // Giữ lại nếu bạn muốn dùng màu theo level, hoặc bỏ qua để dùng màu xanh chủ đạo
  final VoidCallback onLeave;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.classModel,
    required this.levelConfig, // Có thể dùng để tô màu icon nếu muốn
    required this.onLeave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Màu chủ đạo Blue & White
    const Color primaryBlue = Color(0xFF3B82F6);
    const Color textDark = Color(0xFF1E293B);
    const Color textGrey = Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- PHẦN TRÊN: ICON & TÊN LỚP & NÚT RỜI ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Icon Lớp (Bo tròn, nền xanh nhạt)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons
                            .school_rounded, // Hoặc dùng levelConfig['icon'] nếu muốn đa dạng
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 2. Thông tin chính
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tên lớp
                          Text(
                            classModel.className,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Chip Môn học (Course Name)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9), // Slate 100
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              classModel.courseName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: textGrey,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Nút Rời lớp (Góc trên phải)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onLeave,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // --- ĐƯỜNG KẺ NGĂN CÁCH ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: Colors.grey.shade100),
                ),

                // --- PHẦN DƯỚI: GIẢNG VIÊN & NÚT VÀO ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Giảng viên
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey.shade100,
                          child: const Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          classModel.teacherName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textGrey,
                          ),
                        ),
                      ],
                    ),

                    // Nút "Vào lớp" (CTA)
                    Row(
                      children: [
                        const Text(
                          'Vào lớp',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
