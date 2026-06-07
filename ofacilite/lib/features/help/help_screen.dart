import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ofacilite/core/services/tts_service.dart';
import 'package:ofacilite/core/theme/app_theme.dart';
import 'package:ofacilite/shared/widgets/accessible_button.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  FlutterTts get _tts => TtsService.instance.tts;
  final SpeechToText _stt = SpeechToText();

  bool _ttsInitialized = false;
  bool _sttAvailable = false;
  bool _isListening = false;
  String _transcribedText = '';

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initStt();
  }

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
    if (mounted) await _tts.speak('help_tts_intro'.tr());
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _initStt() async {
    _sttAvailable = await _stt.initialize(
      onError: (_) => _stopListening(),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) _stopListening();
        }
      },
    );
    print('[STT] available: $_sttAvailable');
    if (mounted) setState(() {});
  }

  void _stopListening() {
    if (!mounted || !_isListening) return;
    setState(() => _isListening = false);
    _pulseController.stop();
    _pulseController.reset();
  }

  String _sttLocale() => switch (context.locale.languageCode) {
        'ar' => 'ar_SA',
        'en' => 'en_US',
        _ => 'fr_FR',
      };

  Future<void> _startListening() async {
    if (!_sttAvailable || _isListening) return;
    await _tts.stop();
    setState(() {
      _transcribedText = '';
      _isListening = true;
    });
    _pulseController.repeat(reverse: true);
    await _stt.listen(
      onResult: (result) {
        setState(() => _transcribedText = result.recognizedWords);
      },
      localeId: _sttLocale(),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _reset() {
    _stt.cancel();
    setState(() {
      _transcribedText = '';
      _isListening = false;
    });
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tts.stop();
    _stt.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('help_title'.tr()),
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _buildVoiceSection(),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            flex: 2,
            child: _buildEmergencySection(),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: AccessibleButton(
              description: 'help_desc_mic'.tr(),
              onTap: _isListening ? null : _startListening,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening
                      ? const Color(0xFFD32F2F)
                      : AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening
                              ? const Color(0xFFD32F2F)
                              : AppColors.primary)
                          .withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isListening
                ? 'help_listening'.tr()
                : 'help_tap_to_speak'.tr(),
            style: TextStyle(
              fontSize: 18,
              color: _isListening
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFF888888),
              fontWeight:
                  _isListening ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (_transcribedText.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Text(
                _transcribedText,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'help_coming_soon'.tr(),
              style: const TextStyle(fontSize: 16, color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'help_retry'.tr(),
                style: const TextStyle(fontSize: 18),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'help_emergencies'.tr(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: AccessibleButton(
                    description: 'help_desc_samu'.tr(),
                    onTap: () => _callNumber('15'),
                    child: _EmergencyButton(
                      emoji: '🚑',
                      label: 'help_samu'.tr(),
                      number: '15',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: AccessibleButton(
                    description: 'help_desc_police'.tr(),
                    onTap: () => _callNumber('17'),
                    child: _EmergencyButton(
                      emoji: '🚔',
                      label: 'help_police'.tr(),
                      number: '17',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: AccessibleButton(
                    description: 'help_desc_pompiers'.tr(),
                    onTap: () => _callNumber('18'),
                    child: _EmergencyButton(
                      emoji: '🚒',
                      label: 'help_pompiers'.tr(),
                      number: '18',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton({
    required this.emoji,
    required this.label,
    required this.number,
  });

  final String emoji;
  final String label;
  final String number;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFD32F2F),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
