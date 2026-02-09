import 'package:cpgrams_citizen_app/services/auth/auth_service.dart';
import 'package:cpgrams_citizen_app/utils/validator.dart';
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
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';
  bool _showError = false;
  bool _showSuccess = false;
  bool _passwordMatch = false;
  bool _showPasswordMatchIcon = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(_checkPasswordMatch);
    _confirmPasswordController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _emailController.removeListener(() => setState(() {}));
    _passwordController.removeListener(_checkPasswordMatch);
    _confirmPasswordController.removeListener(_checkPasswordMatch);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordMatch() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final shouldShowIcon = confirmPassword.isNotEmpty;
    final passwordMatch = password == confirmPassword && password.isNotEmpty;

    if (_showPasswordMatchIcon != shouldShowIcon ||
        _passwordMatch != passwordMatch) {
      setState(() {
        _showPasswordMatchIcon = shouldShowIcon;
        _passwordMatch = passwordMatch;
      });
    }
  }

  void _goToNextStep(String nextStep) {
    setState(() {
      _formType = nextStep;
      _errorMessage = '';
      _emailError = '';
      _passwordError = '';
      _confirmPasswordError = '';
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
      // final response = await AuthAPIService().resendPasswordRecoveryOTP(_emailController.text);

      await Future.delayed(const Duration(seconds: 1));

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

  void _handleEmailSubmit() {
    setState(() {
      _emailError = '';
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email or mobile number is required';
      });
      return;
    }

    if (!isValidEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    _goToNextStep('OTP');
  }

  void _handleOTPSubmit() {
    if (_otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
        _showError = true;
      });
      return;
    }

    _goToNextStep('Password');
  }

  Future<void> _handlePasswordSubmit() async {
    setState(() {
      _passwordError = '';
      _confirmPasswordError = '';
      _errorMessage = '';
    });

    bool isValid = true;

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      isValid = false;
    } else if (!isValidPassword(_passwordController.text)) {
      setState(() {
        _passwordError =
            'Password must be at least 8 characters with letters, numbers, and special characters';
      });
      isValid = false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Confirm Password is required';
      });
      isValid = false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      isValid = false;
    }

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await AuthAPISerivce().passwordReset(
        identifier: _emailController.text,
        otp: _otp,
        newPassword: _passwordController.text,
        conformPassword: _confirmPasswordController.text,
      );

      if (!mounted) return;
      if (response.success) {
        CustomPopup.show(
          context: context,
          title: 'Password Updated Successfully',
          titleIcon: Icons.check_circle,
          titleIconColor: Colors.green,
          buttonType: PopupButtonType.ok,
          okText: 'Login now',
          showCloseIcon: true,
          barrierDismissible: false,
          buttonWidth: 110,
          buttonHeight: 40,
          child: const Text(
            "Your password has been updated successfully. You can use your new password to login.",
            style: TextStyle(fontSize: 14.0, color: Color(0xFF424242)),
          ),
          onClose: () {
            setState(() {
              _isLoading = false;
            });
            Navigator.pop(context);
          },
          onOkPressed: () {
            setState(() {
              _isLoading = false;
            });
            Navigator.pushReplacementNamed(context, '/login/email');
          },
        );
      } else {
        setState(() {
          _errorMessage =
              response.message ?? 'Failed to reset password. Please try again.';
          _isLoading = false;
        });
      }
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
          hintText: 'Enter your email or mobile number',
          label:
              'Enter mobile number or registered email address to receive OTP',
          keyboardType: TextInputType.emailAddress,
          showRequiredAsterisk: true,
          errorText: _emailError.isNotEmpty ? _emailError : null,
          onChanged: (value) {
            if (_emailError.isNotEmpty) {
              setState(() {
                _emailError = '';
              });
            }
          },
        ),
        const SizedBox(height: 48),
        CustomButton(
          text: _isLoading ? 'Sending...' : 'Send OTP',
          onPressed: _handleEmailSubmit,
          width: double.infinity,
          enabled: _emailController.text.isNotEmpty && !_isLoading,
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
          errorText: _passwordError.isNotEmpty ? _passwordError : null,
          onChanged: (value) {
            if (_passwordError.isNotEmpty) {
              setState(() {
                _passwordError = '';
              });
            }
          },
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirm new password',
          label: 'Confirm Password',
          isPassword: false,
          obscureText: true,
          showRequiredAsterisk: true,
          errorText: _confirmPasswordError.isNotEmpty
              ? _confirmPasswordError
              : null,
          onChanged: (value) {
            if (_confirmPasswordError.isNotEmpty) {
              setState(() {
                _confirmPasswordError = '';
              });
            }
          },
          suffixIcon: _showPasswordMatchIcon
              ? Icon(
                  _passwordMatch ? Icons.check : Icons.cancel_outlined,
                  color: _passwordMatch ? Colors.green : Colors.red,
                )
              : null,
        ),
        const SizedBox(height: 48),
        CustomButton(
          text: _isLoading ? 'Resetting...' : 'Reset Password',
          onPressed: _handlePasswordSubmit,
          width: double.infinity,
          enabled:
              _passwordController.text.isNotEmpty &&
              _confirmPasswordController.text.isNotEmpty &&
              _passwordMatch &&
              !_isLoading,
          gradientBackground: const LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298), Color(0xFF2A5298)],
          ),
        ),
        if (_errorMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 14.0),
          ),
        ],
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
