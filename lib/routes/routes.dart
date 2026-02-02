import 'package:cpgrams_citizen_app/layout/login_layout.dart';
import 'package:cpgrams_citizen_app/layout/register_layout.dart';
import 'package:cpgrams_citizen_app/screens/landing/landing_screen.dart';
import 'package:cpgrams_citizen_app/screens/login/email_login.dart';
import 'package:cpgrams_citizen_app/screens/login/login_flow.dart';
import 'package:cpgrams_citizen_app/screens/login/login_otp.dart';
import 'package:cpgrams_citizen_app/screens/login/phone_number_login.dart';
import 'package:cpgrams_citizen_app/screens/register/register.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/landing': (context) => LandingScreen(),
  '/register': (context) => RegisterLayout(child: RegisterScreen()),
  '/login': (context) => LoginLayout(child: LoginScreen()),
  '/login/email': (context) => LoginLayout(child: EmailLogin()),
  '/login/phone': (context) => LoginLayout(child: PhoneNumberLogin()),
  '/login/phone/otp': (context) => LoginLayout(child: LoginOtp()),
};
