import 'package:flutter/material.dart';

enum OrderStatus { pending, preparing, onTheWay, delivered, cancelled }

class OrderModel {
  final String id;
  final DateTime date;
  final String storeName;
  final double total;
  final int itemsCount;
  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.date,
    required this.storeName,
    required this.total,
    required this.itemsCount,
    required this.status,
  });
}

String orderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'بانتظار التأكيد';
    case OrderStatus.preparing:
      return 'قيد التحضير';
    case OrderStatus.onTheWay:
      return 'في الطريق';
    case OrderStatus.delivered:
      return 'تم التسليم';
    case OrderStatus.cancelled:
      return 'تم الإلغاء';
  }
}

Color orderStatusColor(OrderStatus status, ColorScheme cs) {
  switch (status) {
    case OrderStatus.pending:
      return cs.primary;
    case OrderStatus.preparing:
      return cs.secondary;
    case OrderStatus.onTheWay:
      return Colors.orange;
    case OrderStatus.delivered:
      return Colors.green;
    case OrderStatus.cancelled:
      return Colors.red;
  }
}

/// طلبات تجريبية
final List<OrderModel> kDummyOrders = [
  OrderModel(
    id: 'ORD-1001',
    date: DateTime(2025, 1, 21, 19, 30),
    storeName: 'Tech Corner',
    total: 39.98,
    itemsCount: 2,
    status: OrderStatus.delivered,
  ),
  OrderModel(
    id: 'ORD-1002',
    date: DateTime(2025, 1, 22, 13, 15),
    storeName: 'Coffee Mood',
    total: 4.80,
    itemsCount: 2,
    status: OrderStatus.onTheWay,
  ),
  OrderModel(
    id: 'ORD-1003',
    date: DateTime(2025, 1, 23, 11, 5),
    storeName: 'Fresh Burger',
    total: 5.75,
    itemsCount: 1,
    status: OrderStatus.preparing,
  ),
];
