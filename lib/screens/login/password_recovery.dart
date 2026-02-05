import 'package:cpgrams_ui_kit/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PasswordRecovery extends StatefulWidget {
  const PasswordRecovery({super.key});

  @override
  State<PasswordRecovery> createState() => _PasswordRecoveryState();
}

class _PasswordRecoveryState extends State<PasswordRecovery> {
  String _formType = 'Email'; // 'Email', 'OTP', 'Password'
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _otp = '';
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showError = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Move to next step after successful response
  void _goToNextStep(String nextStep) {
    setState(() {
      _formType = nextStep;
      _errorMessage = '';
      _showError = false;
      _showSuccess = false;
    });
  }

  void _onOtpChanged(String value) {
    setState(() {
      _otp = value;
      _showError = false;
      _showSuccess = false;
      _errorMessage = '';
    });
  }

  Future<void> _onOtpResend() async {
    try {
      // TODO: Call your API to resend OTP
      // final response = await AuthAPIService().resendPasswordRecoveryOTP(_emailController.text);

      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (!mounted) return;

      setState(() {
        _showError = false;
        _errorMessage = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP has been resent successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to resend OTP. Please try again.';
        _showError = true;
      });
      debugPrint('OTP Resend Error: $e');
    }
  }

  Future<void> _handleEmailSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // TODO: Call your API to send OTP
      // final response = await AuthAPIService().sendPasswordRecoveryOTP(_emailController.text);

      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (!mounted) return;

      // If successful, move to OTP verification
      _goToNextStep('OTP');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleOTPSubmit() async {
    if (_otp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP.';
        _showError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _showError = false;
    });

    try {
      // TODO: Call your API to verify OTP
      // final response = await AuthAPIService().verifyPasswordRecoveryOTP(_emailController.text, _otp);

      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (!mounted) return;

      setState(() {
        _showSuccess = true;
        _isLoading = false;
      });

      // If successful, move to password reset
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      _goToNextStep('Password');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
        _showError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePasswordSubmit() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // TODO: Call your API to reset password
      // final response = await AuthAPIService().resetPassword(_emailController.text, _passwordController.text);

      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (!mounted) return;

      // Show success message and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully!')),
      );

      Navigator.pushReplacementNamed(context, '/login/email');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to reset password. Please try again.';
        _isLoading = false;
      });
    }
  }

  Widget _getPasswordRecoveryBody() {
    switch (_formType) {
      case 'Email':
        return _emailFormWidget();
      case 'OTP':
        return _otpFormWidget();
      case 'Password':
        return _passwordFormWidget();
      default:
        return _emailFormWidget();
    }
  }

  Widget _emailFormWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 120),
        const Text(
          'Password Recovery',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212121),
          ),
        ),

        const SizedBox(height: 48),
        CustomTextField(
          controller: _emailController,
          hintText: 'Enter your email',
          label:
              'Enter mobile number or registered email address to receive OTP',
          keyboardType: TextInputType.emailAddress,
          showRequiredAsterisk: true,
          errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
        ),
        const SizedBox(height: 48),
        CustomButton(
          text: _isLoading ? 'Sending...' : 'Send OTP',
          onPressed: _handleEmailSubmit,
          width: double.infinity,
          enabled: !_isLoading,
          gradientBackground: const LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298), Color(0xFF2A5298)],
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            text: "Remember Password?",
            children: [
              TextSpan(
                text: " Login Now",
                style: const TextStyle(
                  color: Color(0xFFFF7501),
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, '/login/email');
                  },
              ),
            ],
            style: const TextStyle(
              color: Color(0xFF727272),
              fontSize: 14.0,
              fontFamily: 'Noto Sans',
            ),
          ),
        ),
      ],
    );
  }

  Widget _otpFormWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 120),
        Text(
          "Please Verify OTP",
          style: const TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 22.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 48),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android, size: 24, color: Colors.black),
            const SizedBox(width: 8.0),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'Please enter OTP sent to ',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade400,
                  ),
                  children: [
                    TextSpan(
                      text: _emailController.text,
                      style: const TextStyle(
                        fontFamily: 'Noto Sans',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13.0),
        CustomOtpField(
          length: 6,
          onChanged: _onOtpChanged,
          onResend: _onOtpResend,
          onSubmit: () => _handleOTPSubmit(),
          errorText: _errorMessage,
          showSuccess: _showSuccess,
          showError: _showError,
          resendTimerSeconds: 120,
        ),
        const SizedBox(height: 48),
        CustomButton(
          text: _isLoading ? 'Verifying...' : 'Verify & Continue',
          onPressed: _handleOTPSubmit,
          width: double.infinity,
          enabled: _otp.length == 6 && !_isLoading,
          gradientBackground: const LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298), Color(0xFF2A5298)],
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            text: "Remember Password?",
            children: [
              TextSpan(
                text: " Login Now",
                style: const TextStyle(
                  color: Color(0xFFFF7501),
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, '/login/email');
                  },
              ),
            ],
            style: const TextStyle(
              color: Color(0xFF727272),
              fontSize: 14.0,
              fontFamily: 'Noto Sans',
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordFormWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 120),
        const Text(
          'Reset Password',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Please enter your new password.',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 16,
            color: Color(0xFF727272),
          ),
        ),
        const SizedBox(height: 48),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Enter new password',
          label: 'New Password',
          isPassword: true,
          showRequiredAsterisk: true,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirm new password',
          label: 'Confirm Password',
          isPassword: true,
          showRequiredAsterisk: true,
          errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
        ),
        const SizedBox(height: 48),
        CustomButton(
          text: _isLoading ? 'Resetting...' : 'Reset Password',
          onPressed: _handlePasswordSubmit,
          width: double.infinity,
          enabled: !_isLoading,
          gradientBackground: const LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298), Color(0xFF2A5298)],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: _getPasswordRecoveryBody(),
      ),
    );
  }
}
