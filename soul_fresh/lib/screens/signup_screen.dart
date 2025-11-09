import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/colors.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/loading_widget.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _acceptDataConsent = false;
  bool _confirmAge = false;
  DateTime? _dateOfBirth;
  String? _selectedGender;
  String? _selectedGoal;
  String? _errorMessage;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
    'Custom',
  ];
  final List<String> _goalOptions = [
    'Managing stress',
    'Improving mood',
    'Better sleep',
    'Mindfulness practice',
    'Coping with anxiety',
    'General wellness',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Calculate password strength (0.0 to 1.0)
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

  /// Get password strength label and color
  (String label, Color color) _getPasswordStrengthInfo(String password) {
    if (password.isEmpty) return ('', Colors.grey);
    final strength = _calculatePasswordStrength(password);
    if (strength < 0.4) {
      return ('Weak', AppColors.error);
    } else if (strength < 0.7) {
      return ('Medium', Colors.orange);
    } else {
      return ('Strong', Colors.green);
    }
  }

  /// Show date picker for date of birth
  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      helpText: 'Select your date of birth',
    );

    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms || !_acceptDataConsent || !_confirmAge) {
      setState(() {
        _errorMessage = 'Please accept all terms and confirmations to continue';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signup(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Navigate to OTP verification or home
      Navigator.of(context).pushReplacementNamed(
        '/otp-verification',
        arguments: {'email': _emailController.text.trim()},
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final (passwordStrength, strengthColor) =
        _getPasswordStrengthInfo(_passwordController.text);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToLogin,
        ),
        title: const Text('Create Account'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Creating your account...',
        child: SafeArea(
          child: SingleChildScrollView(
            // Add extra bottom padding so legal checkboxes & buttons remain
            // visible above the keyboard on smaller devices.
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Logo
                  const Center(
                    child: Icon(
                      Icons.self_improvement,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start your wellness journey',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.grey600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Section: Basic Information
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  // Full Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'Enter your full name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      if (value.length > 50) {
                        return 'Name must be less than 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'Enter your email',
                    ),
                    validator: Validators.email,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 24),

                  // Section: Password
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Password Setup',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  // Password field with strength indicator
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: 'At least 8 characters',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: Validators.password,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                  const SizedBox(height: 8),

                  // Password strength indicator
                  if (_passwordController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _calculatePasswordStrength(
                                  _passwordController.text,
                                ),
                                minHeight: 6,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  strengthColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            passwordStrength,
                            style: TextStyle(
                              color: strengthColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: 'Re-enter your password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section: Profile Information (Optional)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Profile Information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(Optional)',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.grey600,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Date of Birth
                  GestureDetector(
                    onTap: _selectDateOfBirth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _dateOfBirth == null
                                ? 'Date of Birth'
                                : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                            style: TextStyle(
                              color: _dateOfBirth == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender/Pronouns dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender/Pronouns',
                      prefixIcon: Icon(Icons.wc_outlined),
                      hintText: 'Select (optional)',
                    ),
                    items: _genderOptions.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Primary Goal dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGoal,
                    decoration: const InputDecoration(
                      labelText: 'Primary Mental Wellness Goal',
                      prefixIcon: Icon(Icons.psychology_outlined),
                      hintText: 'Select (optional)',
                    ),
                    items: _goalOptions.map((goal) {
                      return DropdownMenuItem(
                        value: goal,
                        child: Text(goal),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGoal = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Section: Legal & Compliance
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Legal & Compliance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  // Terms and conditions checkbox
                  _buildCheckboxTile(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                    label: 'I agree to the ',
                    linkText: 'Terms of Service',
                    linkOnTap: () => Navigator.of(context).pushNamed('/terms'),
                    suffix: ' and ',
                    linkText2: 'Privacy Policy',
                    linkOnTap2: () =>
                        Navigator.of(context).pushNamed('/privacy-policy'),
                  ),
                  const SizedBox(height: 12),

                  // Data consent checkbox
                  _buildCheckboxTile(
                    value: _acceptDataConsent,
                    onChanged: (value) {
                      setState(() {
                        _acceptDataConsent = value ?? false;
                      });
                    },
                    label:
                        'I consent to the collection and processing of my health data',
                    linkText: '',
                    linkOnTap: () {},
                  ),
                  const SizedBox(height: 12),

                  // Age confirmation checkbox
                  _buildCheckboxTile(
                    value: _confirmAge,
                    onChanged: (value) {
                      setState(() {
                        _confirmAge = value ?? false;
                      });
                    },
                    label: 'I confirm that I am 13 years or older',
                    linkText: '',
                    linkOnTap: () {},
                  ),
                  const SizedBox(height: 28),

                  // Sign up button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'Create Account',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Log In',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _navigateToLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper widget for checkbox with linked text
  Widget _buildCheckboxTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    required String linkText,
    required VoidCallback linkOnTap,
    String suffix = '',
    String linkText2 = '',
    VoidCallback? linkOnTap2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RichText(
              text: TextSpan(
                // Improve contrast & readability for legal text which was
                // reported as barely visible. Use bodyMedium with slightly
                // darker color on light background.
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      // Use withOpacity to stay compatible with Flutter 3.24 CI.
                      color: Colors.black.withOpacity(0.75),
                      height: 1.3,
                    ),
                children: [
                  TextSpan(text: label),
                  if (linkText.isNotEmpty)
                    TextSpan(
                      text: linkText,
                      style: const TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = linkOnTap,
                    ),
                  if (suffix.isNotEmpty) TextSpan(text: suffix),
                  if (linkText2.isNotEmpty)
                    TextSpan(
                      text: linkText2,
                      style: const TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = linkOnTap2,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

