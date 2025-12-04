import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/student_detail_model.dart';
import 'package:mobile/screens/teacher/manage_class/teacher_class_view_model.dart';
import 'package:provider/provider.dart';

class StudentInfoDialog extends StatelessWidget {
  final String classId;
  final String studentId;

  const StudentInfoDialog({
    super.key,
    required this.classId,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    // Gọi API
    final future = context.read<TeacherClassViewModel>().fetchStudentDetail(
      classId,
      studentId,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        // Chiều cao cố định hoặc dynamic
        height: 500,
        width: 400,
        child: FutureBuilder<StudentDetailModel?>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                height: 200,
                child: const Text("Không tải được thông tin"),
              );
            }

            final user = snapshot.data!;

            // ✅ SỬ DỤNG STACK ĐỂ AVATAR NỔI LÊN TRÊN
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // 1. NỀN TRẮNG (CONTENT) - Nằm dưới, cách top một đoạn
                Container(
                  margin: const EdgeInsets.only(top: 60), // Chừa chỗ cho Avatar
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 60), // Khoảng trống cho Avatar
                      // NAME & EMAIL
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // STATS ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            "Level",
                            "${user.level}",
                            Colors.orange,
                          ),
                          _buildStatItem("EXP", "${user.exp}", Colors.blue),
                          _buildStatItem(
                            "Streak",
                            "${user.streak}🔥",
                            Colors.red,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1, indent: 20, endIndent: 20),

                      // INFO LIST (Cuộn được nếu dài)
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.phone,
                                "Số điện thoại",
                                user.phoneNumber ?? "Chưa cập nhật",
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.cake,
                                "Ngày sinh",
                                user.birthday != null
                                    ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(user.birthday!)
                                    : "Chưa cập nhật",
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.calendar_today,
                                "Ngày vào lớp",
                                DateFormat('dd/MM/yyyy').format(user.joinedAt),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. HEADER MÀU XANH (Nằm dưới Avatar nhưng trên nền trắng phần trên)
                // Ta dùng Container bo góc trên của nền trắng để làm header giả
                // Hoặc đơn giản là Avatar nằm đè lên viền

                // 3. AVATAR (Nằm trên cùng)
                Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade50,
                      backgroundImage:
                          user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                      child:
                          user.avatarUrl == null
                              ? Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B82F6),
                                ),
                              )
                              : null,
                    ),
                  ),
                ),

                // 4. NÚT ĐÓNG (Góc trên phải của Card trắng)
                Positioned(
                  top: 70,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
