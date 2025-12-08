import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/app/theme/app_theme.dart';
import 'package:shoofha/features/auth/application/auth_notifier.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder عشان نسمع لتغيّر حالة الأوث (لوج إن / لوج آوت)
    return AnimatedBuilder(
      animation: authNotifier,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final size = MediaQuery.sizeOf(context);
        final width = size.width;
        final height = size.height;

        final horizontalPadding = width * 0.06;
        final _ = height * 0.012;
        final vSpaceSm = height * 0.018;
        final vSpaceMd = height * 0.026;

        final user = authNotifier.user;
        final isLoggedIn = authNotifier.isLoggedIn;

        final displayName = user?.name.isNotEmpty == true
            ? user!.name
            : 'مستخدم Shoofha';
        final email = user?.email ?? 'قم بتسجيل الدخول للوصول لكل المزايا';

        final initials = displayName.isNotEmpty
            ? displayName.trim()[0].toUpperCase()
            : 'S';

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // الهيدر العلوي (Gradient + صورة + اسم)
                _ProfileHeader(
                  displayName: displayName,
                  email: email,
                  initials: initials,
                  isLoggedIn: isLoggedIn,
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: vSpaceMd),

                          // 🧍‍♂️ قسم الحساب
                          _SectionCard(
                            title: 'حسابي',
                            children: [
                              if (isLoggedIn)
                                _ProfileTile(
                                  icon: Icons.receipt_long_outlined,
                                  label: 'طلباتي',
                                  onTap: () {
                                    context.pushNamed('orders');
                                  },
                                ),
                              _ProfileTile(
                                icon: Icons.favorite_border,
                                label: 'المفضلة',
                                onTap: () {
                                  context.pushNamed('favorites');
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: vSpaceSm),

                          // ⚙️ قسم التطبيق
                          _SectionCard(
                            title: 'التطبيق',
                            children: [
                              _ProfileTile(
                                icon: Icons.settings_outlined,
                                label: 'الإعدادات',
                                onTap: () {
                                  context.pushNamed('settings');
                                },
                              ),
                              _ProfileTile(
                                icon: Icons.notifications_outlined,
                                label: 'الإشعارات',
                                onTap: () {
                                  context.pushNamed('notifications');
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: vSpaceSm),

                          // 🆘 قسم الدعم والمساعدة
                          _SectionCard(
                            title: 'الدعم والمساعدة',
                            children: [
                              _ProfileTile(
                                icon: Icons.help_outline,
                                label: 'مركز المساعدة',
                                onTap: () {
                                  // TODO: صفحة دعم حقيقية لاحقاً
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'سيتم إضافة مركز المساعدة قريباً ⭐',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _ProfileTile(
                                icon: Icons.privacy_tip_outlined,
                                label: 'الخصوصية والشروط',
                                onTap: () {
                                  // TODO: صفحة سياسة الخصوصية
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: vSpaceMd),

                          // زر تسجيل الدخول / تسجيل الخروج
                          Padding(
                            padding: EdgeInsets.only(bottom: vSpaceSm),
                            child: _AuthButton(
                              isLoggedIn: isLoggedIn,
                              onLogin: () {
                                context.pushNamed('login');
                              },
                              onLogout: () {
                                authNotifier.logOut();
                                context.goNamed('welcome');
                              },
                            ),
                          ),
                        ],
                      ),
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

/// الهيدر العلوي: Gradient + Avatar + اسم
class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String initials;
  final bool isLoggedIn;

  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.initials,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _ = theme.colorScheme;
    final shoofhaTheme = theme.extension<ShoofhaTheme>();
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final headerHeight = height * 0.26;
    final avatarRadius = height * 0.045;

    return Container(
      width: double.infinity,
      height: headerHeight,
      decoration: BoxDecoration(
        gradient:
            shoofhaTheme?.primaryHeaderGradient ??
            const LinearGradient(
              colors: [AppColors.navy, AppColors.purple],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.020,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان أعلى يمين/وسط
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'حسابي',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white.withOpacity(0.9),
                  size: height * 0.030,
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  child: CircleAvatar(
                    radius: avatarRadius * 0.82,
                    backgroundColor: Colors.white,
                    child: Text(
                      initials,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * 0.004),
                      Text(
                        email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.012),
            if (!isLoggedIn)
              Text(
                'سجّل الدخول لتجربة مخصصة بالكامل لعاداتك واهتماماتك.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// كارد لقسم (حسابي / التطبيق / الدعم...)
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.020;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.03 : 0.25,
            ),
            blurRadius: height * 0.020,
            offset: Offset(0, height * 0.010),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.012,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: height * 0.006),
            const Divider(height: 0),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// عنصر واحد في قائمة الخيارات
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.010),
        child: Row(
          children: [
            Icon(icon, size: height * 0.026),
            SizedBox(width: size.width * 0.03),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Icon(
              Icons.chevron_left,
              size: height * 0.024,
              color: theme.iconTheme.color?.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر تسجيل الدخول / تسجيل الخروج حسب الحالة
class _AuthButton extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  const _AuthButton({
    required this.isLoggedIn,
    required this.onLogin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shoofhaTheme = theme.extension<ShoofhaTheme>();
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final height = size.height;

    final label = isLoggedIn ? 'تسجيل الخروج' : 'تسجيل الدخول / إنشاء حساب';

    if (!isLoggedIn) {
      // زر Gradient للدخول
      return SizedBox(
        width: double.infinity,
        height: height * 0.058,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height * 0.026),
            gradient:
                shoofhaTheme?.primaryButtonGradient ??
                const LinearGradient(
                  colors: [AppColors.navy, AppColors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(height * 0.026),
              onTap: onLogin,
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // زر تسجيل خروج بخلفية خفيفة
    return SizedBox(
      width: double.infinity,
      height: height * 0.058,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.error.withOpacity(0.9)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height * 0.026),
          ),
        ),
        onPressed: onLogout,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
