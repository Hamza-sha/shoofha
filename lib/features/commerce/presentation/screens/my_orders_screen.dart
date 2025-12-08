import 'package:flutter/material.dart';

import 'package:shoofha/core/responsive/responsive.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;

    final orders = _dummyOrders;

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
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
                horizontal: w * 0.04,
                vertical: h * 0.015,
              ),
              itemCount: orders.length,
              separatorBuilder: (_, __) => SizedBox(height: h * 0.012),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;

    final statusData = _statusMap[order.status]!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.all(w * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رقم الطلب + الحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.number}',
                  style: TextStyle(
                    fontSize: w * 0.042,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.02,
                    vertical: w * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: statusData.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusData.icon,
                        size: w * 0.035,
                        color: statusData.color,
                      ),
                      SizedBox(width: w * 0.01),
                      Text(
                        statusData.label,
                        style: TextStyle(
                          fontSize: w * 0.032,
                          color: statusData.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: h * 0.006),
            Text(
              order.dateLabel,
              style: TextStyle(
                fontSize: w * 0.032,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),

            SizedBox(height: h * 0.01),

            // المنتجات
            Column(
              children: order.items.map((item) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: h * 0.003),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.name} × ${item.quantity}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: w * 0.035),
                        ),
                      ),
                      Text(
                        '${item.total.toStringAsFixed(2)} د.أ',
                        style: TextStyle(
                          fontSize: w * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: h * 0.010),

            const Divider(),

            // الإجمالي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: TextStyle(
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${order.total.toStringAsFixed(2)} د.أ',
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
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

// Models

enum _OrderStatus { pending, ready, completed, cancelled }

class _OrderStatusData {
  final String label;
  final Color color;
  final IconData icon;

  _OrderStatusData({
    required this.label,
    required this.color,
    required this.icon,
  });
}

final Map<_OrderStatus, _OrderStatusData> _statusMap = {
  _OrderStatus.pending: _OrderStatusData(
    label: 'قيد المعالجة',
    color: const Color(0xFFFB8C00),
    icon: Icons.schedule_outlined,
  ),
  _OrderStatus.ready: _OrderStatusData(
    label: 'جاهز للاستلام',
    color: const Color(0xFF1976D2),
    icon: Icons.delivery_dining_outlined,
  ),
  _OrderStatus.completed: _OrderStatusData(
    label: 'مكتمل',
    color: const Color(0xFF2E7D32),
    icon: Icons.check_circle_outline,
  ),
  _OrderStatus.cancelled: _OrderStatusData(
    label: 'ملغي',
    color: const Color(0xFFE53935),
    icon: Icons.cancel_outlined,
  ),
};

class _OrderItem {
  final String name;
  final int quantity;
  final double price;

  _OrderItem({required this.name, required this.quantity, required this.price});

  double get total => price * quantity;
}

class _Order {
  final String id;
  final String number;
  final String dateLabel;
  final _OrderStatus status;
  final List<_OrderItem> items;

  _Order({
    required this.id,
    required this.number,
    required this.dateLabel,
    required this.status,
    required this.items,
  });

  double get total => items.fold(0, (sum, i) => sum + i.total);
}

// Dummy data

final List<_Order> _dummyOrders = [
  _Order(
    id: 'o1',
    number: '1023',
    dateLabel: 'اليوم - 3:45 م',
    status: _OrderStatus.ready,
    items: [
      _OrderItem(name: 'سماعات لاسلكية Pro', quantity: 1, price: 49.0),
      _OrderItem(name: 'باور بانك 20,000mAh', quantity: 1, price: 29.0),
    ],
  ),
  _Order(
    id: 'o2',
    number: '1017',
    dateLabel: 'أمس - 9:10 م',
    status: _OrderStatus.completed,
    items: [
      _OrderItem(name: 'آيس لاتيه', quantity: 2, price: 2.50),
      _OrderItem(name: 'كاراميل ماكياتو', quantity: 1, price: 3.00),
    ],
  ),
  _Order(
    id: 'o3',
    number: '1009',
    dateLabel: 'منذ 3 أيام',
    status: _OrderStatus.cancelled,
    items: [
      _OrderItem(name: 'اشتراك شهر في FitZone', quantity: 1, price: 35.0),
    ],
  ),
];
