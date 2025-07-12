// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../models/dashboard.dart';
import '../models/tenant.dart';

class DashboardScreen extends StatefulWidget {
  final Tenant tenant;

  const DashboardScreen({
    super.key,
    required this.tenant,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data with tenant ID
    context.read<DashboardBloc>().add(LoadDashboardData(widget.tenant.id!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tenant.name} Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardBloc>().add(LoadDashboardData(widget.tenant.id!)),
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            return _buildDashboardContent(state.dashboardData);
          } else if (state is DashboardOperationFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${state.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DashboardBloc>().add(LoadDashboardData(widget.tenant.id!)),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDashboardContent(DashboardData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewSection(data.overview),
          const SizedBox(height: 24),
          _buildStudentStatistics(data.studentStatistics),
          const SizedBox(height: 24),
          _buildStaffStatistics(data.staffStatistics),
          const SizedBox(height: 24),
          _buildExamStatistics(data.examStatistics),
          const SizedBox(height: 24),
          _buildAttendanceStatistics(data.attendanceStatistics),
          const SizedBox(height: 24),
          _buildComplaintStatistics(data.complaintStatistics),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(Overview overview) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard('Total Students', overview.totalStudents.toString(), Icons.school),
                _buildStatCard('Total Staff', overview.totalStaff.toString(), Icons.people),
                _buildStatCard('Total Classes', overview.totalClasses.toString(), Icons.class_),
                _buildStatCard('Total Subjects', overview.totalSubjects.toString(), Icons.subject),
                _buildStatCard('Upcoming Exams', overview.upcomingExams.toString(), Icons.quiz),
                _buildStatCard('Total Complaints', overview.totalComplaints.toString(), Icons.report),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentStatistics(StudentStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Total Students: ${stats.totalStudents}'),
            const SizedBox(height: 12),
            const Text('Students by Class:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...stats.studentsByClass.map((classData) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Class ${classData.className}-${classData.sectionName}'),
                  Text('${classData.studentCount} students'),
                ],
              ),
            )),
            if (stats.recentEnrollments.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Recent Enrollments:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...stats.recentEnrollments.take(3).map((enrollment) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(enrollment.studentName)),
                    Text('Class ${enrollment.className}-${enrollment.sectionName}'),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStaffStatistics(StaffStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Staff Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Total Staff: ${stats.totalStaff}'),
            const SizedBox(height: 12),
            const Text('Staff by Role:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...stats.staffByRole.map((roleData) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(roleData.role),
                  Text('${roleData.count} staff'),
                ],
              ),
            )),
            const SizedBox(height: 12),
            Text('Class Teachers: ${stats.classTeachers}'),
            Text('Subject Teachers: ${stats.subjectTeachers}'),
          ],
        ),
      ),
    );
  }

  Widget _buildExamStatistics(ExamStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exam Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Exams: ${stats.totalExams}'),
                Text('Upcoming: ${stats.upcomingExams}'),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Exams by Subject:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...stats.examsBySubject.map((subjectData) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(subjectData.subjectName),
                  Text('${subjectData.examCount} exams'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatistics(AttendanceStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Today: ${stats.todayAttendanceRate.toStringAsFixed(1)}%'),
                Text('Weekly: ${stats.weeklyAttendanceRate.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Monthly: ${stats.monthlyAttendanceRate.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintStatistics(ComplaintStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complaint Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ${stats.totalComplaints}'),
                Text('Pending: ${stats.pendingComplaints}'),
                Text('Resolved: ${stats.resolvedComplaints}'),
              ],
            ),
            if (stats.complaintsByCategory.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('By Category:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...stats.complaintsByCategory.map((categoryData) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(categoryData.category.toUpperCase()),
                    Text('${categoryData.count} complaints'),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}