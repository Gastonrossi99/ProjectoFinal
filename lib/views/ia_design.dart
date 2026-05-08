import 'package:flutter/material.dart';

class IADesignView extends StatelessWidget {
  const IADesignView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 100, color: Color(0xFF1D1B20)),
            SizedBox(height: 16),
            Text(
              'IA Design Studio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
