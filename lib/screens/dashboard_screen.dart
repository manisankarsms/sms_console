// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/administration/administration_bloc.dart';
import '../bloc/administration/administration_event.dart';
import '../bloc/administration/administration_state.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../models/administration.dart';
import '../models/dashboard.dart';
import '../models/tenant.dart';

class DashboardScreen extends StatefulWidget {
  final Tenant tenant;

  const DashboardScreen({super.key, required this.tenant});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _academicYearFormKey = GlobalKey<FormState>();
  final _userFormKey = GlobalKey<FormState>();

  final _yearController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _yearOptions = <String>[];
  String? _selectedYearOption;
  bool _useCustomYear = false;
  bool _isAcademicYearActive = true;

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _selectedRole = 'ADMIN';

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData(widget.tenant.id!));
    context.read<AdministrationBloc>().add(LoadAcademicYears(widget.tenant.id!));
    context.read<AdministrationBloc>().add(LoadAdminUsers(widget.tenant.id!));

    final currentYear = DateTime.now().year;
    for (int i = 0; i < 5; i++) {
      final startYear = currentYear + i;
      _yearOptions.add('$startYear-${startYear + 1}');
    }
    _selectedYearOption = _yearOptions.isNotEmpty ? _yearOptions.first : null;
    if (_selectedYearOption != null) {
      _yearController.text = _selectedYearOption!;
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _resetAcademicYearForm() {
    _useCustomYear = false;
    _selectedYearOption = _yearOptions.isNotEmpty ? _yearOptions.first : null;
    _yearController.text = _selectedYearOption ?? '';
    _startDateController.clear();
    _endDateController.clear();
    setState(() => _isAcademicYearActive = true);
  }

  void _resetUserForm() {
    _emailController.clear();
    _mobileController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    setState(() => _selectedRole = 'ADMIN');
  }

  Future<void> _pickDate(TextEditingController controller, {DateTime? initialDate}) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (selectedDate != null) {
      controller.text = _dateFormatter.format(selectedDate);
    }
  }

  void _confirmDeleteUser(String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete user'),
        content: const Text('Are you sure you want to remove this administrator?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<AdministrationBloc>().add(DeleteUser(tenantId: widget.tenant.id!, userId: userId));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.tenant.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardBloc>().add(LoadDashboardData(widget.tenant.id!)),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AdministrationBloc, AdministrationState>(
            listener: (context, adminState) {
              if (adminState is AdministrationLoaded && adminState.message != null) {
                if (adminState.message!.contains('Academic year')) _resetAcademicYearForm();
                if (adminState.message!.contains('User created')) _resetUserForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(adminState.message!), backgroundColor: Colors.green),
                );
              } else if (adminState is AdministrationFailure) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(adminState.error), backgroundColor: Colors.red));
              }
            },
          ),
          BlocListener<DashboardBloc, DashboardState>(
            listener: (context, state) {
              if (state is DashboardOperationFailure) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
              }
            },
          ),
        ],
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) return const Center(child: CircularProgressIndicator());
            if (state is DashboardLoaded) {
              return BlocBuilder<AdministrationBloc, AdministrationState>(
                builder: (context, adminState) => _buildDashboardContent(state.dashboardData, adminState),
              );
            }
            if (state is DashboardOperationFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(state.error, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.read<DashboardBloc>().add(LoadDashboardData(widget.tenant.id!)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardData data, AdministrationState adminState) {
    final academicYears = _academicYearsFromState(adminState);
    final adminUsers = _adminUsersFromState(adminState);
    final isProcessing = adminState is AdministrationOperationInProgress;
    final isLoading = adminState is AdministrationLoading && academicYears.isEmpty && adminUsers.isEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'Overview',
          child: _metricGrid({
            'Students': data.overview.totalStudents.toString(),
            'Staff': data.overview.totalStaff.toString(),
            'Classes': data.overview.totalClasses.toString(),
            'Subjects': data.overview.totalSubjects.toString(),
            'Attendance': '${data.overview.todayAttendanceRate.toStringAsFixed(1)}%',
            'Active Years': data.overview.activeAcademicYears.toString(),
          }),
        ),
        const SizedBox(height: 12),
        _Section(
          title: 'Administration',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardShell(
                title: 'Academic Year',
                child: _buildAcademicYearForm(isProcessing, isLoading),
              ),
              const SizedBox(height: 12),
              _CardShell(
                title: 'Console User',
                child: _buildUserForm(isProcessing),
              ),
              const SizedBox(height: 12),
              _CardShell(title: 'Academic Years', child: _buildAcademicYearList(academicYears, adminState, isLoading)),
              const SizedBox(height: 12),
              _CardShell(title: 'Admin Users', child: _buildAdminUsers(adminUsers, adminState, isLoading)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Section(
          title: 'Recent activity',
          child: Column(
            children: [
              _CardShell(
                title: 'Enrollments',
                child: _simpleList(
                  data.studentStatistics.recentEnrollments
                      .map((e) => '${e.studentName} • ${e.className} (${e.academicYearName})')
                      .toList(),
                  emptyLabel: 'No enrollments logged',
                ),
              ),
              const SizedBox(height: 12),
              _CardShell(
                title: 'Holidays',
                child: _metricGrid({
                  'Total': data.holidayStatistics.totalHolidays.toString(),
                  'Upcoming': data.holidayStatistics.upcomingHolidays.toString(),
                }),
              ),
              const SizedBox(height: 12),
              _CardShell(
                title: 'Complaints',
                child: _metricGrid({
                  'Filed': data.overview.totalComplaints.toString(),
                  'Pending': data.overview.pendingComplaints.toString(),
                  'Resolved': data.complaintStatistics.resolvedComplaints.toString(),
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<AcademicYear> _academicYearsFromState(AdministrationState state) {
    if (state is AdministrationLoaded) return state.academicYears;
    if (state is AdministrationOperationInProgress) return state.academicYears;
    if (state is AdministrationFailure) return state.academicYears;
    return [];
  }

  List<AdminUser> _adminUsersFromState(AdministrationState state) {
    if (state is AdministrationLoaded) return state.adminUsers;
    if (state is AdministrationOperationInProgress) return state.adminUsers;
    if (state is AdministrationFailure) return state.adminUsers;
    return [];
  }

  Widget _buildAcademicYearForm(bool isProcessing, bool isAdminLoading) {
    return Form(
      key: _academicYearFormKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedYearOption,
            decoration: _fieldDecoration('Academic Year'),
            items: [
              ..._yearOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))),
              const DropdownMenuItem(value: 'custom', child: Text('Custom year label')),
            ],
            onChanged: isProcessing || isAdminLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedYearOption = value;
                      _useCustomYear = value == 'custom';
                      _yearController.text = _useCustomYear ? '' : value;
                    });
                  },
            validator: (value) {
              if (_useCustomYear && _yearController.text.trim().isEmpty) return 'Enter a custom year label';
              if (!_useCustomYear && (value == null || value.isEmpty)) return 'Select the academic year label';
              return null;
            },
          ),
          if (_useCustomYear)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextFormField(
                controller: _yearController,
                decoration: _fieldDecoration('Custom Academic Year'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  onTap: isProcessing || isAdminLoading
                      ? null
                      : () => _pickDate(_startDateController, initialDate: DateTime.tryParse(_startDateController.text)),
                  decoration: _fieldDecoration('Start Date').copyWith(suffixIcon: const Icon(Icons.calendar_today_rounded)),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  onTap: isProcessing || isAdminLoading
                      ? null
                      : () => _pickDate(_endDateController, initialDate: DateTime.tryParse(_endDateController.text)),
                  decoration: _fieldDecoration('End Date').copyWith(suffixIcon: const Icon(Icons.calendar_today_rounded)),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _isAcademicYearActive,
            onChanged: (value) => setState(() => _isAcademicYearActive = value),
            title: const Text('Mark as active'),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing || isAdminLoading
                  ? null
                  : () {
                      if (_academicYearFormKey.currentState?.validate() != true) return;
                      final selectedYear = _useCustomYear ? _yearController.text.trim() : (_selectedYearOption ?? '');
                      if (selectedYear.isEmpty) return;
                      final academicYear = AcademicYear(
                        year: selectedYear,
                        startDate: _startDateController.text.trim(),
                        endDate: _endDateController.text.trim(),
                        isActive: _isAcademicYearActive,
                      );
                      context.read<AdministrationBloc>().add(
                            CreateAcademicYear(tenantId: widget.tenant.id!, academicYear: academicYear),
                          );
                    },
              child: Text(isProcessing || isAdminLoading ? 'Working...' : 'Create Academic Year'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserForm(bool isProcessing) {
    return Form(
      key: _userFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _simpleField(_firstNameController, 'First Name')),
              const SizedBox(width: 8),
              Expanded(child: _simpleField(_lastNameController, 'Last Name')),
            ],
          ),
          const SizedBox(height: 8),
          _simpleField(_emailController, 'Email', keyboardType: TextInputType.emailAddress, validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Required';
            if (!value.contains('@')) return 'Invalid email';
            return null;
          }),
          const SizedBox(height: 8),
          _simpleField(_mobileController, 'Mobile', keyboardType: TextInputType.phone),
          const SizedBox(height: 8),
          _simpleField(_passwordController, 'Password', obscureText: true),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: _fieldDecoration('Role'),
            items: const [
              DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
              DropdownMenuItem(value: 'OPERATOR', child: Text('Operator')),
            ],
            onChanged: isProcessing ? null : (value) => setState(() => _selectedRole = value ?? 'ADMIN'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () {
                      if (_userFormKey.currentState?.validate() != true) return;
                      final user = AdminUser(
                        email: _emailController.text.trim(),
                        mobileNumber: _mobileController.text.trim(),
                        password: _passwordController.text.trim(),
                        role: _selectedRole,
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                      );
                      context.read<AdministrationBloc>().add(CreateUser(tenantId: widget.tenant.id!, user: user));
                    },
              child: Text(isProcessing ? 'Saving...' : 'Create User'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicYearList(List<AcademicYear> academicYears, AdministrationState adminState, bool isLoading) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (academicYears.isEmpty) return const Padding(padding: EdgeInsets.all(8), child: Text('No academic years yet.'));
    return Column(
      children: academicYears
          .map(
            (year) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(year.isActive ? Icons.check_circle : Icons.calendar_today,
                  color: year.isActive ? Colors.green : Colors.grey[700]),
              title: Text(year.year, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${year.startDate} → ${year.endDate}'),
              trailing: year.isActive ? const Chip(label: Text('Active')) : null,
            ),
          )
          .toList(),
    );
  }

  Widget _buildAdminUsers(List<AdminUser> adminUsers, AdministrationState adminState, bool isLoading) {
    final isDeleting = adminState is AdministrationOperationInProgress && adminState.message.toLowerCase().contains('user');
    if (isLoading || isDeleting) return const Center(child: CircularProgressIndicator());
    if (adminUsers.isEmpty) return const Padding(padding: EdgeInsets.all(8), child: Text('No admin users yet.'));
    return Column(
      children: adminUsers
          .map(
            (user) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: CircleAvatar(child: Text(user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?')),
              title: Text('${user.firstName} ${user.lastName}'.trim()),
              subtitle: Text('${user.email} • ${user.mobileNumber}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDeleteUser(user.id),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _simpleList(List<String> items, {String emptyLabel = 'Nothing to show'}) {
    if (items.isEmpty) return Padding(padding: const EdgeInsets.all(8), child: Text(emptyLabel));
    return Column(
      children: items
          .map((item) => ListTile(
                dense: true,
                leading: const Icon(Icons.bolt_outlined, size: 18),
                title: Text(item),
              ))
          .toList(),
    );
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(labelText: label, filled: true, border: const OutlineInputBorder());

  Widget _simpleField(TextEditingController controller, String label,
      {bool obscureText = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: _fieldDecoration(label),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator ?? (value) => value == null || value.trim().isEmpty ? 'Required' : null,
    );
  }

  Widget _metricGrid(Map<String, String> items) {
    final entries = items.entries.toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
                ? 2
                : 1;
        final itemWidth = (constraints.maxWidth - (12 * (crossAxisCount - 1))) / crossAxisCount;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: entries
              .map((entry) => SizedBox(
                    width: itemWidth,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: TextStyle(color: Colors.grey[700])),
                          const SizedBox(height: 6),
                          Text(entry.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
