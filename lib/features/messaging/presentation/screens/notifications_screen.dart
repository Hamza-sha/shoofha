import 'package:flutter/material.dart';
import 'package:shoofha/core/theme/app_colors.dart';
import 'package:shoofha/core/responsive/responsive.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = Responsive.width(context);
    final h = Responsive.height(context);

    final notifications = _dummyNotifications;
    final isEmpty = notifications.isEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإشعارات'), centerTitle: true),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.06,
            vertical: h * 0.015,
          ),
          child: isEmpty
              ? _EmptyNotifications()
              : ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => SizedBox(height: h * 0.012),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return _NotificationCard(item: item);
                  },
                ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = Responsive.height(context);
    final w = Responsive.width(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: h * 0.18,
              height: h * 0.18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.navy, AppColors.purple],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: h * 0.08,
              ),
            ),
            SizedBox(height: h * 0.02),
            Text(
              'ما في إشعارات حالياً',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.008),
            Text(
              'أول ما يصير شيء جديد بخصوص طلباتك أو المتاجر اللي تتابعها، رح نخبرك هون 😉',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationCard({required this.item});

  IconData get _icon {
    switch (item.type) {
      case _NotificationType.order:
        return Icons.shopping_bag_outlined;
      case _NotificationType.offer:
        return Icons.local_offer_outlined;
      case _NotificationType.message:
        return Icons.chat_bubble_outline_rounded;
      case _NotificationType.system:
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color get _iconColor {
    switch (item.type) {
      case _NotificationType.order:
        return AppColors.teal;
      case _NotificationType.offer:
        return AppColors.orange;
      case _NotificationType.message:
        return AppColors.purple;
      case _NotificationType.system:
      default:
        return AppColors.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.012),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(h * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.04 : 0.18,
            ),
            blurRadius: h * 0.016,
            offset: Offset(0, h * 0.006),
          ),
        ],
        border: item.isNew
            ? Border.all(color: cs.primary.withOpacity(0.55), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: h * 0.048,
            height: h * 0.048,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _iconColor.withOpacity(0.12),
            ),
            child: Icon(_icon, size: h * 0.026, color: _iconColor),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان + الوقت
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: w * 0.02),
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
                SizedBox(height: h * 0.004),
                Text(
                  item.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
                if (item.isNew) ...[
                  SizedBox(height: h * 0.006),
                  Row(
                    children: [
                      Container(
                        width: h * 0.008,
                        height: h * 0.008,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.teal,
                        ),
                      ),
                      SizedBox(width: w * 0.012),
                      Text(
                        'غير مقروء',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotificationType { order, offer, message, system }

class _NotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final _NotificationType type;
  final bool isNew;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.type,
    required this.isNew,
  });
}

final List<_NotificationItem> _dummyNotifications = [
  _NotificationItem(
    id: 'n1',
    title: 'تم تأكيد طلبك من Pizza House',
    body: 'طلبك رقم #849 تم تأكيده ورح يوصل خلال 35–45 دقيقة.',
    timeLabel: 'قبل 5 د',
    type: _NotificationType.order,
    isNew: true,
  ),
  _NotificationItem(
    id: 'n2',
    title: 'عرض جديد من Coffee Mood',
    body: 'خصم 30٪ على كل المشروبات الباردة اليوم فقط! لا تفوّت العرض.',
    timeLabel: 'اليوم',
    type: _NotificationType.offer,
    isNew: true,
  ),
  _NotificationItem(
    id: 'n3',
    title: 'رسالة جديدة من Fit Zone Gym',
    body: 'تم تعديل موعد حصّتك بناءً على طلبك. شوف التفاصيل من الرسائل.',
    timeLabel: 'أمس',
    type: _NotificationType.message,
    isNew: false,
  ),
  _NotificationItem(
    id: 'n4',
    title: 'مرحباً في Shoofha ✨',
    body: 'خلّينا نجهز حسابك: كمّل الاهتمامات واستكشف المتاجر حولك.',
    timeLabel: 'منذ 3 أيام',
    type: _NotificationType.system,
    isNew: false,
  ),
];
