import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/theme/app_colors.dart';

class OrderSuccessArgs {
  final String orderId;
  final double total;

  const OrderSuccessArgs({required this.orderId, required this.total});
}

class OrderSuccessScreen extends StatelessWidget {
  final OrderSuccessArgs args;

  const OrderSuccessScreen({super.key, required this.args});

  void _copyOrderId(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: args.orderId));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ رقم الطلب ✅'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false, // ✅ يمنع الرجوع للـ Checkout
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navy, AppColors.purple],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.08),
                child: Column(
                  children: [
                    SizedBox(height: h * 0.10),
                    Container(
                      width: w * 0.28,
                      height: w * 0.28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: w * 0.18,
                      ),
                    ),
                    SizedBox(height: h * 0.03),
                    Text(
                      'تم إرسال الطلب بنجاح ✅',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: h * 0.012),

                    // ✅ تفاصيل + زر نسخ رقم الطلب
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.05,
                        vertical: h * 0.018,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'رقم الطلب: ${args.orderId}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.92),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _copyOrderId(context),
                                icon: Icon(
                                  Icons.copy_rounded,
                                  color: Colors.white.withOpacity(0.92),
                                ),
                                tooltip: 'نسخ رقم الطلب',
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.008),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'الإجمالي:',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ),
                              Text(
                                '${args.total.toStringAsFixed(2)} د.أ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    Text(
                      'رح نبلّشك بتحديثات حالة الطلب أول بأول.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // ✅ زر تتبع الطلب
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          // حالياً يروح على الطلبات (لاحقاً: صفحة تفاصيل الطلب)
                          context.goNamed('orders');
                        },
                        child: const Text('تتبع الطلب'),
                      ),
                    ),

                    SizedBox(height: h * 0.012),

                    // ✅ رجوع للرئيسية (يمسح الستاك عملياً)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.goNamed('app');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        child: const Text('الرجوع للرئيسية'),
                      ),
                    ),

                    SizedBox(height: h * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
