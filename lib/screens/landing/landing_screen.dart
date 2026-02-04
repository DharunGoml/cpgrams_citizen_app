import 'package:cpgrams_ui_kit/components/footer_section.dart';
import 'package:cpgrams_ui_kit/components/images.dart';
import 'package:flutter/material.dart';

import 'landing_hero_section.dart';


class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          HeroSection(),
          SizedBox(height: 41),
          _raiseCompliant(context),
          SizedBox(height: 16),
          _compliantsSection(),
          FooterSection(),
        ],
      ),
    );
  }

  Widget _raiseCompliant(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 400 ? 358.0 : screenWidth * 0.9;

    return SizedBox(
      width: contentWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE7E7E7)),
              ),
              child: Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(whatsAppLogo, width: 26, height: 26),
                  Text(
                    'Raise Complaint on WhatsApp',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Noto Sans',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE7E7E7)),
              ),
              child: Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_in_talk_outlined,
                    size: 24,
                    color: Colors.black,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help number',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Noto Sans',
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '1800-123-4545',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Noto Sans',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compliantsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF1E3C72), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          tileMode: TileMode.clamp,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Number of compliants",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              fontFamily: 'Noto Sans',
            ),
          ),
          SizedBox(height: 32),
          _sec(tickRounded, "12,26,178+", "Resolved Complaint"),
          SizedBox(height: 32),
          _sec(documentText, "6,78,908+", "Filed Complaint"),
          SizedBox(height: 32),
          _sec(like, "8,78,102+", "Positive Complaint"),
        ],
      ),
    );
  }

  Widget _sec(String image, String title, String subTitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white54,
          child: Image.asset(image, width: 27, height: 27, fit: BoxFit.cover),
        ),
        SizedBox(width: 20),
        Row(
          children: [
            const VerticalDivider(
              width: 20,
              thickness: 1,
              indent: 1,
              endIndent: 4,
              color: Colors.white,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Noto Sans',
                  ),
                ),
                Text(
                  subTitle,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontFamily: 'Noto Sans',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
