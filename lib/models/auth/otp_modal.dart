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
