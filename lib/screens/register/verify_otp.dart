import 'package:cpgrams_citizen_app/models/auth/otp_modal.dart';
import 'package:cpgrams_citizen_app/services/auth/auth_service.dart';
import 'package:cpgrams_ui_kit/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class VerifyOtp extends StatefulWidget {
  const VerifyOtp({super.key});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  String _emailOtp = '';
  String _phoneOtp = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _mobileNumber = '';
  String _emailAddress = '';
  String _uuid = '';

  Future<void> _onOtpResend(String type) async {
    try {
      final payload = type == "mobile"
          ? MobileOtpPayload(
              mobileNumber: _mobileNumber,
              requestType: 'REGISTER',
            )
          : EmailOtpPayload(email: _emailAddress, requestType: 'REGISTER');

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
    if (_emailOtp.length < 6 || _phoneOtp.length < 6) {
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
      final response = await AuthAPISerivce().verifyOtp(
        uuid: _uuid.isNotEmpty
            ? _uuid
            : '840c61ec-d3aa-43ce-aced-c551d087f3ee', // This should ideally come from the registration response
        emailOtp: _emailOtp,
        smsOtp: _phoneOtp,
      );

      if (response.success) {
        setState(() {
          _showSuccess = true;
          _showError = false;
          _isLoading = false;
        });

        // Show success modal
        if (!mounted) return;
        await CustomPopup.show(
          context: context,
          title: 'Register Successfully',
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
            Navigator.of(context).pop(); // Close the popup
            Navigator.of(
              context,
            ).pushReplacementNamed('/login'); // Navigate to login
          },
        );
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
    final String email = args?['email'] ?? '';
    final String uuid = args?['uuid'] ?? '';
    setState(() {
      _mobileNumber = mobileNumber;
      _emailAddress = email;
      _uuid = uuid;
    });
    return SafeArea(
      maintainBottomViewPadding: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 70),
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
            _otpHeaderSection(_mobileNumber, Icons.phone_android),
            SizedBox(height: 8.0),
            _editSection(
              icon: Icons.edit,
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(height: 13.0),
            CustomOtpField(
              length: 6,
              onChanged: (value) {
                setState(() {
                  _phoneOtp = value;
                  _showError = false;
                  _showSuccess = false;
                  _errorMessage = '';
                });
              },
              onResend: () => _onOtpResend("mobile"),
              onSubmit: _onOtpSubmit,
              errorText: _errorMessage,
              showSuccess: _showSuccess,
              showError: _showError,
              resendTimerSeconds: 120,
            ),
            SizedBox(height: 48),
            Divider(
              color: Colors.grey.shade300,
              thickness: 1.0,
              indent: 5,
              endIndent: 5,
            ),
            SizedBox(height: 48),
            _otpHeaderSection(_emailAddress, Icons.email_outlined),
            SizedBox(height: 8.0),
            _editSection(
              icon: Icons.edit,
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(height: 13.0),
            CustomOtpField(
              length: 6,
              onChanged: (value) {
                setState(() {
                  _emailOtp = value;
                  _showError = false;
                  _showSuccess = false;
                  _errorMessage = '';
                });
              },
              onResend: () => _onOtpResend("email"),
              onSubmit: _onOtpSubmit,
              errorText: _errorMessage,
              showSuccess: _showSuccess,
              showError: _showError,
              resendTimerSeconds: 120,
            ),
            SizedBox(height: 48),
            CustomButton(
              text: _isLoading ? "Verifying..." : "Verify & Login",
              enabled:
                  !_isLoading && _emailOtp.length == 6 && _phoneOtp.length == 6,
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

  Widget _otpHeaderSection(String data, IconData? icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon),
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
                text: data,
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
    );
  }

  Widget _editSection({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        CustomIconButton(
          icon: Icons.edit,
          onPressed: onPressed,
          size: 16,
          iconSize: 16,
          type: IconButtonType.secondary,
          borderWidth: 0,
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          iconColor: const Color(0xFFFF7501),
        ),
        Text(
          "Edit",
          style: TextStyle(
            color: const Color(0xFFFF7501),
            fontWeight: FontWeight.w400,
            fontFamily: "Noto Sans",
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }
}
