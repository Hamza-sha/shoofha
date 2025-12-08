import 'package:flutter/material.dart';
import 'package:shoofha/core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.06;
    final vSpaceMd = height * 0.024;

    // بيانات تجريبية مؤقتاً (لحد ما نربط API / Backend)
    final todayNotifications = [
      _NotificationItem(
        title: 'طلبك رقم #SH-1024 تم تأكيده',
        body: 'المتجر يستعد لتحضير طلبك الآن 👌',
        timeLabel: 'منذ 10 دقائق',
        isUnread: true,
      ),
      _NotificationItem(
        title: 'عرض جديد من Coffee Mood',
        body: 'خصم 20% على جميع المشروبات حتى نهاية اليوم.',
        timeLabel: 'منذ ساعة',
        isUnread: true,
      ),
    ];

    final olderNotifications = [
      _NotificationItem(
        title: 'تم توصيل طلبك بنجاح',
        body: 'نتمنى أن تكون تجربتك مميزة مع Shoofha ✨',
        timeLabel: 'أمس',
        isUnread: false,
      ),
      _NotificationItem(
        title: 'حفظنا متجرك المفضل',
        body: 'تمت إضافة Coffee Mood إلى المفضلة.',
        timeLabel: 'منذ يومين',
        isUnread: false,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const _NotificationsHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: vSpaceMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (todayNotifications.isNotEmpty) ...[
                      _SectionLabel(text: 'اليوم'),
                      SizedBox(height: height * 0.012),
                      ...todayNotifications.map(
                        (n) => _NotificationCard(item: n),
                      ),
                      SizedBox(height: vSpaceMd),
                    ],
                    if (olderNotifications.isNotEmpty) ...[
                      _SectionLabel(text: 'الأيام السابقة'),
                      SizedBox(height: height * 0.012),
                      ...olderNotifications.map(
                        (n) => _NotificationCard(item: n),
                      ),
                    ],
                    if (todayNotifications.isEmpty &&
                        olderNotifications.isEmpty)
                      _EmptyState(height: height),
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

/// هيدر الشاشة – Gradient + Back + أيقونة جرس
class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

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
            // Back + bell icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _backButton(context),
                Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.white.withOpacity(.9),
                  size: height * 0.032,
                ),
              ],
            ),
            const Spacer(),
            Text(
              'الإشعارات',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: height * 0.030,
              ),
            ),
            SizedBox(height: height * 0.006),
            Text(
              'كل جديد يصلك من المتاجر والطلبات في مكان واحد.',
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

/// Label للفصل بين "اليوم" و "الأيام السابقة"
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;

    return Row(
      children: [
        Container(
          width: height * 0.010,
          height: height * 0.010,
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        SizedBox(width: size.width * 0.018),
        Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}

/// موديل بسيط للإشعار (داخلي للملف)
class _NotificationItem {
  final String title;
  final String body;
  final String timeLabel;
  final bool isUnread;

  const _NotificationItem({
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.isUnread,
  });
}

/// كرت إشعار فردي
class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.018;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: height * 0.012),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.04 : 0.20,
            ),
            blurRadius: height * 0.018,
            offset: Offset(0, height * 0.008),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.040,
          vertical: height * 0.014,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circle indicator
            Container(
              width: height * 0.028,
              height: height * 0.028,
              decoration: BoxDecoration(
                color: item.isUnread
                    ? AppColors.teal.withOpacity(.12)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isUnread
                      ? AppColors.teal
                      : AppColors.navy.withOpacity(0.18),
                  width: height * 0.0014,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.isUnread
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_outlined,
                size: height * 0.018,
                color: item.isUnread
                    ? AppColors.teal
                    : AppColors.navy.withOpacity(.7),
              ),
            ),
            SizedBox(width: width * 0.034),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: item.isUnread
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: height * 0.006),
                  Text(
                    item.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.8,
                      ),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: height * 0.008),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: height * 0.016,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      SizedBox(width: width * 0.012),
                      Text(
                        item.timeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (item.isUnread) ...[
              SizedBox(width: width * 0.02),
              Container(
                width: height * 0.010,
                height: height * 0.010,
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// حالة عدم وجود إشعارات
class _EmptyState extends StatelessWidget {
  final double height;

  const _EmptyState({required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;

    return SizedBox(
      height: height * 0.4,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: height * 0.07,
              color: AppColors.navy.withOpacity(0.35),
            ),
            SizedBox(height: height * 0.018),
            Text(
              'ما في إشعارات حالياً',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: height * 0.008),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.12),
              child: Text(
                'أول ما يصير شيء جديد بخصوص طلباتك أو المتاجر اللي تحبها، رح نخبرك هون. 😉',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
