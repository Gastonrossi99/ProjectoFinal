import 'package:flutter/material.dart';

class OtrosView extends StatelessWidget {
  const OtrosView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 100, color: Color(0xFF1D1B20)),
            SizedBox(height: 16),
            Text(
              'Otros Productos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
