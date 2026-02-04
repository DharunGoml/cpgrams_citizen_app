import 'package:cpgrams_citizen_app/models/auth/otp_modal.dart';
import 'package:cpgrams_citizen_app/services/auth_service.dart';
import 'package:cpgrams_ui_kit/components/custom_otp.dart';
import 'package:cpgrams_ui_kit/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginOtp extends StatefulWidget {
  const LoginOtp({super.key});

  @override
  State<LoginOtp> createState() => _LoginOtpState();
}

class _LoginOtpState extends State<LoginOtp> {
  String _otp = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _mobileNumber = '';

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
      final payload = MobileOtpPayload(
        mobileNumber: _mobileNumber,
        requestType: 'LOGIN',
      );

      final response = await AuthAPISerivce().resendOtp(payload);
      if (!mounted) return;
      if (response.success) {
        setState(() {
          _showError = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to resend OTP.';
          _showError = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _showError = true;
      });
      debugPrint('OTP Resend Error: $e');
    }
  }

  Future<void> _onOtpSubmit() async {
    if (_otp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP.';
        _showError = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      final response = await AuthAPISerivce().login(
        grantType: 'otp',
        userName: _mobileNumber,
        password: _otp,
      );

      if (response.success) {
        setState(() {
          _showSuccess = true;
          _showError = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'OTP verification failed.';
          _showError = true;
          _showSuccess = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _showError = true;
        _isLoading = false;
      });
      debugPrint('OTP Submission Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String mobileNumber = args?['mobileNumber'] ?? '';
    setState(() {
      _mobileNumber = mobileNumber;
    });
    return SafeArea(
      maintainBottomViewPadding: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 120),
            Row(
              spacing: 12.0,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomIconButton(
                  icon: Icons.arrow_back,
                  type: IconButtonType.secondary,
                  size: 32,
                  borderRadius: 24,
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                ),
                Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF212121),
                  ),
                ),
              ],
            ),
            SizedBox(height: 48),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.phone_android, size: 24, color: Colors.black),
                SizedBox(width: 8.0),
                RichText(
                  text: TextSpan(
                    text: 'Please enter the OTP sent to ',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400,
                    ),
                    children: [
                      TextSpan(
                        text: _mobileNumber,
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 13.0),
            CustomOtpField(
              length: 6,
              onChanged: _onOtpChanged,
              onResend: _onOtpResend,
              onSubmit: _onOtpSubmit,
              errorText: _errorMessage,
              showSuccess: _showSuccess,
              showError: _showError,
              resendTimerSeconds: 120,
            ),
            SizedBox(height: 48),
            CustomButton(
              text: _isLoading ? "Verifying..." : "Verify & Login",
              enabled: !_isLoading && _otp.length == 6,
              onPressed: _onOtpSubmit,
              width: double.infinity,
              // loading: _isLoading,
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
