import 'package:cpgrams_citizen_app/layout/landing_layout.dart';
import 'package:cpgrams_citizen_app/layout/login_layout.dart';
import 'package:cpgrams_citizen_app/layout/register_layout.dart';
import 'package:cpgrams_citizen_app/layout/citizen_layout.dart';
import 'package:cpgrams_citizen_app/screens/grievances/track_grievance/track_grievance.dart';
import 'package:cpgrams_citizen_app/screens/landing/landing_screen.dart';
import 'package:cpgrams_citizen_app/screens/login/email_login.dart';
import 'package:cpgrams_citizen_app/screens/login/login_flow.dart';
import 'package:cpgrams_citizen_app/screens/login/login_otp.dart';
import 'package:cpgrams_citizen_app/screens/login/password_recovery.dart';
import 'package:cpgrams_citizen_app/screens/login/phone_number_login.dart';
import 'package:cpgrams_citizen_app/screens/register/phone_register.dart';
import 'package:cpgrams_citizen_app/screens/register/register.dart';
import 'package:cpgrams_citizen_app/screens/register/verify_otp.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/landing': (context) => LandingLayout(child: LandingScreen()),
  '/register': (context) => RegisterLayout(child: RegisterScreen()),
  '/register/phone': (context) => RegisterLayout(child: PhoneRegister()),
  '/register/phone/otp': (context) => RegisterLayout(child: VerifyOtp()),
  '/login': (context) => LoginLayout(child: LoginScreen()),
  '/login/email': (context) => LoginLayout(child: EmailLogin()),
  '/login/phone': (context) => LoginLayout(child: PhoneNumberLogin()),
  '/login/phone/otp': (context) => LoginLayout(child: LoginOtp()),
  '/login/email/password-recovery': (context) =>
      LoginLayout(child: PasswordRecovery()),
  '/grievance/list': (context) => CitizenLayout(child: TrackGrievance()),
};
