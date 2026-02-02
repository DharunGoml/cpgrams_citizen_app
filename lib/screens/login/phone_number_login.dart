import 'package:cpgrams_ui_kit/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PhoneNumberLogin extends StatefulWidget {
  const PhoneNumberLogin({super.key});

  @override
  State<PhoneNumberLogin> createState() => _PhoneNumberLoginState();
}

class _PhoneNumberLoginState extends State<PhoneNumberLogin> {
  final TextEditingController _mobileNumberController = TextEditingController();

  final FocusNode _mobileNumberFocusNode = FocusNode();

  bool _disableOtpButton() {
    return _mobileNumberController.text.length < 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                focusNode: _mobileNumberFocusNode,
                hintText: "Enter your mobile number here",
                label: "Mobile Number",
                showRequiredAsterisk: true,
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: "Get Otp",
                onPressed: () {},
                type: ButtonType.primary,
                width: double.infinity,
                enabled: !_disableOtpButton(),
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
                          Navigator.pushNamed(context, '/register');
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
      ),
    );
  }
}
