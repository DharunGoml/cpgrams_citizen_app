import 'package:cpgrams_citizen_app/models/grievances/grievance_modal.dart';
import 'package:cpgrams_citizen_app/services/grievances/grievance_service.dart';
import 'package:cpgrams_citizen_app/utils/secure_storage.dart';
import 'package:cpgrams_ui_kit/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrackGrievance extends StatefulWidget {
  const TrackGrievance({super.key});

  @override
  State<TrackGrievance> createState() => _TrackGrievanceState();
}

class _TrackGrievanceState extends State<TrackGrievance> {
  String _errorMessage = "";
  List<dynamic>? _grievanceTrackList = [];

  @override
  void initState() {
    _fetchGrievanceTrackList();
    setState(() {
      _errorMessage = "";
      _grievanceTrackList = [];
    });
    super.initState();
  }

  Future<void> _fetchGrievanceTrackList() async {
    try {
      final deskId = await SecureStorage.userId ?? "";
      final payload = GrievanceListModal(deskId: deskId);

      final response = await GrievanceService().getGrievanceTrackList(payload);
      if (response.success) {
        final data = response.data;
        setState(() {
          _grievanceTrackList = data?["items"] as List<dynamic>?;
          _errorMessage = "";
        });
        // Handle the successful response data as needed
      } else {
        setState(() {
          _errorMessage =
              response.message ?? "Failed to fetch grievance track list.";
          _showErrorSnackbar(_errorMessage);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _showErrorSnackbar(_errorMessage);
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomHeader(
            variant: HeaderVariant.protected,
            title: "Track Grievance",
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Color(0xFF1E3C72),
                ),
                onPressed: () {},
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: "Search",
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    CustomIconButton(
                      icon: Icons.filter_alt_outlined,
                      onPressed: () {},
                      iconColor: const Color(0xFFFF7501),
                      backgroundColor: Colors.white,
                      borderColor: const Color(0xFFDDDDDD),
                      size: 42.0,
                    ),
                    const SizedBox(width: 12.0),
                    CustomIconButton(
                      icon: Icons.add_rounded,
                      onPressed: () {},

                      size: 42.0,
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                ListView.builder(
                  itemCount: _grievanceTrackList?.length ?? 0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final grievance = _grievanceTrackList?[index];
                    return _card(
                      grievance?['registrationNo'] ?? "N/A",
                      grievance?['title'] ?? "N/A",
                      grievance?['status'] ?? "N/A",
                      grievance?['entityName'] ?? "N/A",
                      grievance?['categoryName'] ?? "N/A",
                      grievance?['createdAt'] ?? "N/A",
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      // If dateStr is "N/A" or null, DateTime.tryParse returns null
      DateTime? parsedDate = DateTime.tryParse(dateStr);
      if (parsedDate != null) {
        return DateFormat('dd MMM yyyy').format(parsedDate);
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    }
    return "N/A";
  }

  Widget _card(
    String grievanceId,
    String subject,
    String status,
    String ministry,
    String category,
    String submissionDate,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0.26,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20.0,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Grievance ID",
                      style: TextStyle(
                        fontFamily: "Noto Sans",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF727272),
                      ),
                    ),
                    Text(
                      grievanceId,
                      style: TextStyle(
                        fontFamily: "Noto Sans",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFF7501),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFFF7501),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date of Submission",
                      style: TextStyle(
                        fontFamily: "Noto Sans",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF727272),
                      ),
                    ),
                    Text(
                      _formatDate(submissionDate),
                      style: TextStyle(
                        fontFamily: "Noto Sans",
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                        color: const Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Grievance Subject",
                  style: TextStyle(
                    fontFamily: "Noto Sans",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF727272),
                  ),
                ),
                Text(
                  subject,
                  style: TextStyle(
                    fontFamily: "Noto Sans",
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                    color: const Color(0xFF212121),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ministry/Department",
                  style: TextStyle(
                    fontFamily: "Noto Sans",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF727272),
                  ),
                ),
                Text(
                  ministry,
                  style: TextStyle(
                    fontFamily: "Noto Sans",
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                    color: const Color(0xFF212121),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Category",
                  style: TextStyle(
                    fontFamily: "Noto Sans",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF727272),
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    fontFamily: "Noto Sans",
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                    color: const Color(0xFF212121),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Grievance Status",
                  style: TextStyle(
                    fontFamily: "Noto Sans",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF727272),
                  ),
                ),
                Text(status),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  text: "View Grievance",
                  onPressed: () {},
                  type: ButtonType.secondary,
                  suffixIcon: Icons.arrow_forward_ios_rounded,
                  width: 270.0,
                ),
                CustomIconButton(
                  icon: Icons.notifications_none_rounded,
                  onPressed: () {},
                  iconColor: const Color(0xFFFF7501),
                  backgroundColor: Colors.transparent,
                  borderColor: const Color(0xFFFF7501),
                  size: 42.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
