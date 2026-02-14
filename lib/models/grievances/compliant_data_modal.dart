import 'package:flutter/material.dart';

class CompliantDataModal {
  final int order;
  String? verifiedId;
  TextEditingController nameController;
  TextEditingController emailController;
  TextEditingController phoneController;
  bool isVerified;
  String emailErrorText = '';
  String phoneErrorText = '';
  String nameErrorText = '';

  CompliantDataModal({
    required this.order,
    this.verifiedId,
    this.isVerified = false,
    this.nameErrorText = '',
    this.emailErrorText = '',
    this.phoneErrorText = '',
  }) : nameController = TextEditingController(),
       emailController = TextEditingController(),
       phoneController = TextEditingController();

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'verifiedId': verifiedId,
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'nameErrorText': nameErrorText,
      'emailErrorText': emailErrorText,
      'phoneErrorText': phoneErrorText,
    };
  }
}
