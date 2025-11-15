import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_input_field.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../controllers/auth_controller.dart';
import '../models/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _codeFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(authControllerProvider);
    final initialEmail = initialState.email;
    if (initialEmail != null && initialEmail.isNotEmpty) {
      _emailController.text = initialEmail;
    }

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted) {
        return;
      }
      if (previous?.status != AuthStatus.codeSent &&
          next.status == AuthStatus.codeSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'We sent a verification code to ${next.email}.',
              style: AppTypography.body2.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage!,
              style: AppTypography.body2.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isCodeSent = authState.status == AuthStatus.codeSent;
    final isSending = authState.operation == AuthOperation.sendingCode;
    final isVerifying = authState.operation == AuthOperation.verifyingCode;

    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in with your email to receive a one-time verification code.',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.darkGrey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomCard(
                    backgroundColor: AppColors.lightGrey,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How it works',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.charcoal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. Enter your email and we\'ll send a 6-digit code.\n'
                          '2. Enter the code to securely sign in.\n'
                          '3. Your sessions stay private—no passwords to remember.',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.darkGrey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _emailFormKey,
                    child: CustomInputField(
                      label: 'Email address',
                      hint: 'you@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => ref
                          .read(authControllerProvider.notifier)
                          .clearError(),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Enter your email address';
                        }
                        final emailRegExp =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegExp.hasMatch(trimmed)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: isCodeSent ? 'Resend code' : 'Send code',
                    isLoading: isSending,
                    onPressed: isSending
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            if (_emailFormKey.currentState?.validate() !=
                                true) {
                              return;
                            }
                            await ref
                                .read(authControllerProvider.notifier)
                                .requestOtp(_emailController.text);
                          },
                  ),
                  if (isCodeSent) ...[
                    const SizedBox(height: 36),
                    Text(
                      'Enter verification code',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Form(
                      key: _codeFormKey,
                      child: TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.lightGrey,
                          hintText: '123456',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryPastel,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (_) => ref
                            .read(authControllerProvider.notifier)
                            .clearError(),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Enter the 6-digit code';
                          }
                          if (trimmed.length != 6) {
                            return 'Codes are 6 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Verify and continue',
                      isLoading: isVerifying,
                      onPressed: isVerifying
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();
                              if (_codeFormKey.currentState?.validate() !=
                                  true) {
                                return;
                              }
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .verifyOtp(_codeController.text);
                            },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: isVerifying
                          ? null
                          : () {
                              _codeController.clear();
                              ref
                                  .read(authControllerProvider.notifier)
                                  .resetFlow();
                            },
                      child: const Text('Use a different email'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
