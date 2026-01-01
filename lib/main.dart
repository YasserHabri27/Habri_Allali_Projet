import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'config/injection/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/projects/presentation/pages/project_list_page.dart';

void main() async {
  // Nous assurons l'initialisation des bindings Flutter avant toute opération asynchrone
  WidgetsFlutterBinding.ensureInitialized();
  
  // Nous initialisons notre conteneur d'injection de dépendances (Service Locator)
  // Cela permet de découpler l'instanciation des classes de leur utilisation
  await di.init();
  
  runApp(const PegasusApp());
}

class PegasusApp extends StatelessWidget {
  const PegasusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Nous utilisons MultiBlocProvider pour injecter les BLoCs globaux nécessaires à l'application
    // AuthBloc est injecté ici car l'état d'authentification affecte l'ensemble de l'app
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
        // Configuration de GoRouter pour la gestion de la navigation
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
          ],
          // Nous implémentons ici la logique de protection des routes (Guard)
          // Cette fonction redirige automatiquement l'utilisateur selon son état d'auth
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
