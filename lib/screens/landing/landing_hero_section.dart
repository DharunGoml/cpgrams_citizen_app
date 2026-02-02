import 'package:cpgrams_ui_kit/components/custom_button.dart';
import 'package:cpgrams_ui_kit/components/images.dart';
import 'package:flutter/material.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 900,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4a4a40),
            blurRadius: 50,
            spreadRadius: -12,
          ),
        ],
      ),
      child: Stack(children: [_backgroundImage(), _compliantFormWithAI()]),
    );
  }

  Widget _backgroundImage() {
    return Image.asset(homepageBanner, fit: BoxFit.cover, height: 220);
  }

  Widget _compliantFormWithAI() {
    return Positioned(
      top: 88,
      left: 35,
      child: Container(
        width: 358,
        height: 812,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Register your ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF13316C),
                    ),
                  ),
                  TextSpan(
                    text: "compliant ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFFA500),
                    ),
                  ),
                  TextSpan(
                    text: "here ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF13316C),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "Select the option you wish to complain about",
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 0.25,
                height: 2,
                color: const Color(0xFF212180),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            _chatSection(),
            SizedBox(height: 10),
            _card(
              "Speak on the mic to register your complaints",
              "हिंदी, தமிழ், తెలుగు, অসমীয়া अन्य",
              "0xFFFBE9ED",
            ),
            SizedBox(height: 10),
            _card(
              "Upload a written letter to file your complaint",
              "Only PDF, JPG, and PNG formats are accepted",
              "0xFFEDF7E6",
            ),
            SizedBox(height: 10),
            _card(
              "Write down to register your complaint...",
              "File your complaint",
              "0xFFEEF3FE",
            ),
            SizedBox(height: 10),
            CustomButton(
              onPressed: () {},
              text: "Submit Grievance",
              width: 318,
              height: 48,
              borderRadius: 8.0,
              backgroundColor: Color(0xFF2E5090),
            ),
            SizedBox(height: 10),
            CustomButton(
              onPressed: () {},
              text: "Track Grievance",
              width: 318,
              height: 48,
              borderRadius: 8.0,
              borderColor: Color(0xFF2E5090),
              borderWidth: 1.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String subtitle, String color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 319,
        height: 99,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          color: Color(int.parse(color)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: "Noto Sans",
              ),
            ),
            SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: "Noto Sans",
                color: Color(0xFF13316C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatSection() {
    return Container(
      width: 314,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        gradient: const LinearGradient(
          colors: [Color(0xFFE8EAF6), Color(0xFFF3E5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Color(0xFF13316C), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: GradientText(
                  "Talk to the smart AI chatbot and file your complaint",
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1E3C72),
                      Color(0xFF1E3C72),
                      Color(0xFF2A5298),
                    ],
                  ),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: "Enter your complaint here...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
