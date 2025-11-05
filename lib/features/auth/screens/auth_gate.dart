import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../shell/screens/main_screen.dart';
import '../controllers/auth_controller.dart';
import '../models/auth_state.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.operation == AuthOperation.restoring ||
        authState.status == AuthStatus.unknown) {
      return const _SplashLoader();
    }

    if (authState.isAuthenticated) {
      return const MainScreen();
    }

    return const LoginScreen();
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Getting things ready...',
              style: AppTypography.body2.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
