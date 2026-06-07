import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ofacilite/core/services/tts_service.dart';
import 'package:ofacilite/core/theme/app_theme.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ofacilite/shared/widgets/accessible_button.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  FlutterTts get _tts => TtsService.instance.tts;
  final ImagePicker _picker = ImagePicker();

  File? _image;
  String? _extractedText;
  bool _analyzing = false;
  bool _ttsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ttsInitialized) {
      _ttsInitialized = true;
      _initTts();
    }
  }

  Future<void> _initTts() async {
    await TtsService.instance.init(context.locale.languageCode);
    await Future.delayed(const Duration(milliseconds: 800));
    await _tts.speak('document_tts_intro'.tr());
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _extractedText = null;
      _analyzing = true;
    });

    await _analyzeImage(picked.path);
  }

  Future<void> _analyzeImage(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      final text = result.text.trim();
      final display = text.isEmpty ? 'document_no_text'.tr() : text;

      setState(() {
        _extractedText = display;
        _analyzing = false;
      });

      await _tts.stop();
      await _tts.speak(display);
    } finally {
      recognizer.close();
    }
  }

  void _reset() {
    _tts.stop();
    setState(() {
      _image = null;
      _extractedText = null;
      _analyzing = false;
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('document_title'.tr()),
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.white,
      ),
      body: _image == null ? _buildPicker() : _buildResult(),
    );
  }

  Widget _buildPicker() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AccessibleButton(
              description: 'document_desc_take_photo'.tr(),
              onTap: () => _pickImage(ImageSource.camera),
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.camera_alt, size: 36),
                label: Text(
                  'document_take_photo'.tr(),
                  style: const TextStyle(fontSize: 22),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.dark,
                  disabledBackgroundColor: AppColors.primary,
                  disabledForegroundColor: AppColors.dark,
                  minimumSize: const Size.fromHeight(80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AccessibleButton(
              description: 'document_desc_gallery'.tr(),
              onTap: () => _pickImage(ImageSource.gallery),
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.photo_library, size: 28),
                label: Text(
                  'document_gallery'.tr(),
                  style: const TextStyle(fontSize: 18),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(60),
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: Image.file(_image!, fit: BoxFit.cover),
        ),
        Expanded(
          child: _analyzing
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'document_analyzing'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _extractedText ?? '',
                          style: const TextStyle(fontSize: 18, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AccessibleButton(
                        description: 'document_desc_new_photo'.tr(),
                        onTap: _reset,
                        child: ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.refresh, size: 24),
                          label: Text(
                            'document_new_photo'.tr(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.dark,
                            disabledBackgroundColor: AppColors.primary,
                            disabledForegroundColor: AppColors.dark,
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
