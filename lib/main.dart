import 'package:flutter/material.dart';
import 'package:pegasus_app/core/theme/app_theme.dart';
import 'package:pegasus_app/features/auth/presentation/pages/login_page.dart';

void main() async {
  // Version simplifiée pour tester sans AuthBloc
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const PegasusApp());
}

class PegasusApp extends StatelessWidget {
  const PegasusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pegasus - Smart Workflow Manager',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
