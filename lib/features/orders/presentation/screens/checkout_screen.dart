import 'package:flutter/material.dart';
import 'package:shoofha/features/commerce/presentation/screens/checkout_screen.dart'
    as commerce;

/// Wrapper لتجنب تكرار شاشة Checkout القديمة داخل features/orders.
/// أي Route قديم كان يشير على Orders Checkout سيحوّل تلقائياً
/// على شاشة Checkout العالمية الجديدة داخل features/commerce.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const commerce.CheckoutScreen();
  }
}
