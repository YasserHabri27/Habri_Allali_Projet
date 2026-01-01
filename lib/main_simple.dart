import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleTestApp());
}

class SimpleTestApp extends StatelessWidget {
  const SimpleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pegasus - Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pegasus App - Mode Test'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'L\'application fonctionne !',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Le moteur Flutter est opérationnel.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Bouton de test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
