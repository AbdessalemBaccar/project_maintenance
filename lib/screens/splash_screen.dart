import 'package:flutter/material.dart';
import '../app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.tealGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.directions_car, size: 44, color: Colors.black),
            ),
            const SizedBox(height: 24),
            Text('CarTrack',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonTeal),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
