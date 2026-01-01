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
  
  // Nous initialisons notre conteneur d'injection de dépendances (Service Locator)
  // Cette étape est cruciale pour découpler l'instanciation des classes de leur utilisation
  await di.init();
  
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
      child: MaterialApp.router(
        title: 'Pegasus - Smart Workflow Manager',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        // Configuration de GoRouter pour une gestion déclarative de la navigation
        routerConfig: GoRouter(
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
          // Nous implémentons ici un Guard pour sécuriser l'accès aux routes
          // Cette fonction redirige automatiquement l'utilisateur en fonction de son statut d'authentification
          redirect: (context, state) {
            final authBloc = context.read<AuthBloc>();
            final isAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';
            
            // Si l'utilisateur est authentifié et tente d'accéder aux pages de login/register,
            // nous le redirigeons vers le dashboard
            if (authBloc.state is AuthAuthenticated && isAuthPage) {
              return '/dashboard';
            }
            
            // Si l'utilisateur n'est pas authentifié et tente d'accéder à une page protégée,
            // nous le redirigeons vers le login
            if (authBloc.state is AuthUnauthenticated && !isAuthPage) {
              return '/login';
            }
            
            return null;
          },
        ),
      ),
    );
  }
}
