import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/analysis_provider.dart';
import '../providers/locale_provider.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final analysisProvider = Provider.of<AnalysisProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    String getLanguageName(String code) {
      switch (code) {
        case 'ml':
          return 'മലയാളം';
        case 'hi':
          return 'हिन्दी';
        case 'ta':
          return 'தமிழ்';
        case 'en':
        default:
          return 'English';
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.appearance),
          SwitchListTile(
            title: Text(l10n.darkMode),
            secondary: const Icon(Icons.dark_mode_rounded),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
          _SectionHeader(title: l10n.language),
          ListTile(
            title: Text(l10n.appLanguage),
            subtitle: Text(
                getLanguageName(localeProvider.locale?.languageCode ?? 'en')),
            leading: const Icon(Icons.language_rounded),
            onTap: () => _showLanguageBottomSheet(context, localeProvider),
          ),
          _SectionHeader(title: l10n.account),
          ListTile(
            title: Text(authProvider.user?.name ?? l10n.guest),
            subtitle: Text(authProvider.user?.email ?? l10n.connectYourAccount),
            leading: const Icon(Icons.person_rounded),
            trailing: authProvider.user?.isGuest ?? true
                ? TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(l10n.signUp),
                  )
                : null,
          ),
          _SectionHeader(title: l10n.storage),
          ListTile(
            title: Text(l10n.clearCache),
            leading: const Icon(Icons.cached_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.cacheCleared)),
              );
            },
          ),
          ListTile(
            title: Text(l10n.deleteAllHistory),
            leading:
                const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onTap: () => analysisProvider.clearHistory(),
          ),
          _SectionHeader(title: l10n.about),
          ListTile(
            title: Text(l10n.privacyPolicy),
            leading: const Icon(Icons.privacy_tip_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            title: Text(l10n.termsOfService),
            leading: const Icon(Icons.description_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TermsOfServiceScreen()),
              );
            },
          ),
          ListTile(
            title: Text(l10n.appVersion),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_rounded),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: Text(l10n.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(
      BuildContext context, LocaleProvider localeProvider) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.selectLanguage,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _LanguageOption(
                title: 'English',
                languageCode: 'en',
                currentLocale: currentLocale,
                localeProvider: localeProvider,
              ),
              _LanguageOption(
                title: 'മലയാളം',
                languageCode: 'ml',
                currentLocale: currentLocale,
                localeProvider: localeProvider,
              ),
              _LanguageOption(
                title: 'हिन्दी',
                languageCode: 'hi',
                currentLocale: currentLocale,
                localeProvider: localeProvider,
              ),
              _LanguageOption(
                title: 'தமிழ்',
                languageCode: 'ta',
                currentLocale: currentLocale,
                localeProvider: localeProvider,
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String languageCode;
  final String currentLocale;
  final LocaleProvider localeProvider;

  const _LanguageOption({
    required this.title,
    required this.languageCode,
    required this.currentLocale,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentLocale == languageCode;
    final theme = Theme.of(context);

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.primaryColor : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.primaryColor)
          : null,
      onTap: () {
        localeProvider.setLocale(Locale(languageCode));
        Navigator.pop(context);
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
