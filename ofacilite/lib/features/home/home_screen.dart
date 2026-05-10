import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ofacilite/main.dart';
import 'package:ofacilite/features/contacts/contacts_screen.dart';
import 'package:ofacilite/features/document/document_screen.dart';
import 'package:ofacilite/features/health/health_screen.dart';
import 'package:ofacilite/features/map/map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final FlutterTts _tts = FlutterTts();

  bool _ttsInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ttsInitialized) {
      _ttsInitialized = true;
      _initTts();
    }
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  Future<void> _initTts() async {
    final locale = context.locale.languageCode;
    final ttsLang = switch (locale) {
      'ar' => 'ar-SA',
      'en' => 'en-US',
      _ => 'fr-FR',
    };
    await _tts.setLanguage(ttsLang);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await Future.delayed(const Duration(milliseconds: 800));
    await _tts.speak('home_question'.tr());
  }

  @override
  void didPopNext() async {
    await _tts.stop();
    await Future.delayed(const Duration(milliseconds: 800));
    await _tts.speak('home_question'.tr());
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tts.stop();
    super.dispose();
  }

  Future<void> _navigateTo(Widget screen) async {
    await _tts.stop();
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _showLanguagePicker() async {
    await _tts.stop();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LanguageSheet(
        onLocaleSelected: (locale) async {
          Navigator.pop(context);
          await context.setLocale(locale);
          final ttsLang = switch (locale.languageCode) {
            'ar' => 'ar-SA',
            'en' => 'en-US',
            _ => 'fr-FR',
          };
          await _tts.setLanguage(ttsLang);
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) await _tts.speak('home_question'.tr());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    'home_title'.tr(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.language,
                      size: 32,
                      color: Color(0xFF1565C0),
                    ),
                    onPressed: _showLanguagePicker,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _BigButton(
                              icon: Icons.description_rounded,
                              label: 'home_document'.tr(),
                              color: const Color(0xFF1976D2),
                              onTap: () => _navigateTo(const DocumentScreen()),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _BigButton(
                              icon: Icons.contacts_rounded,
                              label: 'home_contacts'.tr(),
                              color: const Color(0xFF388E3C),
                              onTap: () => _navigateTo(const ContactsScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _BigButton(
                              icon: Icons.favorite_rounded,
                              label: 'home_health'.tr(),
                              color: const Color(0xFFD32F2F),
                              onTap: () => _navigateTo(const HealthScreen()),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _BigButton(
                              icon: Icons.map_rounded,
                              label: 'home_map'.tr(),
                              color: const Color(0xFF00796B),
                              onTap: () => _navigateTo(const MapScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.onLocaleSelected});

  final void Function(Locale) onLocaleSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tile(context, '🇫🇷', 'Français', const Locale('fr')),
            _tile(context, '🇬🇧', 'English', const Locale('en')),
            _tile(context, '🇸🇦', 'عربي', const Locale('ar')),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, String flag, String label, Locale locale) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Text(flag, style: const TextStyle(fontSize: 36)),
      title: Text(
        label,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      onTap: () => onLocaleSelected(locale),
    );
  }
}
