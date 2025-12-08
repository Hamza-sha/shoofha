import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoofha/core/theme/app_colors.dart';
import 'package:shoofha/features/settings/application/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return settingsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => const Scaffold(
        body: Center(child: Text('حدث خطأ أثناء تحميل الإعدادات')),
      ),
      data: (settings) {
        final theme = Theme.of(context);
        final size = MediaQuery.sizeOf(context);
        final width = size.width;
        final height = size.height;

        final hPadding = width * 0.06;
        final vSpaceMd = height * 0.026;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                const _SettingsHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPadding,
                      vertical: vSpaceMd,
                    ),
                    child: Column(
                      children: [
                        // المظهر
                        _SettingsSectionCard(
                          title: 'المظهر',
                          icon: Icons.dark_mode_outlined,
                          children: [
                            _SettingsRadioTile<ThemeMode>(
                              label: 'حسب النظام',
                              group: settings.themeMode,
                              value: ThemeMode.system,
                              onChange: controller.updateThemeMode,
                            ),
                            _SettingsRadioTile<ThemeMode>(
                              label: 'فاتح',
                              group: settings.themeMode,
                              value: ThemeMode.light,
                              onChange: controller.updateThemeMode,
                            ),
                            _SettingsRadioTile<ThemeMode>(
                              label: 'داكن',
                              group: settings.themeMode,
                              value: ThemeMode.dark,
                              onChange: controller.updateThemeMode,
                            ),
                          ],
                        ),

                        SizedBox(height: vSpaceMd),

                        // اللغة
                        _SettingsSectionCard(
                          title: 'اللغة',
                          icon: Icons.language_outlined,
                          children: [
                            _SettingsRadioTile<Locale>(
                              label: 'العربية',
                              group: settings.locale,
                              value: const Locale('ar'),
                              onChange: controller.updateLocale,
                            ),
                            _SettingsRadioTile<Locale>(
                              label: 'English',
                              group: settings.locale,
                              value: const Locale('en'),
                              onChange: controller.updateLocale,
                            ),
                          ],
                        ),

                        SizedBox(height: vSpaceMd),

                        // عام
                        _SettingsSectionCard(
                          title: 'عام',
                          icon: Icons.settings_suggest_outlined,
                          children: [
                            _SettingsSimpleTile(
                              label: 'الإشعارات',
                              icon: Icons.notifications_none_rounded,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'سيتم إضافة إعدادات الإشعارات قريباً ✨',
                                    ),
                                  ),
                                );
                              },
                            ),
                            _SettingsSimpleTile(
                              label: 'الخصوصية والشروط',
                              icon: Icons.privacy_tip_outlined,
                              onTap: () {
                                // TODO: ربط صفحة سياسة الخصوصية لاحقاً
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// الهيدر العلوي – Gradient + زر رجوع + عنوان
class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final headerHeight = height * 0.19;

    return Container(
      height: headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.purple],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back + main icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _backButton(context),
                Icon(
                  Icons.settings_outlined,
                  color: Colors.white.withOpacity(.9),
                  size: height * 0.032,
                ),
              ],
            ),
            const Spacer(),
            Text(
              'الإعدادات',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: height * 0.030,
              ),
            ),
            SizedBox(height: height * 0.006),
            Text(
              'خصص تجربتك في Shoofha كما تحب ✨',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(.88),
                fontSize: height * 0.017,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _backButton(BuildContext context) {
  final height = MediaQuery.sizeOf(context).height;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.15),
      borderRadius: BorderRadius.circular(height * 0.014),
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
  );
}

/// كارد موحد لكل قسم إعدادات
class _SettingsSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final width = size.width;

    final radius = height * 0.018;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: height * 0.02),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.05 : 0.25,
            ),
            blurRadius: height * 0.02,
            offset: Offset(0, height * 0.01),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.045,
          vertical: height * 0.018,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(theme, title, icon, height, width),
            SizedBox(height: height * 0.012),
            Divider(color: theme.dividerColor.withOpacity(.4)),
            SizedBox(height: height * 0.012),
            ...children,
          ],
        ),
      ),
    );
  }
}

Widget _sectionTitle(
  ThemeData theme,
  String text,
  IconData icon,
  double h,
  double w,
) {
  return Row(
    children: [
      Icon(icon, size: h * 0.025, color: AppColors.teal),
      SizedBox(width: w * 0.02),
      Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
          fontSize: h * 0.018,
        ),
      ),
    ],
  );
}

/// RadioTile مخصص – للمظهر واللغة
class _SettingsRadioTile<T> extends StatelessWidget {
  final String label;
  final T group;
  final T value;
  final ValueChanged<T> onChange;

  const _SettingsRadioTile({
    required this.label,
    required this.group,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RadioListTile<T>(
      value: value,
      groupValue: group,
      onChanged: (v) {
        if (v != null) onChange(v);
      },
      dense: true,
      activeColor: AppColors.orange,
      title: Text(label, style: theme.textTheme.bodyMedium),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Tile بسيط للإجراءات العامة (الإشعارات، الشروط...)
class _SettingsSimpleTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsSimpleTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(height * 0.015),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.01),
        child: Row(
          children: [
            Icon(icon, size: height * 0.026, color: AppColors.teal),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: height * 0.018,
                ),
              ),
            ),
            Icon(
              Icons.chevron_left,
              size: height * 0.024,
              color: theme.iconTheme.color?.withOpacity(.7),
            ),
          ],
        ),
      ),
    );
  }
}
