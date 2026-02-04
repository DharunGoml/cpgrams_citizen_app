import 'package:cpgrams_citizen_app/utils/validator.dart';
import 'package:cpgrams_ui_kit/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PhoneRegister extends StatefulWidget {
  const PhoneRegister({super.key});

  @override
  State<PhoneRegister> createState() => _PhoneRegisterState();
}

class _PhoneRegisterState extends State<PhoneRegister> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _nameFocusNode = FocusNode();
  final _mobileNumberFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isChecked = false;
  bool isLoading = false;
  String _nameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';
  String _mobileNumberError = '';
  String _countryCode = '+91';
  bool _isButtonEnabled = false;
  bool _passwordMatch = false;
  bool _showPasswordMatchIcon = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
    _mobileNumberController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_checkPasswordMatch);
    _confirmPasswordController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _mobileNumberController.removeListener(_updateButtonState);
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_checkPasswordMatch);
    _confirmPasswordController.removeListener(_checkPasswordMatch);
    _nameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _mobileNumberFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
      _updateButtonState();
    }
  }

  void _updateButtonState() {
    final isEnabled =
        _nameController.text.isNotEmpty &&
        _mobileNumberController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _isChecked;

    if (_isButtonEnabled != isEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  void _toggleCheckbox(bool? value) {
    setState(() {
      _isChecked = value ?? false;
    });
    _updateButtonState();
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      _emailError = '';
      _passwordError = '';
      _nameError = '';
      _confirmPasswordError = '';
      _mobileNumberError = '';
    });

    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = 'Name is required';
      });
      isValid = false;
    }

    if (_mobileNumberController.text.isEmpty) {
      setState(() {
        _mobileNumberError = 'Mobile number is required';
      });
      isValid = false;
    }

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

    return isValid;
  }

  Future<void> _onSubmitRegisterDetails() async {
    if (!_validateForm()) {
      return;
    }
    //TODO: To implement the register API.
    debugPrint(
      "Submitting registration details for ${_nameController.text} with email ${_emailController.text} and mobile number $_countryCode${_mobileNumberController.text}",
    );

    setState(() {
      isLoading = false;
    });
  }

  void _onCountryCodeChanged(String countryCode) {
    _countryCode = countryCode;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Text(
              'Enter your details to Register',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                fontFamily: 'Noto Sans',
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: "Full Name",
              hintText: "Enter your full name here",
              onChanged: (value) {
                if (_nameError.isNotEmpty) {
                  setState(() {
                    _nameError = '';
                  });
                }
              },
              controller: _nameController,
              focusNode: _nameFocusNode,
              showRequiredAsterisk: true,
              errorText: _nameError.isNotEmpty ? _nameError : null,
            ),
            const SizedBox(height: 32),
            RepaintBoundary(
              child: CustomMobileNumberField(
                label: "Mobile Number",
                hintText: "Enter your mobile number here",
                onChanged: (value) {
                  if (_mobileNumberError.isNotEmpty) {
                    setState(() {
                      _mobileNumberError = '';
                    });
                  }
                },
                controller: _mobileNumberController,
                focusNode: _mobileNumberFocusNode,
                showRequiredAsterisk: true,
                onCountryCodeChanged: (value) =>
                    _onCountryCodeChanged(value.code),
                errorText: _mobileNumberError.isNotEmpty
                    ? _mobileNumberError
                    : null,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: "Email Address",
              hintText: "Enter your email ID here",
              onChanged: (value) {
                if (_emailError.isNotEmpty) {
                  setState(() {
                    _emailError = '';
                  });
                }
              },
              controller: _emailController,
              focusNode: _emailFocusNode,
              showRequiredAsterisk: true,
              errorText: _emailError.isNotEmpty ? _emailError : null,
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: "Create Password",
              hintText: "Create password",
              onChanged: (value) {
                if (_passwordError.isNotEmpty) {
                  setState(() {
                    _passwordError = '';
                  });
                }
              },
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              showRequiredAsterisk: true,
              isPassword: true,
              errorText: _passwordError.isNotEmpty ? _passwordError : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: "Confirm Password",
              onChanged: (value) {
                setState(() {
                  if (_confirmPasswordError.isNotEmpty) {
                    _confirmPasswordError = '';
                  }
                });
              },
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              showRequiredAsterisk: true,
              isPassword: false,
              obscureText: true,
              errorText: _confirmPasswordError.isNotEmpty
                  ? _confirmPasswordError
                  : null,
              suffixIcon: _showPasswordMatchIcon
                  ? Icon(
                      _passwordMatch ? Icons.check : Icons.cancel_outlined,
                      color: _passwordMatch ? Colors.green : Colors.red,
                    )
                  : null,
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCheckbox(value: _isChecked, onChanged: _toggleCheckbox),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "I agree to the ",
                      children: [
                        TextSpan(
                          text: "Terms of use ",
                          style: const TextStyle(
                            color: Color(0xFFFF7501),
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/terms-of-use');
                            },
                        ),
                        const TextSpan(text: "and have read the "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: const TextStyle(
                            color: Color(0xFFFF7501),
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/privacy-policy');
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
                ),
              ],
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: isLoading ? "Loading..." : "Continue",
              onPressed: _onSubmitRegisterDetails,
              type: ButtonType.primary,
              width: double.infinity,
              enabled: _isButtonEnabled && !isLoading,
              gradientBackground: const LinearGradient(
                colors: [
                  Color(0xFF1E3C72),
                  Color(0xFF2A5298),
                  Color(0xFF2A5298),
                ],
                tileMode: TileMode.decal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
