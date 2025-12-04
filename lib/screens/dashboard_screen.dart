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
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          '${widget.tenant.name} Dashboard',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(data.overview),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(Overview overview) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B88F0), Color(0xFF6FC8FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.dashboard_customize, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Your organization at a glance',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dashboard Overview',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Chip(
                backgroundColor: Colors.white,
                label: Text(
                  'Total ${overview.totalStudents + overview.totalStaff}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F5AD5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildHeroTile(
                  title: 'Students',
                  value: overview.totalStudents.toString(),
                  icon: Icons.school,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeroTile(
                  title: 'Staff',
                  value: overview.totalStaff.toString(),
                  icon: Icons.badge,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeroTile(
                  title: 'Classes',
                  value: overview.totalClasses.toString(),
                  icon: Icons.class_,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.28),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(Overview overview) {
    return _SectionCard(
      title: 'Overview',
      subtitle: 'Key metrics from across your school',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildStatCard('Total Students', overview.totalStudents.toString(), Icons.school, Colors.indigo),
          _buildStatCard('Total Staff', overview.totalStaff.toString(), Icons.people, Colors.teal),
          _buildStatCard('Total Classes', overview.totalClasses.toString(), Icons.class_, Colors.deepPurple),
          _buildStatCard('Total Subjects', overview.totalSubjects.toString(), Icons.subject, Colors.orange),
          _buildStatCard('Upcoming Exams', overview.upcomingExams.toString(), Icons.quiz, Colors.blue),
          _buildStatCard('Total Complaints', overview.totalComplaints.toString(), Icons.report, Colors.pink),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentStatistics(StudentStatistics stats) {
    return _SectionCard(
      title: 'Student Statistics',
      subtitle: 'Keep an eye on enrollment and class distribution',
      action: Chip(
        backgroundColor: Colors.indigo.withOpacity(0.12),
        label: Text(
          '${stats.totalStudents} total',
          style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Students by Class', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...stats.studentsByClass.map(
            (classData) => _LabeledStatRow(
              label: 'Class ${classData.className}-${classData.sectionName}',
              value: '${classData.studentCount} students',
            ),
          ),
          if (stats.recentEnrollments.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Recent Enrollments', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...stats.recentEnrollments.take(3).map(
              (enrollment) => _LabeledStatRow(
                label: enrollment.studentName,
                value: 'Class ${enrollment.className}-${enrollment.sectionName}',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStaffStatistics(StaffStatistics stats) {
    return _SectionCard(
      title: 'Staff Statistics',
      subtitle: 'Breakdown by roles and teaching duties',
      action: Chip(
        backgroundColor: Colors.teal.withOpacity(0.12),
        label: Text(
          '${stats.totalStaff} total',
          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Staff by Role', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...stats.staffByRole.map(
            (roleData) => _LabeledStatRow(
              label: roleData.role,
              value: '${roleData.count} staff',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniPill(label: 'Class Teachers', value: stats.classTeachers.toString(), color: Colors.deepPurple),
              const SizedBox(width: 10),
              _MiniPill(label: 'Subject Teachers', value: stats.subjectTeachers.toString(), color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamStatistics(ExamStatistics stats) {
    return _SectionCard(
      title: 'Exam Statistics',
      subtitle: 'Track progress across upcoming and completed exams',
      action: Chip(
        backgroundColor: Colors.orange.withOpacity(0.12),
        label: Text(
          '${stats.upcomingExams} upcoming',
          style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniPill(label: 'Total Exams', value: stats.totalExams.toString(), color: Colors.orange),
              _MiniPill(label: 'Upcoming', value: stats.upcomingExams.toString(), color: Colors.deepOrange),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Exams by Subject', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...stats.examsBySubject.map(
            (subjectData) => _LabeledStatRow(
              label: subjectData.subjectName,
              value: '${subjectData.examCount} exams',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatistics(AttendanceStatistics stats) {
    return _SectionCard(
      title: 'Attendance Statistics',
      subtitle: 'Attendance health at a glance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniPill(
                label: 'Today',
                value: '${stats.todayAttendanceRate.toStringAsFixed(1)}%',
                color: Colors.green,
              ),
              _MiniPill(
                label: 'Weekly',
                value: '${stats.weeklyAttendanceRate.toStringAsFixed(1)}%',
                color: Colors.blue,
              ),
              _MiniPill(
                label: 'Monthly',
                value: '${stats.monthlyAttendanceRate.toStringAsFixed(1)}%',
                color: Colors.indigo,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintStatistics(ComplaintStatistics stats) {
    return _SectionCard(
      title: 'Complaint Statistics',
      subtitle: 'Monitor feedback resolution progress',
      action: Chip(
        backgroundColor: Colors.pink.withOpacity(0.12),
        label: Text(
          '${stats.pendingComplaints} pending',
          style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w600),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MiniPill(label: 'Total', value: stats.totalComplaints.toString(), color: Colors.black87),
              const SizedBox(width: 10),
              _MiniPill(label: 'Resolved', value: stats.resolvedComplaints.toString(), color: Colors.green),
            ],
          ),
          if (stats.complaintsByCategory.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('By Category', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...stats.complaintsByCategory.map(
              (categoryData) => _LabeledStatRow(
                label: categoryData.category.toUpperCase(),
                value: '${categoryData.count} complaints',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LabeledStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _LabeledStatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}