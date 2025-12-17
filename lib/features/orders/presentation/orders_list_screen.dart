import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shoofha/core/theme/app_colors.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.06;
    final vSpaceMd = height * 0.024;

    final orders = _dummyOrders;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const _OrdersHeader(),
            Expanded(
              child: orders.isEmpty
                  ? _EmptyOrders(height: height)
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: vSpaceMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(text: 'طلباتي'),
                          SizedBox(height: height * 0.014),
                          ...orders.map((order) => _OrderCard(order: order)),
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

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader();

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
            // Back + box icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _backButton(context),
                Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white.withOpacity(.9),
                  size: height * 0.032,
                ),
              ],
            ),
            const Spacer(),
            Text(
              'طلباتي',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: height * 0.030,
              ),
            ),
            SizedBox(height: height * 0.006),
            Text(
              'تابع حالة طلباتك السابقة والحالية بسهولة.',
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

/// ✅ تعديل مهم: back باستخدام GoRouter (أفضل مع ستاك الراوت)
Widget _backButton(BuildContext context) {
  final height = MediaQuery.sizeOf(context).height;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.15),
      borderRadius: BorderRadius.circular(height * 0.014),
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          // احتياط: لو وصلت هون من deep link أو ستاك فاضي
          context.goNamed('app');
        }
      },
    ),
  );
}

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

/// موديل داخلي بسيط للطلبات (UI فقط)
class _OrderItem {
  final String id;
  final String storeName;
  final String statusLabel;
  final Color statusColor;
  final String dateLabel;
  final double total;

  const _OrderItem({
    required this.id,
    required this.storeName,
    required this.statusLabel,
    required this.statusColor,
    required this.dateLabel,
    required this.total,
  });
}

final _dummyOrders = <_OrderItem>[
  _OrderItem(
    id: '#SH-1024',
    storeName: 'Coffee Mood',
    statusLabel: 'قيد التحضير',
    statusColor: AppColors.orange,
    dateLabel: 'اليوم - 10:30 ص',
    total: 12.50,
  ),
  _OrderItem(
    id: '#SH-0987',
    storeName: 'Fit Zone',
    statusLabel: 'تم التوصيل',
    statusColor: Colors.green,
    dateLabel: 'أمس - 5:20 م',
    total: 34.90,
  ),
  _OrderItem(
    id: '#SH-0870',
    storeName: 'Burger Hub',
    statusLabel: 'ملغي',
    statusColor: Colors.redAccent,
    dateLabel: 'منذ 3 أيام',
    total: 22.00,
  ),
];

class _OrderCard extends StatelessWidget {
  final _OrderItem order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.018;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: height * 0.014),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // السطر الأول: رقم الطلب + الحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03,
                    vertical: height * 0.004,
                  ),
                  decoration: BoxDecoration(
                    color: order.statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(height * 0.012),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: order.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.006),
            Text(
              order.storeName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
              ),
            ),
            SizedBox(height: height * 0.008),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: height * 0.016,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
                SizedBox(width: width * 0.010),
                Text(
                  order.dateLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                Text(
                  '${order.total.toStringAsFixed(2)} د.أ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final double height;

  const _EmptyOrders({required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;

    return SizedBox(
      height: height * 0.5,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: height * 0.07,
              color: AppColors.navy.withOpacity(0.35),
            ),
            SizedBox(height: height * 0.018),
            Text(
              'لا يوجد طلبات حتى الآن',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: height * 0.008),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.14),
              child: Text(
                'ابدأ باكتشاف المتاجر، وخلي أول طلب إلك يكون مميز مع Shoofha ✨',
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
