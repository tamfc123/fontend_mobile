import 'package:flutter/material.dart';
import 'package:mobile/widgets/student/scheduleStudent/student_schedule_card.dart';
import 'package:provider/provider.dart';
import 'package:mobile/services/student/student_schedule_service.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentScheduleService>().fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StudentScheduleService>();
    final schedules = service.schedules;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        title: const Text(
          'Lịch học',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // TODO: Implement search
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng tìm kiếm đang phát triển'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body:
          service.isLoading
              ? const Center(child: CircularProgressIndicator())
              : schedules.isEmpty
              ? const Center(child: Text('Không có lịch học.'))
              : ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final s = schedules[index];
                  return StudentScheduleCard(schedule: s);
                },
              ),
    );
  }
}
