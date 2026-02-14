import 'package:cpgrams_citizen_app/models/auth/otp_modal.dart';
import 'package:cpgrams_citizen_app/services/grievances/grievance_service.dart';
import 'package:cpgrams_ui_kit/main.dart';
import 'package:flutter/material.dart';

/// Widget for handling OTP verification for complainant mobile numbers
class OtpVerificationWidget {
  static const _primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3C72), Color(0xFF2A5298), Color(0xFF2A5298)],
  );

  /// Send OTP to complainant's phone number
  static Future<bool> sendOtp(String phone, BuildContext context) async {
    try {
      final payload = MobileIdentityVerify(
        mobile: phone,
        requestType: "MOBILE_IDENTITY_VERIFY",
      );

      final response = await GrievanceService().sendOtp(payload.toJson());

      if (response.success) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("[OtpVerificationWidget] Error sending OTP: $e");
      return false;
    }
  }

  /// Verify OTP and return the verification result
  static Future<Map<String, dynamic>?> verifyOtp(
    String phone,
    String otp,
    String name,
    String email,
  ) async {
    try {
      final payload = VerifyOtpPayload(
        mobile: phone,
        otp: otp,
        name: name,
        email: email,
      );
      final response = await GrievanceService().verifyOtp(payload);

      if (response.success) {
        debugPrint("[OtpVerificationWidget] OTP verified successfully");
        return {'success': true, 'uuid': response.data?['uuid']};
      } else {
        return {'success': false, 'message': response.message ?? 'Invalid OTP'};
      }
    } catch (e) {
      debugPrint("[OtpVerificationWidget] Error verifying OTP: $e");
      return {
        'success': false,
        'message': 'Failed to verify OTP. Please try again.',
      };
    }
  }

  /// Show OTP verification dialog
  static Future<Map<String, dynamic>?> showOtpDialog({
    required BuildContext context,
    required String phone,
    required String name,
    required String email,
    required int compliantIndex,
  }) async {
    String otp = '';
    bool isVerifyingOtp = false;
    String otpErrorMessage = '';
    bool otpVerificationSuccess = false;

    // Send OTP first
    final otpSent = await sendOtp(phone, context);
    if (!otpSent) {
      return null;
    }

    if (!context.mounted) return null;

    return showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return CustomPopup(
            popupWidth: double.infinity,
            buttonType: PopupButtonType.none,
            title: "Verify OTP",
            child: _buildOtpPopupContent(
              mobileNumber: phone,
              otp: otp,
              isVerifyingOtp: isVerifyingOtp,
              otpErrorMessage: otpErrorMessage,
              otpVerificationSuccess: otpVerificationSuccess,
              setDialogState: setDialogState,
              onOtpChanged: (value) {
                setDialogState(() {
                  otp = value;
                  if (value.length < 6) {
                    otpErrorMessage = '';
                  }
                });
              },
              onOtpResend: () async {
                setDialogState(() {
                  otp = '';
                  otpErrorMessage = '';
                  otpVerificationSuccess = false;
                });
                await sendOtp(phone, context);
              },
              onOtpSubmit: () async {
                if (otp.length == 6 && !isVerifyingOtp) {
                  setDialogState(() {
                    isVerifyingOtp = true;
                    otpErrorMessage = '';
                    otpVerificationSuccess = false;
                  });

                  final result = await verifyOtp(phone, otp, name, email);

                  if (result != null && result['success'] == true) {
                    setDialogState(() {
                      otpVerificationSuccess = true;
                      isVerifyingOtp = false;
                    });

                    await Future.delayed(const Duration(seconds: 2));

                    if (context.mounted) {
                      Navigator.of(context).pop({
                        'success': true,
                        'uuid': result['uuid'],
                        'compliantIndex': compliantIndex,
                      });
                    }
                  } else {
                    setDialogState(() {
                      otpErrorMessage = result?['message'] ?? 'Invalid OTP';
                      isVerifyingOtp = false;
                    });
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  static Widget _buildOtpPopupContent({
    required String mobileNumber,
    required String otp,
    required bool isVerifyingOtp,
    required String otpErrorMessage,
    required bool otpVerificationSuccess,
    required StateSetter setDialogState,
    required ValueChanged<String> onOtpChanged,
    required VoidCallback onOtpResend,
    required VoidCallback onOtpSubmit,
  }) {
    final bool isOtpValid = otp.length == 6;
    final bool hasError = otpErrorMessage.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOtpHeader(mobileNumber),
        const SizedBox(height: 13.0),
        _buildOtpInputField(
          otp: otp,
          otpErrorMessage: otpErrorMessage,
          otpVerificationSuccess: otpVerificationSuccess,
          onChanged: onOtpChanged,
          onResend: onOtpResend,
          onSubmit: onOtpSubmit,
          hasError: hasError,
        ),
        const SizedBox(height: 48),
        _buildVerifyButton(
          isEnabled: isOtpValid && !isVerifyingOtp,
          isLoading: isVerifyingOtp,
          onPressed: onOtpSubmit,
        ),
      ],
    );
  }

  static Widget _buildOtpHeader(String mobileNumber) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.phone_android, size: 20, color: Colors.black),
        const SizedBox(width: 8.0),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'Please enter the OTP sent to ',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade400,
              ),
              children: [
                TextSpan(
                  text: mobileNumber,
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildOtpInputField({
    required String otp,
    required String otpErrorMessage,
    required bool otpVerificationSuccess,
    required ValueChanged<String> onChanged,
    required VoidCallback onResend,
    required VoidCallback onSubmit,
    required bool hasError,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final fieldWidth = (availableWidth - 50) / 6;
        final responsiveFieldWidth = fieldWidth.clamp(35.0, 48.0);

        return SizedBox(
          width: double.infinity,
          child: CustomOtpField(
            length: 6,
            fieldSpacing: 10.0,
            fieldWidth: responsiveFieldWidth,
            onChanged: onChanged,
            onResend: onResend,
            onSubmit: onSubmit,
            errorText: otpErrorMessage,
            showSuccess: otpVerificationSuccess,
            showError: hasError,
            resendTimerSeconds: 120,
          ),
        );
      },
    );
  }

  static Widget _buildVerifyButton({
    required bool isEnabled,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return CustomButton(
      text: isLoading ? "Verifying..." : "Verify",
      enabled: isEnabled,
      onPressed: onPressed,
      width: double.infinity,
      gradientBackground: _primaryGradient,
    );
  }
}
