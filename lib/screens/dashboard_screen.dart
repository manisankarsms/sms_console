// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../bloc/administration/administration_bloc.dart';
import '../bloc/administration/administration_event.dart';
import '../bloc/administration/administration_state.dart';
import '../models/administration.dart';
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
    // Load dashboard data with tenant ID
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
    setState(() {
      _isAcademicYearActive = true;
    });
  }

  void _resetUserForm() {
    _emailController.clear();
    _mobileController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    setState(() {
      _selectedRole = 'ADMIN';
    });
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<AdministrationBloc>().add(DeleteUser(
                    tenantId: widget.tenant.id!,
                    userId: userId,
                  ));
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<AdministrationBloc, AdministrationState>(
            listener: (context, adminState) {
              if (adminState is AdministrationLoaded && adminState.message != null) {
                if (adminState.message!.contains('Academic year')) {
                  _resetAcademicYearForm();
                }
                if (adminState.message!.contains('User created')) {
                  _resetUserForm();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(adminState.message!),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (adminState is AdministrationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(adminState.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<DashboardBloc, DashboardState>(
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
          ),
        ],
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardLoaded) {
              return BlocBuilder<AdministrationBloc, AdministrationState>(
                builder: (context, adminState) {
                  return _buildDashboardContent(state.dashboardData, adminState);
                },
              );
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
      ),
    );
  }

  Widget _buildDashboardContent(DashboardData data, AdministrationState adminState) {
    final academicYears = _academicYearsFromState(adminState);
    final adminUsers = _adminUsersFromState(adminState);
    final isAdminLoading = adminState is AdministrationLoading && academicYears.isEmpty && adminUsers.isEmpty;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(data.overview),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildManagementSection(adminState, academicYears, adminUsers, isAdminLoading),
                const SizedBox(height: 24),
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

  List<AcademicYear> _academicYearsFromState(AdministrationState state) {
    if (state is AdministrationLoaded) {
      return state.academicYears;
    }
    if (state is AdministrationOperationInProgress) {
      return state.academicYears;
    }
    if (state is AdministrationFailure) {
      return state.academicYears;
    }
    return [];
  }

  List<AdminUser> _adminUsersFromState(AdministrationState state) {
    if (state is AdministrationLoaded) {
      return state.adminUsers;
    }
    if (state is AdministrationOperationInProgress) {
      return state.adminUsers;
    }
    if (state is AdministrationFailure) {
      return state.adminUsers;
    }
    return [];
  }

  Widget _buildManagementSection(
    AdministrationState adminState,
    List<AcademicYear> academicYears,
    List<AdminUser> adminUsers,
    bool isAdminLoading,
  ) {
    final isProcessing = adminState is AdministrationOperationInProgress;
    final isUserOperation = isProcessing && adminState.message.toLowerCase().contains('user');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.settings, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              'Setup & Administration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1100
                ? 3
                : constraints.maxWidth > 780
                    ? 2
                    : 1;
            final itemWidth = (constraints.maxWidth - (16 * (crossAxisCount - 1))) / crossAxisCount;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _buildAcademicYearCard(isProcessing, isAdminLoading),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildUserCard(isProcessing),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildAcademicYearListCard(academicYears, adminState, isAdminLoading),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildAdminUsersCard(adminUsers, adminState, isAdminLoading || isUserOperation),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAcademicYearCard(bool isProcessing, bool isAdminLoading) {
    return _SectionCard(
      title: 'Create Academic Year',
      subtitle: 'Publish academic windows that other modules can reference',
      child: Form(
        key: _academicYearFormKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedYearOption,
              decoration: const InputDecoration(
                labelText: 'Academic Year',
                hintText: '2025-2026',
                border: OutlineInputBorder(),
              ),
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
                        if (!_useCustomYear) {
                          _yearController.text = value;
                        } else {
                          _yearController.clear();
                        }
                      });
                    },
              validator: (value) {
                if (_useCustomYear && _yearController.text.trim().isEmpty) {
                  return 'Enter a custom year label';
                }
                if (!_useCustomYear && (value == null || value.isEmpty)) {
                  return 'Select the academic year label';
                }
                return null;
              },
            ),
            if (_useCustomYear) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Custom Academic Year',
                  hintText: 'e.g., 2025-2026',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (!_useCustomYear) return null;
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the academic year label';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startDateController,
                    readOnly: true,
                    onTap: isProcessing || isAdminLoading
                        ? null
                        : () => _pickDate(
                              _startDateController,
                              initialDate: DateTime.tryParse(_startDateController.text),
                            ),
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      hintText: 'YYYY-MM-DD',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _endDateController,
                    readOnly: true,
                    onTap: isProcessing || isAdminLoading
                        ? null
                        : () => _pickDate(
                              _endDateController,
                              initialDate: DateTime.tryParse(_endDateController.text),
                            ),
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      hintText: 'YYYY-MM-DD',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isAcademicYearActive,
              onChanged: (value) {
                setState(() {
                  _isAcademicYearActive = value;
                });
              },
              title: const Text('Mark as active'),
              subtitle: const Text('Sets this year as the active calendar for the tenant'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                              CreateAcademicYear(
                                tenantId: widget.tenant.id!,
                                academicYear: academicYear,
                              ),
                            );
                      },
                icon: isProcessing || isAdminLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(isProcessing || isAdminLoading ? 'Working...' : 'Create Academic Year'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(bool isProcessing) {
    return _SectionCard(
      title: 'Create Console User',
      subtitle: 'Quickly provision administrators for this tenant',
      child: Form(
        key: _userFormKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Required';
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mobileController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isProcessing
                    ? null
                    : () {
                        if (_userFormKey.currentState?.validate() != true) return;
                        final user = UserPayload(
                          email: _emailController.text.trim(),
                          mobileNumber: _mobileController.text.trim(),
                          password: _passwordController.text.trim(),
                          role: _selectedRole,
                          firstName: _firstNameController.text.trim(),
                          lastName: _lastNameController.text.trim(),
                        );

                        context.read<AdministrationBloc>().add(
                              CreateUser(
                                tenantId: widget.tenant.id!,
                                user: user,
                              ),
                            );
                      },
                icon: isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.person_add_alt_1),
                label: Text(isProcessing ? 'Working...' : 'Create User'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicYearListCard(
    List<AcademicYear> academicYears,
    AdministrationState adminState,
    bool isAdminLoading,
  ) {
    return _SectionCard(
      title: 'Academic Years',
      subtitle: 'Recently published timelines',
      action: IconButton(
        tooltip: 'Refresh',
        onPressed: () => context.read<AdministrationBloc>().add(LoadAcademicYears(widget.tenant.id!)),
        icon: const Icon(Icons.refresh),
      ),
      child: isAdminLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (academicYears.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No academic years have been created yet.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  )
                else
                  ...academicYears.map(
                    (year) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: year.isActive ? const Color(0xFFE8F3FF) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: year.isActive ? const Color(0xFF2B88F0) : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(year.isActive ? Icons.check_circle : Icons.calendar_today,
                              color: year.isActive ? const Color(0xFF2B88F0) : Colors.grey.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  year.year,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${year.startDate} → ${year.endDate}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          if (year.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B88F0).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(color: Color(0xFF2B88F0), fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (adminState is AdministrationFailure)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      adminState.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildAdminUsersCard(
    List<AdminUser> adminUsers,
    AdministrationState adminState,
    bool isLoading,
  ) {
    return _SectionCard(
      title: 'Admin Users',
      subtitle: 'Manage console administrators',
      action: IconButton(
        tooltip: 'Refresh',
        onPressed: isLoading
            ? null
            : () => context.read<AdministrationBloc>().add(LoadAdminUsers(widget.tenant.id!)),
        icon: const Icon(Icons.refresh),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (adminUsers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No admin users found for this tenant.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  )
                else
                  ...adminUsers.map(
                    (user) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF2B88F0).withOpacity(0.12),
                            child: Text(user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.firstName} ${user.lastName}'.trim(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(user.email, style: TextStyle(color: Colors.grey.shade700)),
                                const SizedBox(height: 2),
                                Text('Mobile: ${user.mobileNumber}', style: TextStyle(color: Colors.grey.shade700)),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete user',
                            onPressed: isLoading ? null : () => _confirmDeleteUser(user.id),
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (adminState is AdministrationFailure)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      adminState.error,
                      style: const TextStyle(color: Colors.red),
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