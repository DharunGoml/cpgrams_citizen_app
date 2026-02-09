import 'package:cpgrams_citizen_app/models/auth/otp_modal.dart';
import 'package:cpgrams_ui_kit/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../services/auth/auth_service.dart';

class PhoneNumberLogin extends StatefulWidget {
  const PhoneNumberLogin({super.key});

  @override
  State<PhoneNumberLogin> createState() => _PhoneNumberLoginState();
}

class _PhoneNumberLoginState extends State<PhoneNumberLogin> {
  final TextEditingController _mobileNumberController = TextEditingController();

  final FocusNode _mobileNumberFocusNode = FocusNode();
  String errorMessage = '';
  bool isLoading = false;
  late String _countryCode = '+91';

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _mobileNumberFocusNode.dispose();
    super.dispose();
  }

  bool _disableOtpButton() {
    return _mobileNumberController.text.length < 2;
  }

  void _onGetOtpPressed() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final payload = MobileOtpPayload(
      mobileNumber: '$_countryCode${_mobileNumberController.text}',
      requestType: "LOGIN",
    );

    final response = await AuthAPISerivce().sendOtp(payload);
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (response.success) {
      Navigator.pushNamed(
        context,
        '/login/phone/otp',
        arguments: {
          'mobileNumber': '$_countryCode${_mobileNumberController.text}',
        },
      );
    } else {
      setState(() {
        errorMessage = response.message ?? 'Failed to send OTP';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 120),
            Text(
              "Please enter your Mobile Number",
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            CustomMobileNumberField(
              controller: _mobileNumberController,
              onChanged: (value) {
                setState(() {
                  errorMessage = '';
                });
              },
              onCountryCodeChanged: (value) {
                setState(() {
                  _countryCode = value.code;
                });
              },
              focusNode: _mobileNumberFocusNode,
              hintText: "Enter your mobile number here",
              label: "Mobile Number",
              showRequiredAsterisk: true,
              errorText: errorMessage.isNotEmpty ? errorMessage : null,
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: isLoading ? "Sending..." : "Get Otp",
              onPressed: _onGetOtpPressed,
              type: ButtonType.primary,
              width: double.infinity,
              enabled: !_disableOtpButton() && !isLoading,
              // isLoading: isLoading,
              gradientBackground: LinearGradient(
                colors: [
                  const Color(0xFF1E3C72),
                  const Color(0xFF2A5298),
                  const Color(0xFF2A5298),
                ],
                tileMode: TileMode.decal,
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                text: "Don't have an account?",
                children: [
                  TextSpan(
                    text: " Register Now",
                    style: TextStyle(
                      color: const Color(0xFFFF7501),
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                  ),
                ],
                style: TextStyle(
                  color: const Color(0xFF727272),
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
