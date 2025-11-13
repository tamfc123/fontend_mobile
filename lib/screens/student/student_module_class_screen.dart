import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/student_class_model.dart';
import 'package:mobile/services/student/student_module_service.dart';
import 'package:mobile/widgets/student/module_expansion_item.dart';
import 'package:provider/provider.dart';

class StudentClassDetailScreen extends StatefulWidget {
  final StudentClassModel studentClassModel;

  const StudentClassDetailScreen({super.key, required this.studentClassModel});

  @override
  State<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StudentModuleService>().fetchModules(
        widget.studentClassModel.classId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentModuleService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        title: Text(
          'Lớp: ${widget.studentClassModel.className}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // context.pushNamed(
                      //   'student_attendance',
                      //   extra: widget.studentClassModel,
                      // );
                    },
                    icon: Icon(
                      Icons.how_to_reg_outlined,
                      color: Colors.green.shade600,
                    ),
                    label: Text(
                      'Điểm danh',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.green.shade600,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.pushNamed(
                        'student-quiz-list',
                        extra: widget.studentClassModel,
                      );
                    },
                    icon: Icon(
                      Icons.assignment_outlined,
                      color: Colors.blue.shade600,
                    ),
                    label: Text(
                      'Bài tập',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.blue.shade600,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: _buildBody(service)),
        ],
      ),
    );
  }

  Widget _buildBody(StudentModuleService service) {
    if (service.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (service.error != null) {
      return Center(
        child: Text(
          'Lỗi: ${service.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (service.modules.isEmpty) {
      return const Center(
        child: Text('Chưa có nội dung nào trong lớp học này.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: service.modules.length, // Dùng itemCount
      itemBuilder: (context, index) {
        // Dùng itemBuilder
        final module = service.modules[index];

        // GỌI WIDGET MỚI (ExpansionTile)
        return ModuleExpansionItem(module: module, index: index);
      },
    );
  }
}
