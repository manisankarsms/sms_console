import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/tenant/tenant_bloc.dart';
import 'bloc/dashboard/dashboard_bloc.dart';
import 'repositories/tenant_repository.dart';
import 'repositories/dashboard_repository.dart';
import 'services/web_service.dart';
import 'screens/tenants_screen.dart';

void main() {
  runApp(const AdminConsoleApp());
}

class AdminConsoleApp extends StatelessWidget {
  const AdminConsoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WebService>(
          create: (context) => WebService(baseUrl: 'https://web-test-5149.up.railway.app/api/v1'),
        ),
        RepositoryProvider<TenantRepository>(
          create: (context) => TenantRepository(
            webService: context.read<WebService>(),
          ),
        ),
        RepositoryProvider<DashboardRepository>(
          create: (context) => DashboardRepository(
            webService: context.read<WebService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TenantBloc>(
            create: (context) => TenantBloc(
              tenantRepository: context.read<TenantRepository>(),
            ),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              dashboardRepository: context.read<DashboardRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Admin Console',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const TenantsScreen(),
        ),
      ),
    );
  }
}

// Now your navigation will work as-is:
// onTap: () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => DashboardScreen(tenant: tenant),
//     ),
//   );
// },