import 'package:flutter/material.dart';
import 'package:project/data/models/auth_session.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/user_service.dart';
import 'package:project/app/settings_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<AuthUser> _userFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('[PROFILE] ProfileScreen.initState() called');
    try {
      _userFuture = UserService(ApiClient()).fetchUserProfile();
      debugPrint('[PROFILE] _userFuture initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('[PROFILE] Exception in initState: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[PROFILE] build() called');
    try {
      final settings = Provider.of<SettingsProvider>(context);
      final theme = Theme.of(context);
      debugPrint('[PROFILE] Settings and Theme acquired from Provider');

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: FutureBuilder<AuthUser>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                debugPrint('[PROFILE] FutureBuilder connectionState: waiting');
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                debugPrint('[PROFILE] FutureBuilder hasError: ${snapshot.error}');
                debugPrint('[PROFILE] FutureBuilder error stack trace: ${snapshot.stackTrace}');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Stack Trace:\n${snapshot.stackTrace}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (!snapshot.hasData) {
                debugPrint('[PROFILE] FutureBuilder !hasData: returning "No profile data found."');
                return const Center(child: Text('No profile data found.'));
              }

              debugPrint('[PROFILE] FutureBuilder hasData: successfully unwrapped AuthUser');
              final user = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color ?? theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : const NetworkImage('https://ui-avatars.com/api/?name=User&background=random'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName ?? 'Unknown User',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Account'),
                  const SizedBox(height: 8),
                  _buildCardGroup(theme, [
                    _buildListTile(theme, 'Manage Profile', Icons.person_outline),
                    _buildListTile(theme, 'Password & Security', Icons.lock_outline),
                    _buildListTile(theme, 'Notifications', Icons.notifications_none),
                    _buildListTile(theme, 'Language', Icons.translate, trailingText: settings.language, onTap: () {
                      _showLanguageDialog(context, settings);
                    }),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Preferences'),
                  const SizedBox(height: 8),
                  _buildCardGroup(theme, [
                    _buildListTile(theme, 'About Us', Icons.info_outline),
                    _buildListTile(theme, 'Theme', Icons.contrast, trailingText: settings.themeMode == ThemeMode.dark ? 'Dark' : 'Light', onTap: () {
                      _showThemeDialog(context, settings);
                    }),
                    _buildListTile(theme, 'Appointments', Icons.calendar_today_outlined),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Support'),
                  const SizedBox(height: 8),
                  _buildCardGroup(theme, [
                    _buildListTile(theme, 'Help Center', Icons.help_outline),
                  ]),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEB),
                        foregroundColor: const Color(0xFFD32F2F),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
    } catch (e, stackTrace) {
      debugPrint('[PROFILE] Exception in build(): $e\n$stackTrace');
      return Scaffold(body: Center(child: Text('Build Error: $e')));
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCardGroup(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          return Column(
            children: [
              child,
              if (idx < children.length - 1)
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.1), indent: 52, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListTile(ThemeData theme, String title, IconData icon, {String? trailingText, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                trailingText,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  settings.setTheme(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  settings.setTheme(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: settings.language,
                onChanged: (value) {
                  settings.setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Vietnamese'),
                value: 'Vietnamese',
                groupValue: settings.language,
                onChanged: (value) {
                  settings.setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
