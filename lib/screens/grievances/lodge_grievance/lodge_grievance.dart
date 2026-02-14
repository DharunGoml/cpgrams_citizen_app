import 'dart:convert';

import 'package:cpgrams_citizen_app/models/form/form_modal.dart';
import 'package:cpgrams_citizen_app/models/grievances/compliant_data_modal.dart';
import 'package:cpgrams_citizen_app/models/grievances/draft_modal.dart';
import 'package:cpgrams_citizen_app/models/grievances/location_modal.dart';
import 'package:cpgrams_citizen_app/screens/grievances/lodge_grievance/widgets/document_upload_widget.dart';
import 'package:cpgrams_citizen_app/screens/grievances/lodge_grievance/widgets/otp_verification_widget.dart';
import 'package:cpgrams_citizen_app/services/form/form.dart';
import 'package:cpgrams_citizen_app/services/grievances/grievance_service.dart';
import 'package:cpgrams_citizen_app/utils/secure_storage.dart';
import 'package:cpgrams_citizen_app/utils/snackbar_helper.dart';
import 'package:cpgrams_citizen_app/utils/validator.dart';
import 'package:cpgrams_ui_kit/main.dart';
import 'package:flutter/material.dart';

import 'widgets/exclusion_popup.dart';
//1
// draft
// summary
// spam detection
// duplicate detection
// taxonamy
//2 search

class LodgeGrievance extends StatefulWidget {
  const LodgeGrievance({super.key});

  @override
  State<LodgeGrievance> createState() => _LodgeGrievanceState();
}

class _LodgeGrievanceState extends State<LodgeGrievance> {
  static const _primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3C72), Color(0xFF2A5298), Color(0xFF2A5298)],
  );

  static const _orangeColor = Color(0xFFFB8C00);
  static const _primaryBlueColor = Color(0xFF1E3C72);
  static const _pinkColor = Color(0xFFDF3A5C);
  static const _successGreenColor = Color(0xFF4CAF50);
  static const _verifyOrangeColor = Color(0xFFFF7501);

  final TextEditingController _grievanceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final FocusNode _grievanceFocusNode = FocusNode();

  List<DropdownItem> _states = [];
  String _formId = "";
  final List<CompliantDataModal> _compliants = [];
  final List<Map<String, dynamic>> _compliantsList = [];
  final List<Map<String, dynamic>> _attachments = [];
  LocationModal locationModal = LocationModal(
    villageCityTown: "",
    district: "",
    state: "Tamil Nadu",
    pincode: 0,
  );

  String _filePickerError = '';
  bool _isUploadingFiles = false;
  String _draftId = '';

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeForm() {
    _compliants.add(CompliantDataModal(order: 0));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExclusionPopup.show(context);
      _fetchFormData();
    });
  }

  void _disposeControllers() {
    for (var compliant in _compliants) {
      compliant.dispose();
    }
    _grievanceController.dispose();
    _grievanceFocusNode.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
  }

  Future<void> _fetchFormData() async {
    try {
      final payload = FormModal(
        formType: FormType.name,
        formName: "WEB_LODGE_GRIEVANCE_FORM",
      );
      final response = await FormService().getFormData(payload);
      final userDetailsString = await SecureStorage.userDetails;

      if (userDetailsString != null && userDetailsString.isNotEmpty) {
        try {
          final userDetails =
              json.decode(userDetailsString) as Map<String, dynamic>;
          final username = userDetails['username'] as String? ?? '';
          final firstName = userDetails['first_name'] as String? ?? '';
          final lastName = userDetails['last_name'] as String? ?? '';

          _compliants[0].phoneController.text = username;
          _compliants[0].nameController.text = '$firstName $lastName'.trim();
        } catch (e) {
          debugPrint('[LodgeGrievance] Error parsing user details: $e');
        }
      }

      final fields = response.data?['sections']?[0]?['fields'] ?? [];
      _formId = response.data?['id'] ?? "";

      setState(() {
        final stateField = fields
            .where(
              (field) => field['id'] == '7aeeaa6d-3d97-446c-9ae1-4b192aa72be4',
            )
            .toList()
            .cast<Map<String, dynamic>>();

        _states = stateField.isNotEmpty
            ? (stateField[0]['options'] as List)
                  .map<DropdownItem>(
                    (option) => DropdownItem(
                      label: option['key'],
                      value: option['value'],
                    ),
                  )
                  .toList()
            : [];
      });
    } catch (e) {
      debugPrint('[LodgeGrievance] Error fetching form data: $e');
    }
  }

  Future<void> _verifyCompliant(int index) async {
    final compliant = _compliants[index];
    final email = compliant.emailController.text.trim();
    final phone = compliant.phoneController.text.trim();
    final name = compliant.nameController.text.trim();

    String? nameError;
    String? phoneError;
    String? emailError;

    if (name.isEmpty) {
      nameError = "Name is required";
    } else if (phone.isEmpty) {
      phoneError = "Phone number is required";
    } else if (!phone.contains('+')) {
      phoneError = "Phone number should include country code";
    } else if (email.isEmpty) {
      emailError = "Email is required";
    } else if (!isValidEmail(email)) {
      emailError = "Please enter a valid email";
    }

    setState(() {
      compliant.emailErrorText = emailError ?? '';
      compliant.phoneErrorText = phoneError ?? '';
      compliant.nameErrorText = nameError ?? '';
    });

    if (nameError == null && phoneError == null && emailError == null) {
      final result = await OtpVerificationWidget.showOtpDialog(
        context: context,
        phone: phone,
        name: name,
        email: email,
        compliantIndex: index,
      );

      if (result != null && result['success'] == true) {
        _compliantsList.add({'orderNo': index + 1, 'id': result['uuid']});

        setState(() {
          _compliants[index].isVerified = true;
        });
      }
    }
  }

  void _addCompliant() {
    setState(() {
      _compliants.add(CompliantDataModal(order: _compliants.length));
    });
  }

  Future<void> _handleSubmitGrievance() async {
    try {
      // Step 1: Save draft first
      await _handleSaveDraft();

      if (_draftId.isEmpty) {
        if (mounted) {
          SnackBarHelper.showError(
            context,
            'Failed to save draft. Please try again.',
          );
        }
        return;
      }

      // Step 2: Check for spam
      final spamResponse = await GrievanceService().spamDetection(
        _grievanceController.text,
      );

      if (!spamResponse.success) {
        if (mounted) {
          SnackBarHelper.showError(
            context,
            spamResponse.message ?? 'Failed to verify grievance',
          );
        }
        return;
      }

      final isSpam = spamResponse.data?['is_spam'] ?? false;
      if (isSpam) {
        if (mounted) {
          SnackBarHelper.showError(
            context,
            'This grievance appears to be spam. Please revise your submission.',
            duration: const Duration(seconds: 5),
          );
        }
        return;
      }

      // Step 3: Check for duplicates
      final userId = await SecureStorage.userId;

      debugPrint('[LodgeGrievance] Checking duplicates with:');
      debugPrint('[LodgeGrievance] - Draft ID: $_draftId');
      debugPrint('[LodgeGrievance] - Location: ${locationModal.state}');
      debugPrint('[LodgeGrievance] - User ID: $userId');

      final duplicateResponse = await GrievanceService().duplicateDetection(
        _grievanceController.text,
        grievanceId: _draftId,
        locationId: locationModal.state,
        userId: userId,
      );

      if (!duplicateResponse.success) {
        debugPrint(
          '[LodgeGrievance] Duplicate check failed: ${duplicateResponse.message}',
        );
        if (mounted) {
          SnackBarHelper.showError(
            context,
            duplicateResponse.message ?? 'Failed to check for duplicates',
          );
        }
        // Don't return - continue with submission even if duplicate check fails
        debugPrint(
          '[LodgeGrievance] Continuing with submission despite duplicate check failure',
        );
      }

      final isDuplicate = duplicateResponse.data?['is_duplicate'] ?? false;
      debugPrint('[LodgeGrievance] Is duplicate: $isDuplicate');

      if (isDuplicate) {
        if (mounted) {
          SnackBarHelper.showWarning(
            context,
            'A similar grievance already exists. Please check existing grievances or revise your submission.',
          );
        }
        return;
      }

      // Step 4: Generate summary if all checks pass
      final response = await GrievanceService().summaryGeneration(
        _grievanceController.text,
        _draftId,
        "",
      );

      if (response.success && mounted) {
        SnackBarHelper.showSuccess(context, 'Grievance processed successfully');
      }
    } catch (e) {
      debugPrint("Error submitting grievance: $e");
      if (mounted) {
        SnackBarHelper.showError(context, 'Error submitting grievance: $e');
      }
    }
  }

  Future<void> _handleSaveDraft() async {
    try {
      final payload = DraftModal(
        formId: _formId,
        isDraft: true,
        description: _grievanceController.text,
        // location: locationModal.toJson(),
        location: {
          'villageCityTown': _cityController.text.trim(),
          'district': _districtController.text.trim(),
          'state': "Tamil Nadu",
          'pincode': _pincodeController.text.trim(),
        },
        compliantsList: _compliantsList,
        attachments: [],
        additionalFields: {
          "language": "EN",
          "department": {"id": "", "name": ""},
          "category": {"id": "", "name": ""},
        },
      );

      final response = await GrievanceService().saveDraft(payload, true);
      setState(() {
        _draftId = response.data?['draftId'] ?? '';
      });
    } catch (e) {
      debugPrint("Error saving draft: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildLodgeGrievanceForm(screenWidth, isSmallScreen, isTablet),
          const SizedBox(height: 24.0),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return CustomHeader(
      variant: HeaderVariant.protected,
      title: "Lodge Grievance",
      actions: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: _primaryBlueColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildLodgeGrievanceForm(
    double screenWidth,
    bool isSmallScreen,
    bool isTablet,
  ) {
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGrievanceDescriptionField(),
          _buildCharacterCounter(),
          const SizedBox(height: 12.0),
          _buildResponsiveActionButtons(screenWidth, isSmallScreen, isTablet),
          const SizedBox(height: 24.0),
          _buildCompliantsSection(screenWidth, isTablet),
          const SizedBox(height: 24.0),
          _buildLocationFields(),
        ],
      ),
    );
  }

  Widget _buildGrievanceDescriptionField() {
    return CustomTextField(
      label: "Describe your grievance here",
      showRequiredAsterisk: true,
      controller: _grievanceController,
      focusNode: _grievanceFocusNode,
      onChanged: (_) => setState(() {}),
      maxLines: 8,
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildCharacterCounter() {
    final count = _grievanceController.text.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [const Text("Min: 200 characters"), Text("$count/5000")],
    );
  }

  Widget _buildResponsiveActionButtons(
    double screenWidth,
    bool isSmallScreen,
    bool isTablet,
  ) {
    final micButtonWidth = isSmallScreen
        ? screenWidth * 0.4
        : (isTablet ? 180.0 : 152.0);
    final uploadButtonWidth = isSmallScreen
        ? screenWidth * 0.85
        : (isTablet ? 320.0 : 266.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionButton(
          width: micButtonWidth,
          icon: Icons.mic,
          label: "Use Mic",
          iconColor: _pinkColor,
          backgroundColor: const Color(0xFFFBE9ED),
          onTap: () {},
          isSmallScreen: isSmallScreen,
        ),
        const SizedBox(height: 12.0),
        DocumentUploadWidget(
          width: uploadButtonWidth,
          isUploading: _isUploadingFiles,
          errorMessage: _filePickerError,
          isSmallScreen: isSmallScreen,
          onUploadStart: () {
            setState(() {
              _filePickerError = '';
              _isUploadingFiles = true;
            });
          },
          onUploadSuccess: (extractedText, fileName, filePath) {
            setState(() {
              _grievanceController.text = extractedText;
              _isUploadingFiles = false;
              _attachments.add({'fileName': fileName, 'filePath': filePath});
            });
            debugPrint("attachments: $_attachments");
            SnackBarHelper.showSuccess(
              context,
              'File uploaded and text extracted successfully',
            );
          },
          onUploadError: (error) {
            setState(() {
              _filePickerError = error;
              _isUploadingFiles = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        CustomTextField(
          label: "Location of Grievance",
          hintText: "Village / City / Town",
          controller: _cityController,
          onChanged: (value) {
            locationModal.villageCityTown = value.trim();
          },
        ),
        const SizedBox(height: 12.0),
        CustomTextField(
          hintText: "District",
          controller: _districtController,
          onChanged: (value) {
            locationModal.district = value.trim();
          },
        ),
        const SizedBox(height: 12.0),
        CustomDropDown(
          items: _states,
          hint: "State",
          textColor: const Color(0xFFC6C6C6),
          borderColor: const Color(0xFFC6C6C6),
          onChanged: (value) {
            locationModal.state = value.value.trim();
          },
        ),
        const SizedBox(height: 12.0),
        CustomTextField(
          hintText: "Pincode",
          controller: _pincodeController,
          onChanged: (value) {
            locationModal.pincode = int.tryParse(value.trim()) ?? 0;
          },
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final boxShadow = BoxShadow(
      color: const Color(0xA2A2A2A2).withValues(alpha: 0.2),
      spreadRadius: 0,
      blurRadius: 4,
      offset: const Offset(0, -2),
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [boxShadow]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomButton(
            width: double.infinity,
            text: "Proceed to Next",
            onPressed: _handleSubmitGrievance,
            suffixIcon: Icons.arrow_forward_ios,
            gradientBackground: _primaryGradient,
            // enabled: false,
          ),
          const SizedBox(height: 12.0),
          CustomButton(
            width: double.infinity,
            text: "Save as Draft",
            backgroundColor: _orangeColor,
            disabledBackgroundColor: _orangeColor.withValues(alpha: 0.2),
            onPressed: _handleSaveDraft,
            textColor: Colors.white,
            // enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
    required double width,
    required bool isSmallScreen,
  }) {
    final iconSize = isSmallScreen ? 40.0 : 48.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final horizontalPadding = isSmallScreen ? 16.0 : 28.0;

    return Container(
      width: width,
      padding: EdgeInsets.fromLTRB(0, 0, horizontalPadding, 0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(80.0)),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F3F3), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(80.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: iconSize * 0.5),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Noto Sans",
                  color: const Color(0xFF08314D),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCompliantsSection(double screenWidth, bool isTablet) {
    final padding = isTablet ? 20.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.separated(
            itemCount: _compliants.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildCompliantDetail(
                key: ValueKey(_compliants[index].order),
                compliant: _compliants[index],
                index: index,
                screenWidth: screenWidth,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12.0),
          ),
          const SizedBox(height: 16.0),
          _buildAddCompliantButton(),
        ],
      ),
    );
  }

  Widget _buildAddCompliantButton() {
    return InkWell(
      onTap: _addCompliant,
      child: const Row(
        children: [
          Icon(Icons.add_circle_outline, color: _primaryBlueColor),
          SizedBox(width: 8),
          Text(
            "Add Group Grievance",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "Noto Sans",
              color: _primaryBlueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompliantDetail({
    required CompliantDataModal compliant,
    required int index,
    required Key key,
    required double screenWidth,
  }) {
    return Column(
      children: [
        CustomTextField(
          label: "Compliant's Name",
          controller: compliant.nameController,
          errorText: compliant.nameErrorText.isNotEmpty
              ? compliant.nameErrorText
              : null,
          enabled: !compliant.isVerified,
        ),
        const SizedBox(height: 12.0),
        _buildPhoneFieldWithVerify(compliant, index, screenWidth),
        const SizedBox(height: 12.0),
        CustomTextField(
          label: "Email ID",
          controller: compliant.emailController,
          errorText: compliant.emailErrorText.isNotEmpty
              ? compliant.emailErrorText
              : null,
          keyboardType: TextInputType.emailAddress,
          enabled: !compliant.isVerified,
        ),
      ],
    );
  }

  Widget _buildPhoneFieldWithVerify(
    CompliantDataModal compliant,
    int index,
    double screenWidth,
  ) {
    final isSmallScreen = screenWidth < 360;
    final checkmarkSize = isSmallScreen ? 20.0 : 24.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final topPosition = isSmallScreen ? 36.0 : 38.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomTextField(
          label: "Mobile Number",
          controller: compliant.phoneController,
          errorText: compliant.phoneErrorText.isNotEmpty
              ? compliant.phoneErrorText
              : null,
          keyboardType: TextInputType.phone,
          enabled: !compliant.isVerified,
        ),
        Positioned(
          top: topPosition,
          right: 10,
          child: compliant.isVerified
              ? Container(
                  width: checkmarkSize,
                  height: checkmarkSize,
                  decoration: const BoxDecoration(
                    color: _successGreenColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: iconSize),
                )
              : InkWell(
                  onTap: () => _verifyCompliant(index),
                  child: Text(
                    "Verify",
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                      color: _verifyOrangeColor,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
