import 'package:cpgrams_ui_kit/main.dart';
import 'package:flutter/material.dart';

class ExclusionPopup {
  static bool _confirmExclusion = false;

  static void show(BuildContext context) {
    _confirmExclusion = false;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CustomPopup(
              title: "List of Exclusion",
              titleStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                fontFamily: "Noto Sans",
                color: Color(0xFFB7131A),
              ),
              titleIcon: Icons.error_outline_rounded,
              titleIconColor: const Color(0xFFB7131A),
              buttonType: PopupButtonType.ok,
              buttonAlignment: ButtonAlignment.left,
              okText: "Confirm",
              titleIconSize: 24.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Topics below will not be treated as grievances",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Noto Sans",
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FA),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildBulletPoint("RTI matters"),
                        _buildBulletPoint("Court related / Subjudice matters"),
                        _buildBulletPoint("Religious matters"),
                        _buildBulletPoint(
                          "Grievances of Government employees concerning their service matters including disciplinary proceedings etc.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CustomCheckbox(
                          value: _confirmExclusion,
                          onChanged: (value) {
                            setDialogState(() {
                              _confirmExclusion = value ?? false;
                            });
                          },
                          activeColor: Colors.orange.shade600,
                          size: 24.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Expanded(
                        child: Text(
                          "I confirm that my grievance does not fall under the listed exclusions",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Noto Sans",
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              fontFamily: "Noto Sans",
              color: Color(0xFF212121),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                fontFamily: "Noto Sans",
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
