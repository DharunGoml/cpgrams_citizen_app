abstract class SendOtpPayload {
  Map<String, dynamic> toJson();
}

class MobileOtpPayload extends SendOtpPayload {
  final String mobileNumber;
  final String requestType;

  MobileOtpPayload({required this.mobileNumber, required this.requestType});

  @override
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'identityMobile': mobileNumber,
        'type': 'MOBILE',
        'otpRequestType': requestType,
      },
    };
  }
}

class EmailOtpPayload extends SendOtpPayload {
  final String email;
  final String requestType;

  EmailOtpPayload({required this.email, required this.requestType});

  @override
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'identityEmail': email,
        'type': 'EMAIL',
        'otpRequestType': requestType,
      },
    };
  }
}

class MobileIdentityVerify extends SendOtpPayload {
  final String mobile;
  final String requestType;

  MobileIdentityVerify({required this.mobile, required this.requestType});

  @override
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'identityMobile': mobile,
        'type': 'MOBILE',
        'otpRequestType': requestType,
      },
    };
  }
}

class VerifyOtpPayload extends SendOtpPayload {
  final String mobile;
  final String otp;
  final String name;
  final String email;

  VerifyOtpPayload({
    required this.mobile,
    required this.otp,
    required this.name,
    required this.email,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'data': {'name': name, 'email': email, 'mobile': mobile, 'otp': otp},
    };
  }
}
