import 'package:cpgrams_citizen_app/services/grievances/grievance_service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Widget for handling document upload with OCR text extraction
class DocumentUploadWidget extends StatelessWidget {
  final bool isUploading;
  final String errorMessage;
  final VoidCallback onUploadStart;
  final Function(String extractedText, String fileName, String filePath)
  onUploadSuccess;
  final Function(String error) onUploadError;
  final double? width;
  final bool isSmallScreen;

  static const _uploadGreenColor = Color(0xFF3C9718);

  const DocumentUploadWidget({
    super.key,
    required this.isUploading,
    required this.errorMessage,
    required this.onUploadStart,
    required this.onUploadSuccess,
    required this.onUploadError,
    this.width,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUploadButton(),
        if (errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadButton() {
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
        onTap: isUploading ? null : _handleDocumentUpload,
        borderRadius: BorderRadius.circular(80.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(
                color: Color(0xFFEDF7E6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploading
                    ? Icons.hourglass_empty
                    : Icons.file_upload_outlined,
                color: _uploadGreenColor,
                size: iconSize * 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                isUploading ? "Uploading..." : "Upload Grievance Letter",
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

  Future<void> _handleDocumentUpload() async {
    onUploadStart();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        const maxSize = 5 * 1024 * 1024;
        final oversizedFiles = result.files.single.size > maxSize;

        if (oversizedFiles) {
          onUploadError(
            'Selected file exceeds 5MB limit: ${result.files.single.name}',
          );
          return;
        }

        final filesWithPaths = result.files.single.path;

        if (filesWithPaths == null) {
          onUploadError('Unable to access selected files');
          return;
        }

        final filePaths = [filesWithPaths];
        final formData = FormData.fromMap({
          'files': await MultipartFile.fromFile(filePaths[0]),
          'module': 'grievance',
        });

        final response = await GrievanceService().pdfExtract(formData, true);

        if (response.success && response.data != null) {
          // Extract text from OCR response
          final extractedText = _extractTextFromResponse(response.data!);

          if (extractedText.isNotEmpty) {
            onUploadSuccess(
              extractedText,
              result.files.single.name,
              filesWithPaths,
            );
            debugPrint(
              '[DocumentUploadWidget] Extracted text length: ${extractedText.length}',
            );
          } else {
            debugPrint('[DocumentUploadWidget] No text found in response');
            onUploadError('No text could be extracted from the document');
          }
        } else {
          onUploadError(response.message ?? 'Failed to upload files');
        }
      }
    } catch (e) {
      onUploadError('Failed to pick file: $e');
      debugPrint('[DocumentUploadWidget] Error picking file: $e');
    }
  }

  String _extractTextFromResponse(Map<String, dynamic> responseData) {
    final ocrBlock =
        responseData['ocr'] ??
        responseData['ocr_response'] ??
        responseData['payload'] ??
        responseData['data'] ??
        responseData;

    // Define text extraction paths with fallbacks
    final textCandidates = [
      ['ocr', 'payload', 'data', 'data', 0, 'Full_Text_Body'],
      ['ocr', 'payload', 'data', 'data', 0, 'source_text'],
      ['ocr', 'payload', 'data', 'data', 0, 'translated_extracted_text'],
      ['ocr', 'payload', 'data', 'data', 0, 'extracted_text'],
      ['payload', 'data', 'data', 0, 'Full_Text_Body'],
      ['payload', 'data', 'data', 0, 'translated_extracted_text'],
      ['payload', 'data', 'data', 0, 'extracted_text'],
      ['payload', 'data', 'data', 0, 'source_text'],
      ['payload', 'data', 0, 'Full_Text_Body'],
      ['payload', 'data', 0, 'translated_extracted_text'],
      ['payload', 'data', 0, 'extracted_text'],
      ['payload', 'data', 0, 'source_text'],
      ['data', 'data', 0, 'Full_Text_Body'],
      ['data', 'data', 0, 'translated_extracted_text'],
      ['data', 'data', 0, 'extracted_text'],
      ['data', 'data', 0, 'source_text'],
      ['data', 0, 'Full_Text_Body'],
      ['data', 0, 'source_text'],
      ['data', 0, 'translated_extracted_text'],
      ['data', 0, 'extracted_text'],
      ['Full_Text_Body'],
      ['source_text'],
      ['text'],
      ['ocr_text'],
      ['extracted_text'],
    ];

    // Try to extract text from ocrBlock
    for (final path in textCandidates) {
      final val = _tryGetValue(ocrBlock, path);
      if (val is String && val.trim().isNotEmpty) {
        return val.trim();
      }
    }

    // Fallback: try to extract from uploaded data
    final uploaded = responseData['uploaded'];
    if (uploaded != null) {
      for (final path in textCandidates) {
        final val = _tryGetValue(uploaded, path);
        if (val is String && val.trim().isNotEmpty) {
          return val.trim();
        }
      }
    }

    return '';
  }

  dynamic _tryGetValue(dynamic obj, List<dynamic> path) {
    try {
      dynamic current = obj;
      for (final key in path) {
        if (current == null) return null;

        if (key is int) {
          if (current is List && key < current.length) {
            current = current[key];
          } else {
            return null;
          }
        } else if (key is String) {
          if (current is Map) {
            current = current[key];
          } else {
            return null;
          }
        }
      }
      return current;
    } catch (e) {
      return null;
    }
  }
}
