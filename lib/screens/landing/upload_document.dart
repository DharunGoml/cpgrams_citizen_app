import 'package:cpgrams_citizen_app/services/grievances/grievance_service.dart';
import 'package:cpgrams_ui_kit/components/images.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadDocument extends StatefulWidget {
  final String? filePath;
  final String? fileName;
  final void Function(String fileName, String documentReport)?
  onDocumentProcessed;

  const UploadDocument({
    super.key,
    this.filePath,
    this.fileName,
    this.onDocumentProcessed,
  });

  @override
  State<UploadDocument> createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  String _fileName = '';
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // If filePath is provided, start processing immediately
    if (widget.filePath != null) {
      _fileName = widget.fileName ?? 'document';
      _processFile(widget.filePath!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleFilePick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _fileName = result.files.single.name;
        });
        await _processFile(result.files.single.path!);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processFile(String filePath) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final payload = FormData.fromMap({
        'files': await MultipartFile.fromFile(filePath),
      });

      final response = await GrievanceService().pdfExtract(payload);

      if (response.success && response.data != null) {
        final extractedText = _extractTextFromResponse(response.data!);

        if (extractedText.isNotEmpty) {
          debugPrint(
            '[UploadDocument] Extracted text length: ${extractedText.length}',
          );
          widget.onDocumentProcessed?.call(_fileName, extractedText);
        } else {
          debugPrint('[UploadDocument] No text found in response');
          widget.onDocumentProcessed?.call(
            _fileName,
            'Could not extract text from file',
          );
        }
      } else {
        debugPrint('[UploadDocument] API call failed: ${response.message}');
        widget.onDocumentProcessed?.call(
          _fileName,
          response.message ?? 'Upload failed',
        );
      }
    } catch (e) {
      debugPrint('Error processing file: $e');
      widget.onDocumentProcessed?.call(
        _fileName,
        'Error processing file: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return _buildProcessingView();
    }
    return _buildUploadView();
  }

  Widget _buildUploadView() {
    return GestureDetector(
      onTap: _handleFilePick,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            uploadIconButton,
            width: 150,
            height: 120,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 12),
          Text(
            "Click to upload your document",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "Noto Sans",
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Upload icon with scanning animation
        SizedBox(
          width: 150,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                uploadIconButton,
                width: 150,
                height: 120,
                fit: BoxFit.cover,
              ),
              // Scanning bar animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    top: _animationController.value * 120,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Blinking text with animation
        FadeTransition(
          opacity: _opacityAnimation,
          child: const Text(
            "Your document is being scanned,\nplease wait a moment.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: "Noto Sans",
              color: Color(0xFF727272),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
