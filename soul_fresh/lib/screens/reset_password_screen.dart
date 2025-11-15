import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/colors.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  String? _error;
  double _strength = 0.0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.grey;
  int _retryRemaining = 0;
  DateTime? _retryUntil;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset(String email) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      await auth.confirmPasswordResetOtp(
        email: email,
        code: _codeCtrl.text.trim(),
        newPassword: _passCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. Please log in.')),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      final msg = e.toString();
      final retryMatch = RegExp(r'Try again in (\d+)s').firstMatch(msg);
      if (retryMatch != null) {
        final secs = int.tryParse(retryMatch.group(1)!);
        if (secs != null) {
          _retryUntil = DateTime.now().add(Duration(seconds: secs));
          _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
            if (_retryUntil == null) return;
            final diff = _retryUntil!.difference(DateTime.now());
            final s = diff.inSeconds;
            if (s <= 0) {
              setState(() {
                _retryRemaining = 0;
                _retryUntil = null;
              });
            } else {
              setState(() {
                _retryRemaining = s;
              });
            }
          });
        }
      }
      setState(() {
        _error = msg;
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _strength = _calculatePasswordStrength(value);
      final info = _getPasswordStrengthInfo(value);
      _strengthLabel = info.$1;
      _strengthColor = info.$2;
    });
  }

  double _calculatePasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.1;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    return strength.clamp(0, 1);
  }

  (String, Color) _getPasswordStrengthInfo(String password) {
    if (password.isEmpty) return ('', Colors.grey);
    if (_strength < 0.4) return ('Weak', AppColors.error);
    if (_strength < 0.7) return ('Medium', Colors.orange);
    return ('Strong', Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final email = (args['email'] as String?) ?? '';
    final preview = args['preview'] as String?; // dev only

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('We sent a 6-digit code to\n$email'),
              if (preview != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Preview code (dev): $preview',
                  style: const TextStyle(color: Colors.purple),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '6-digit code',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().length != 6) {
                    return 'Enter the 6-digit code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                onChanged: _onPasswordChanged,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: Validators.password,
              ),
              if (_passCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _strength,
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_strengthColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _strengthLabel,
                      style: TextStyle(
                        color: _strengthColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) =>
                    Validators.confirmPassword(value, _passCtrl.text),
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const Spacer(),
              FilledButton(
                onPressed: (_saving || _retryRemaining > 0)
                    ? null
                    : () => _reset(email),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _retryRemaining > 0
                            ? 'Retry in $_retryRemaining s'
                            : 'Change Password',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
