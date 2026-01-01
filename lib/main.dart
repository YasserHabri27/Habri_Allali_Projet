import 'package:flutter/material.dart';
import 'config/injection/injection_container.dart' as di;
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser l'injection de dépendances
  await di.init();
  
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
      home: const Scaffold(
        body: Center(
          child: Text('Pegasus App - Structure prête!'),
        ),
      ),
    );
  }
}
