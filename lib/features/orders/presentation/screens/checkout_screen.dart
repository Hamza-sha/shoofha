import 'package:flutter/material.dart';

import 'package:shoofha/core/responsive/responsive.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedAddress = 'البيت';
  String _selectedPayment = 'كاش عند الاستلام';

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;

    // مؤقتاً أرقام ثابتة، لاحقاً نجيبها من CartController
    const double subTotal = 32.64;
    const double deliveryFee = 1.50;
    const double total = subTotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'العنوان',
              style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: h * 0.010),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'البيت',
                    groupValue: _selectedAddress,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedAddress = v);
                    },
                    title: const Text('البيت'),
                    subtitle: const Text('عمّان، الأردن'),
                  ),
                  const Divider(height: 0),
                  RadioListTile<String>(
                    value: 'العمل',
                    groupValue: _selectedAddress,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedAddress = v);
                    },
                    title: const Text('العمل'),
                    subtitle: const Text('الدوار الخامس'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.add_location_alt_outlined),
                    title: const Text('إضافة عنوان جديد'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('إضافة عنوان جديد (قريباً)'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.025),

            Text(
              'طريقة الدفع',
              style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: h * 0.010),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'كاش عند الاستلام',
                    groupValue: _selectedPayment,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedPayment = v);
                    },
                    title: const Text('كاش عند الاستلام'),
                  ),
                  const Divider(height: 0),
                  RadioListTile<String>(
                    value: 'بطاقة بنكية',
                    groupValue: _selectedPayment,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedPayment = v);
                    },
                    title: const Text('بطاقة بنكية'),
                    subtitle: const Text('الدفع الإلكتروني سيتم تفعيله لاحقاً'),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.025),

            Text(
              'ملخص الطلب',
              style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: h * 0.010),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(w * 0.035),
                child: Column(
                  children: [
                    _SummaryRow(label: 'المجموع', value: subTotal),
                    SizedBox(height: h * 0.004),
                    _SummaryRow(label: 'رسوم التوصيل', value: deliveryFee),
                    SizedBox(height: h * 0.010),
                    Divider(height: h * 0.01),
                    SizedBox(height: h * 0.010),
                    _SummaryRow(
                      label: 'الإجمالي',
                      value: total,
                      isBold: true,
                      valueColor: cs.primary,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: h * 0.02),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم إرسال طلبك ($_selectedPayment) إلى $_selectedAddress ✅',
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: h * 0.013),
                ),
                child: Text(
                  'تأكيد الطلب',
                  style: TextStyle(
                    fontSize: w * 0.040,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final cs = Theme.of(context).colorScheme;

    final textStyle = TextStyle(
      fontSize: w * 0.035,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(
          '${value.toStringAsFixed(2)} د.أ',
          style: textStyle.copyWith(color: valueColor ?? cs.onSurface),
        ),
      ],
    );
  }
}
