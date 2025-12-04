import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tenant/tenant_bloc.dart';
import '../bloc/tenant/tenant_event.dart';
import '../bloc/tenant/tenant_state.dart';
import '../models/tenant.dart';
import 'dashboard_screen.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  final _nameController = TextEditingController();
  final _schemaController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _schemaController.dispose();
    super.dispose();
  }

  void _openTenantSheet({Tenant? existingTenant}) {
    final isEdit = existingTenant != null;
    if (isEdit) {
      _nameController.text = existingTenant!.name;
      _schemaController.text = existingTenant.schemaName;
    } else {
      _nameController.clear();
      _schemaController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEdit ? 'Edit client' : 'New client', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Client Name', filled: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _schemaController,
                decoration: const InputDecoration(
                  labelText: 'Schema Name',
                  helperText: 'e.g., school_abc, client_xyz',
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty || _schemaController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red));
                      return;
                    }

                    final tenant = Tenant(
                      id: isEdit ? existingTenant!.id : null,
                      name: _nameController.text.trim(),
                      schemaName: _schemaController.text.trim(),
                    );

                    if (isEdit) {
                      context.read<TenantBloc>().add(UpdateTenant(tenant));
                    } else {
                      context.read<TenantBloc>().add(AddTenant(tenant));
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(isEdit ? 'Update client' : 'Add client'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String tenantId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete client'),
        content: Text("Are you sure you want to delete '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<TenantBloc>().add(DeleteTenant(tenantId));
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
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [IconButton(onPressed: () => context.read<TenantBloc>().add(LoadTenants()), icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _openTenantSheet(), child: const Icon(Icons.add)),
      body: BlocConsumer<TenantBloc, TenantState>(
        listener: (context, state) {
          if (state is TenantOperationSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
          } else if (state is TenantOperationFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is TenantLoading) return const Center(child: CircularProgressIndicator());
          if (state is TenantsLoaded) {
            if (state.tenants.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.business, size: 56, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('No clients yet', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextButton(onPressed: () => _openTenantSheet(), child: const Text('Add client')),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: state.tenants.length,
              itemBuilder: (context, index) {
                final tenant = state.tenants[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(child: Text(tenant.name[0].toUpperCase())),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('Schema: ${tenant.schemaName}', style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => _openTenantSheet(existingTenant: tenant), icon: const Icon(Icons.edit_outlined)),
                      IconButton(
                        onPressed: () => _confirmDelete(tenant.id!, tenant.name),
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DashboardScreen(tenant: tenant)),
                        ),
                        child: const Text('Open'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          if (state is TenantOperationFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(state.error, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => context.read<TenantBloc>().add(LoadTenants()),
                    child: const Text('Retry'),
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
}
