import 'package:cpgrams_citizen_app/services/auth/auth_service.dart';
import 'package:cpgrams_citizen_app/utils/validator.dart';
import 'package:cpgrams_ui_kit/components/custom_button.dart';
import 'package:cpgrams_ui_kit/components/custom_popup.dart';
import 'package:cpgrams_ui_kit/components/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  State<EmailLogin> createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool isLoading = false;
  String _emailError = '';
  String _passwordError = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      _emailError = '';
      _passwordError = '';
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      isValid = false;
    } else if (!isValidEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      isValid = false;
    }

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

    return isValid;
  }

  bool _disableEmailLoginButton() {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _onSubmitEmailLoginDetails() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      final response = await AuthAPISerivce().login(
        grantType: "password",
        userName: _emailController.text,
        password: _passwordController.text,
      );
      if (response.success) {
        if (!mounted) return;
        CustomPopup.show(
          context: context,
          title: 'Login Successfully',
          titleIcon: Icons.check_circle,
          titleIconColor: Colors.green,
          buttonType: PopupButtonType.ok,
          okText: 'Done',
          showCloseIcon: true,
          barrierDismissible: false,
          buttonWidth: 100,
          buttonHeight: 40,
          child: const Text(
            "You're successfully registered! You can now log in using your phone number or email to submit grievances and track their status.",
            style: TextStyle(fontSize: 14.0, color: Color(0xFF424242)),
          ),
          onOkPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/grievance/list',
              (route) => false,
            );
          },
          onClose: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/grievance/list',
              (route) => false,
            );
          },
        );
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          _emailError = response.message ?? 'Login failed';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        _emailError = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Please enter your Email Address",
              style: TextStyle(
                fontSize: 22.0,
                fontFamily: "Noto Sans",
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48.0),
            CustomTextField(
              hintText: "Enter your email ID here",
              label: "Email Address",
              showRequiredAsterisk: true,
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError.isNotEmpty ? _emailError : null,
              onChanged: (value) {
                setState(() {
                  if (_emailError.isNotEmpty) {
                    _emailError = '';
                  }
                });
              },
            ),
            const SizedBox(height: 24.0),
            CustomTextField(
              hintText: "Enter your password",
              label: "Password",
              showRequiredAsterisk: true,
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              isPassword: true,
              errorText: _passwordError.isNotEmpty ? _passwordError : null,
              onChanged: (value) {
                setState(() {
                  if (_passwordError.isNotEmpty) {
                    _passwordError = '';
                  }
                });
              },
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: isLoading ? "Logging in..." : "Login",
              onPressed: _onSubmitEmailLoginDetails,
              type: ButtonType.primary,
              width: double.infinity,
              enabled: _disableEmailLoginButton() && !isLoading,
              gradientBackground: const LinearGradient(
                colors: [
                  Color(0xFF1E3C72),
                  Color(0xFF2A5298),
                  Color(0xFF2A5298),
                ],
                tileMode: TileMode.decal,
              ),
            ),
            const SizedBox(height: 16),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/login/email/password-recovery',
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFFFF7501),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                text: "Don't have an account?",
                children: [
                  TextSpan(
                    text: " Register Now",
                    style: const TextStyle(
                      color: Color(0xFFFF7501),
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacementNamed(context, '/register');
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
        ),
      ),
    );
  }
}
