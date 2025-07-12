import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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

  void _showTenantDialog({Tenant? existingTenant}) {
    final isEdit = existingTenant != null;
    if (isEdit) {
      _nameController.text = existingTenant.name;
      _schemaController.text = existingTenant.schemaName;
    } else {
      _nameController.clear();
      _schemaController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Client" : "New Client"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Client Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _schemaController,
              decoration: const InputDecoration(
                labelText: "Schema Name",
                border: OutlineInputBorder(),
                helperText: "e.g., school_abc, client_xyz",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty ||
                  _schemaController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please fill in all fields"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final tenant = Tenant(
                id: isEdit ? existingTenant.id : null,
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
            child: Text(isEdit ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String tenantId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Client"),
        content: Text("Are you sure you want to delete '$name'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<TenantBloc>().add(DeleteTenant(tenantId));
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Client Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TenantBloc>().add(LoadTenants()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTenantDialog(),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<TenantBloc, TenantState>(
        listener: (context, state) {
          if (state is TenantOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is TenantOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TenantLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TenantsLoaded) {
            if (state.tenants.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "No clients yet",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showTenantDialog(),
                      child: const Text("Add First Client"),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tenants.length,
              itemBuilder: (context, index) {
                final tenant = state.tenants[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(tenant.name[0].toUpperCase()),
                    ),
                    title: Text(tenant.name),
                    subtitle: Text('Schema: ${tenant.schemaName}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(tenant: tenant),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showTenantDialog(existingTenant: tenant),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(tenant.id!, tenant.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is TenantOperationFailure) {
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
                    onPressed: () => context.read<TenantBloc>().add(LoadTenants()),
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

  @override
  void dispose() {
    _nameController.dispose();
    _schemaController.dispose();
    super.dispose();
  }
}