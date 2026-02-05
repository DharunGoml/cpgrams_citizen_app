import 'package:cpgrams_citizen_app/screens/sso/sso_webview.dart';
import 'package:cpgrams_citizen_app/services/auth_service.dart';
import 'package:cpgrams_ui_kit/components/custom_button.dart';
import 'package:cpgrams_ui_kit/components/custom_dropdown.dart';
import 'package:cpgrams_ui_kit/components/images.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: RegisterFlow());
  }
}

class RegisterFlow extends StatefulWidget {
  const RegisterFlow({super.key});

  @override
  State<RegisterFlow> createState() => _RegisterFlowState();
}

class _RegisterFlowState extends State<RegisterFlow> {
  DropdownItem? selectedLanguage;
  final List<DropdownItem> languages = [
    DropdownItem(label: 'English', value: 'en', icon: Icons.language),
    DropdownItem(label: 'हिन्दी', value: 'hindi', icon: Icons.language),
  ];

  Future<void> _handleFetchSSO(String ssoType) async {
    try {
      final loginUrl = await AuthAPISerivce().fetchSSOLoginUrl(ssoType);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SSOLoginWebView(initialUrl: loginUrl),
        ),
      );
    } catch (e) {
      debugPrint('Error fetching SSO URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16.0,
            children: [
              Text(
                'Choose your language',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Noto Sans',
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CustomDropDown(
                items: languages,
                selectedItem: selectedLanguage,
                hint: 'Select Language',
                onChanged: (item) {
                  setState(() {
                    selectedLanguage = item;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: ${item.label}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                width: 150,
                borderColor: const Color(0xFF2E5090),
              ),
            ],
          ),
          const SizedBox(height: 80),
          CustomButton(
            text: "Register with Phone No.",
            onPressed: () {
              Navigator.pushNamed(context, '/register/phone');
            },
            type: ButtonType.primary,
            icon: Icons.phone,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
            gradientBackground: LinearGradient(
              colors: [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
              tileMode: TileMode.decal,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 8.0,
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  indent: 30,
                  endIndent: 10,
                  thickness: 1,
                ),
              ),
              Text(
                "or continue with Single sign-on (SSO)",
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF727272),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  indent: 10,
                  endIndent: 30,
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _iconLogin(
            () => _handleFetchSSO("janParichay"),
            janparichayLogo,
            null,
            202.0,
            null,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 20.0,
            children: [
              _iconLogin(() {}, googleLogo, null, 68.0, 68.0),
              _iconLogin(() {}, facebookLogo, null, 68.0, 68.0),
              _iconLogin(() {}, twitterLogo, null, 68.0, 68.0),
            ],
          ),
          const SizedBox(height: 24.0),
          RichText(
            text: TextSpan(
              text: "Already have an account?",
              children: [
                TextSpan(
                  text: " Log In",
                  style: TextStyle(
                    color: const Color(0xFFFF7501),
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushReplacementNamed(context, '/login');
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
    );
  }

  Widget _iconLogin(
    VoidCallback onPressed,
    String iconPath,
    EdgeInsetsGeometry? padding,
    double width,
    double? height,
  ) {
    return Container(
      width: width,
      height: height ?? 68,
      padding:
          padding ?? EdgeInsets.symmetric(vertical: 16.0, horizontal: 18.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: IconButton(
        icon: Image.asset(iconPath),
        padding: EdgeInsets.zero,
        splashRadius: (width + (height ?? 68)) / 2,
        onPressed: onPressed,
      ),
    );
  }
}
