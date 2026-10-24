import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:distract/dashboard.dart';

class AccessibilityConsentScreen extends StatefulWidget {
  const AccessibilityConsentScreen({super.key});

  @override
  State<AccessibilityConsentScreen> createState() => _AccessibilityConsentScreenState();
}

class _AccessibilityConsentScreenState extends State<AccessibilityConsentScreen> {
  static const _platform = MethodChannel('com.example.distract/channel');

  Future<void> _onAgree() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accessibility_consented', true);
    
    // Open accessibility settings first
    try {
      await _platform.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint('Error opening accessibility settings: $e');
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  void _onCancel() {
    SystemNavigator.pop();
  }

  // Theme support mirroring dashboard.dart
  Color get _bg => themeModeNotifier.value == ThemeMode.dark
      ? const Color(0xFF111111)
      : const Color(0xFFFFFFFF);
  Color get _surface => themeModeNotifier.value == ThemeMode.dark
      ? const Color(0xFF1A1A1A)
      : const Color(0xFFF7F7F5);
  Color get _card => themeModeNotifier.value == ThemeMode.dark
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);
  Color get _textPrimary => themeModeNotifier.value == ThemeMode.dark
      ? const Color(0xFFF2F2F2)
      : const Color(0xFF1A1A1A);
  Color get _textSecondary => themeModeNotifier.value == ThemeMode.dark
      ? const Color(0xFF9A9A9A)
      : const Color(0xFF6B6B6B);
  Color get _textMuted => themeModeNotifier.value == ThemeMode.dark
      ? const Color(0xFF5A5A5A)
      : const Color(0xFFA0A0A0);
  Color get _border => themeModeNotifier.value == ThemeMode.dark
      ? const Color(0xFF2A2A2A)
      : const Color(0xFFEEEEEE);
  Color get _activeGreen => themeModeNotifier.value == ThemeMode.dark
      ? const Color(0xFF4ADE80)
      : const Color(0xFF16A34A);
  Color get _activeGreenBg => themeModeNotifier.value == ThemeMode.dark
      ? const Color(0xFF4ADE80).withOpacity(0.08)
      : const Color(0xFF16A34A).withOpacity(0.07);
  Color get _activeGreenBorder => themeModeNotifier.value == ThemeMode.dark
      ? const Color(0xFF4ADE80).withOpacity(0.2)
      : const Color(0xFF16A34A).withOpacity(0.25);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Premium Header Icon
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: _surface,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: _border),
                            ),
                            child: Icon(
                              Icons.accessibility_new_rounded,
                              color: _activeGreen,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // Header Text
                        Text(
                          'Why Doomless needs Accessibility Permission?',
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            color: _textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // App description
                        Text(
                          'Doomless helps you manage your screen time and curb mindless scrolling habits. To block distracting platforms and track your app usage effectively, we require the Accessibility Service API.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            height: 1.5,
                            color: _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // Section: Data We Access & Collect
                        Text(
                          'DATA WE ACCESS & COLLECT:',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: _textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Card 1: Installed Apps
                        _buildDataCollectionCard(
                          icon: Icons.apps_rounded,
                          title: 'Installed Apps',
                          description: 'We check your installed applications to detect when a blacklisted or time-limited social media app is opened, allowing us to restrict access as per your limits.',
                        ),
                        const SizedBox(height: 12),
                        
                        // Card 2: Screen Content & User Activity
                        _buildDataCollectionCard(
                          icon: Icons.swipe_vertical_rounded,
                          title: 'Screen Content & User Activity',
                          subtitle: '(Other user-generated content)',
                          description: 'We monitor the current active screen state and scrolling activity within targeted apps to track your scrolling duration and help you stay within your goals.',
                        ),
                        const SizedBox(height: 24),
                        
                        // Local processing assurance banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _activeGreenBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _activeGreenBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: _activeGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This data is processed locally on your device solely for the core app-blocking/tracking features and is never shared with third parties or stored on external servers.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: _activeGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Button Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  decoration: BoxDecoration(
                    color: _bg,
                    border: Border(
                      top: BorderSide(color: _border),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _border),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _onCancel,
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Agree & Enable Button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _textPrimary,
                            foregroundColor: _bg,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _onAgree,
                          child: Text(
                            'Agree & Enable',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataCollectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Icon(
                  icon,
                  color: _textPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              height: 1.45,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
