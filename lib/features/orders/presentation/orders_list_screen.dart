import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;

    final orders = _dummyOrders;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلباتي'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('app');
              }
            },
          ),
        ),
        body: orders.isEmpty
            ? Center(
                child: Text(
                  'لسا ما عملت ولا طلب 👀',
                  style: TextStyle(
                    fontSize: w * 0.04,
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.06,
                  vertical: h * 0.02,
                ),
                itemCount: orders.length,
                separatorBuilder: (_, __) => SizedBox(height: h * 0.012),
                itemBuilder: (context, i) {
                  final order = orders[i];
                  final statusData = _statusMap[order.status]!;
                  return Container(
                    padding: EdgeInsets.all(w * 0.04),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(h * 0.018),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: h * 0.018,
                          offset: Offset(0, h * 0.008),
                        ),
                      ],
                      border: Border.all(color: cs.outline.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '#${order.number}',
                                style: TextStyle(
                                  fontSize: w * 0.042,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.02,
                                vertical: w * 0.005,
                              ),
                              decoration: BoxDecoration(
                                color: statusData.color.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(h * 0.012),
                              ),
                              child: Text(
                                statusData.label,
                                style: TextStyle(
                                  fontSize: w * 0.032,
                                  fontWeight: FontWeight.w700,
                                  color: statusData.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.008),
                        Text(
                          order.storeName,
                          style: TextStyle(
                            fontSize: w * 0.036,
                            color: cs.onSurface.withOpacity(0.75),
                          ),
                        ),
                        SizedBox(height: h * 0.010),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: w * 0.040,
                              color: cs.onSurface.withOpacity(0.55),
                            ),
                            SizedBox(width: w * 0.02),
                            Expanded(
                              child: Text(
                                order.dateLabel,
                                style: TextStyle(
                                  fontSize: w * 0.032,
                                  color: cs.onSurface.withOpacity(0.60),
                                ),
                              ),
                            ),
                            Text(
                              '${order.total.toStringAsFixed(2)} د.أ',
                              style: TextStyle(
                                fontSize: w * 0.038,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// ===== Dummy Models =====

enum _OrderStatus { processing, delivering, delivered, canceled }

class _OrderItem {
  final String number;
  final String storeName;
  final _OrderStatus status;
  final String dateLabel;
  final double total;

  const _OrderItem({
    required this.number,
    required this.storeName,
    required this.status,
    required this.dateLabel,
    required this.total,
  });
}

class _StatusUI {
  final String label;
  final Color color;
  const _StatusUI(this.label, this.color);
}

const _statusMap = <_OrderStatus, _StatusUI>{
  _OrderStatus.processing: _StatusUI('قيد المعالجة', Colors.orange),
  _OrderStatus.delivering: _StatusUI('قيد التوصيل', Colors.blue),
  _OrderStatus.delivered: _StatusUI('تم التسليم', Colors.green),
  _OrderStatus.canceled: _StatusUI('ملغي', Colors.redAccent),
};

final _dummyOrders = <_OrderItem>[
  _OrderItem(
    number: 'SH-1024',
    storeName: 'Coffee Mood',
    status: _OrderStatus.processing,
    dateLabel: 'اليوم - 10:30 ص',
    total: 12.50,
  ),
  _OrderItem(
    number: 'SH-0987',
    storeName: 'Fit Zone',
    status: _OrderStatus.delivered,
    dateLabel: 'أمس - 5:20 م',
    total: 34.90,
  ),
  _OrderItem(
    number: 'SH-0870',
    storeName: 'Burger Hub',
    status: _OrderStatus.canceled,
    dateLabel: 'منذ 3 أيام',
    total: 22.00,
  ),
];
