import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  static const route = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context).extension<SoulGradients>()?.pastel ??
        const LinearGradient(colors: [Colors.blue, Colors.teal]);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'mindcare',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Brain illustration
                Image.asset(
                  'assets/images/brain.png',
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                // Heading
                const Text(
                  'Your mental\nhealth matters',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                const Text(
                  'Start your journey with us',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                // CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      "Let's start now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Import the SoulGradients extension from main.dart
class SoulGradients extends ThemeExtension<SoulGradients> {
  final LinearGradient pastel;

  const SoulGradients({required this.pastel});

  @override
  SoulGradients copyWith({LinearGradient? pastel}) =>
      SoulGradients(pastel: pastel ?? this.pastel);

  @override
  ThemeExtension<SoulGradients> lerp(
    covariant ThemeExtension<SoulGradients>? other,
    double t,
  ) {
    if (other is! SoulGradients) return this;
    return t < .5 ? this : other;
  }
}
