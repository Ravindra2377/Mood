import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sending = false;
  String? _error;
  int? _retryAfter; // seconds
  DateTime? _retryUntil;
  Timer? _timer;
  int _remaining = 0; // countdown seconds
  // We navigate immediately after request; no need to store preview here.

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_retryUntil == null) return;
      final diff = _retryUntil!.difference(DateTime.now());
      final secs = diff.inSeconds;
      if (secs <= 0) {
        setState(() {
          _retryAfter = null;
          _retryUntil = null;
          _remaining = 0;
        });
      } else {
        setState(() {
          _remaining = secs;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      final code = await auth.requestPasswordResetOtp(_emailCtrl.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        '/reset-password',
        arguments: {
          'email': _emailCtrl.text.trim(),
          if (code != null) 'preview': code,
        },
      );
    } catch (e) {
      // Parse retry-after from error message if present
      final msg = e.toString();
      final retryMatch = RegExp(r'Try again in (\d+)s').firstMatch(msg);
      if (retryMatch != null) {
        final secs = int.tryParse(retryMatch.group(1)!);
        if (secs != null) {
          _retryAfter = secs;
          _retryUntil = DateTime.now().add(Duration(seconds: secs));
        }
      }
      setState(() {
        _error = msg;
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter your account email. We\'ll send a 6-digit code to reset your password.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
                if (_retryAfter != null && _remaining > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Retry in $_remaining s',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: (_sending || _retryAfter != null) ? null : _send,
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
