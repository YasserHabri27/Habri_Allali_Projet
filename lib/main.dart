import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pegasus_app/config/injection/injection_container.dart' as di;
import 'package:pegasus_app/core/theme/app_theme.dart';
import 'package:pegasus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pegasus_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:pegasus_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:pegasus_app/features/auth/presentation/pages/login_page.dart';
import 'package:pegasus_app/features/auth/presentation/pages/register_page.dart';
import 'package:pegasus_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pegasus_app/features/projects/presentation/pages/project_list_page.dart';
import 'package:pegasus_app/features/tasks/presentation/pages/task_list_page.dart';

void main() async {
  // Nous assurons l'initialisation des liaisons avec le moteur Flutter avant d'exécuter toute opération asynchrone
  WidgetsFlutterBinding.ensureInitialized();
  
  // Nous initialisons notre conteneur d'injection de dépendances (Service Locator) avec gestion d'erreurs
  try {
    await di.init();
    print('✅ Dependency injection initialized successfully');
  } catch (e) {
    print('⚠️ Dependency injection initialization failed: $e');
    // L'application continuera avec les services disponibles
  }
  
  runApp(const PegasusApp());
}

class PegasusApp extends StatelessWidget {
  const PegasusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Nous mettons en place le MultiBlocProvider pour injecter les BLoCs globaux nécessaires
    // AuthBloc est injecté au sommet de l'arbre car l'état d'authentification impacte l'ensemble de l'application
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.getIt<AuthBloc>()..add(CheckAuthStatus()),
        ),
      ],
      child: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectListPage(),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TaskListPage(),
        ),
      ],
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';
        
        if (authState is AuthLoading) {
          return null;
        }
        
        if (authState is AuthAuthenticated && isAuthPage) {
          return '/dashboard';
        }
        
        if (authState is AuthUnauthenticated && !isAuthPage) {
          return '/login';
        }
        
        return null;
      },
      refreshListenable: GoRouterRefreshStream(context.read<AuthBloc>().stream),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pegasus - Smart Workflow Manager',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
