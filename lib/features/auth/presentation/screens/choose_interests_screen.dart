import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/features/auth/application/auth_notifier.dart';
import '../widgets/auth_header.dart';
import '../widgets/interest_chip.dart';

class InterestCategory {
  final String id;
  final String title;
  final IconData icon;
  final List<String> subInterests;

  const InterestCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.subInterests,
  });
}

class ChooseInterestsScreen extends StatefulWidget {
  const ChooseInterestsScreen({super.key});

  @override
  State<ChooseInterestsScreen> createState() => _ChooseInterestsScreenState();
}

class _ChooseInterestsScreenState extends State<ChooseInterestsScreen> {
  static const int _minSelections = 3;

  // الكاتيجوري العامة
  final List<InterestCategory> _categories = const [
    InterestCategory(
      id: 'fashion',
      title: 'Fashion & Clothing',
      icon: Icons.checkroom_outlined,
      subInterests: [
        'Outfit of the Day',
        'Fashion Photography',
        'Tailoring & Sewing',
        'Fashion Design',
        'Clothing Reviews',
        'Body Shape Styling',
      ],
    ),
    InterestCategory(
      id: 'accessories',
      title: 'Accessories',
      icon: Icons.watch_outlined,
      subInterests: [
        'Fashion Accessories',
        'Personal Accessories',
        'Style Accessories',
        'Trendy Accessories',
        'Everyday Accessories',
      ],
    ),
    InterestCategory(
      id: 'home',
      title: 'Home & Decor',
      icon: Icons.chair_outlined,
      subInterests: [
        'Home Decoration',
        'Furniture',
        'Lighting',
        'Smart Home',
        'Kitchen & Dining',
      ],
    ),
    InterestCategory(
      id: 'electronics',
      title: 'Electronics',
      icon: Icons.devices_other_outlined,
      subInterests: [
        'Smartphones',
        'Laptops',
        'Cameras',
        'Gaming',
        'Audio & Headphones',
      ],
    ),
    InterestCategory(
      id: 'beauty',
      title: 'Beauty & Care',
      icon: Icons.brush_outlined,
      subInterests: ['Makeup', 'Skin Care', 'Hair Care', 'Perfumes', 'Nails'],
    ),
    InterestCategory(
      id: 'sports',
      title: 'Sports & Health',
      icon: Icons.fitness_center_outlined,
      subInterests: [
        'Gym & Workout',
        'Running',
        'Yoga & Meditation',
        'Healthy Lifestyle',
      ],
    ),
    InterestCategory(
      id: 'food',
      title: 'Food & Restaurants',
      icon: Icons.restaurant_outlined,
      subInterests: [
        'Restaurants',
        'Street Food',
        'Healthy Food',
        'Desserts',
        'Cooking & Recipes',
      ],
    ),
    InterestCategory(
      id: 'gifts',
      title: 'Gifts',
      icon: Icons.card_giftcard_outlined,
      subInterests: [
        'Birthday Gifts',
        'Occasion Gifts',
        'Customized Gifts',
        'Surprise Ideas',
      ],
    ),
  ];

  late String _selectedCategoryId;
  final Set<String> _selectedSubInterests = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = _categories.first.id;
  }

  InterestCategory get _currentCategory =>
      _categories.firstWhere((c) => c.id == _selectedCategoryId);

  bool get _canConfirm =>
      !_loading && _selectedSubInterests.length >= _minSelections;

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 1100),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onConfirm() async {
    if (_loading) return;

    if (_selectedSubInterests.length < _minSelections) {
      _showSnack('اختر $_minSelections اهتمامات على الأقل');
      return;
    }

    setState(() => _loading = true);

    try {
      // TODO: خزن _selectedSubInterests في API / local storage
      await Future<void>.delayed(const Duration(milliseconds: 450));

      authNotifier.completeInterests();

      if (mounted) {
        context.go('/app');
      }
    } catch (e) {
      debugPrint('Complete interests error: $e');
      if (mounted) _showSnack('صار خطأ، حاول مرة ثانية');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final chipHeight = height * 0.07;
    final horizontalPadding = width * 0.08;

    // ✅ states جاهزة
    final hasCategories = _categories.isNotEmpty;
    final hasSubs = hasCategories && _currentCategory.subInterests.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AuthHeader(showBack: true),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Interests',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      'Select what you are interested in so we can tailor content for you.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),

                    // ✅ Counter + hint
                    Row(
                      children: [
                        Text(
                          '${_selectedSubInterests.length} selected',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Min $_minSelections',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.55),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.02),

                    // ✅ Categories
                    if (!hasCategories)
                      Expanded(
                        child: Center(
                          child: Text(
                            'No categories yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      )
                    else ...[
                      SizedBox(
                        height: chipHeight,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: width * 0.03),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected =
                                category.id == _selectedCategoryId;

                            final borderRadius = BorderRadius.circular(
                              height * 0.035,
                            );
                            final iconSize = height * 0.028;

                            final bgColor = isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest
                                      .withOpacity(
                                        theme.brightness == Brightness.light
                                            ? 0.45
                                            : 0.14,
                                      );

                            final borderColor = isSelected
                                ? colorScheme.primary
                                : colorScheme.outline.withOpacity(
                                    theme.brightness == Brightness.light
                                        ? 0.25
                                        : 0.35,
                                  );

                            final textColor = isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface.withOpacity(0.85);

                            return InkWell(
                              borderRadius: borderRadius,
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = category.id;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.04,
                                ),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: borderRadius,
                                  border: Border.all(
                                    color: borderColor,
                                    width: height * 0.0015,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      category.icon,
                                      size: iconSize,
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.primary,
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      category.title,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: textColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: height * 0.03),

                      Text(
                        _currentCategory.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: height * 0.015),

                      // ✅ Sub interests
                      Expanded(
                        child: hasSubs
                            ? SingleChildScrollView(
                                child: Wrap(
                                  spacing: width * 0.03,
                                  runSpacing: height * 0.012,
                                  children: _currentCategory.subInterests.map((
                                    label,
                                  ) {
                                    final isSelected = _selectedSubInterests
                                        .contains(label);

                                    return InterestChip(
                                      label: label,
                                      icon: _iconForLabel(label), // ✅ NEW
                                      selected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedSubInterests.remove(label);
                                          } else {
                                            _selectedSubInterests.add(label);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              )
                            : Center(
                                child: Text(
                                  'No interests in this category',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      SizedBox(height: height * 0.02),

                      SizedBox(
                        width: double.infinity,
                        height: height * 0.065,
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : FilledButton(
                                onPressed: _canConfirm ? _onConfirm : null,
                                child: Text(
                                  'Confirm',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),

                      SizedBox(height: height * 0.025),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ mapping بسيط يعطي icon لكل sub-interest (global feeling)
  IconData _iconForLabel(String label) {
    final l = label.toLowerCase();

    if (l.contains('outfit') ||
        l.contains('fashion') ||
        l.contains('clothing') ||
        l.contains('design')) {
      return Icons.checkroom_outlined;
    }
    if (l.contains('camera') || l.contains('photography')) {
      return Icons.photo_camera_outlined;
    }
    if (l.contains('sewing') || l.contains('tailoring')) {
      return Icons.content_cut_outlined;
    }
    if (l.contains('smartphone') ||
        l.contains('laptop') ||
        l.contains('electronics')) {
      return Icons.devices_other_outlined;
    }
    if (l.contains('gaming')) {
      return Icons.sports_esports_outlined;
    }
    if (l.contains('audio') || l.contains('headphone')) {
      return Icons.headphones_outlined;
    }
    if (l.contains('makeup') || l.contains('beauty') || l.contains('nails')) {
      return Icons.brush_outlined;
    }
    if (l.contains('skin') || l.contains('hair') || l.contains('perfume')) {
      return Icons.spa_outlined;
    }
    if (l.contains('gym') || l.contains('workout') || l.contains('running')) {
      return Icons.fitness_center_outlined;
    }
    if (l.contains('yoga') ||
        l.contains('meditation') ||
        l.contains('healthy')) {
      return Icons.self_improvement_outlined;
    }
    if (l.contains('restaurant') ||
        l.contains('food') ||
        l.contains('dessert') ||
        l.contains('recipes')) {
      return Icons.restaurant_outlined;
    }
    if (l.contains('home') || l.contains('decor') || l.contains('furniture')) {
      return Icons.chair_outlined;
    }
    if (l.contains('light')) {
      return Icons.lightbulb_outline;
    }
    if (l.contains('kitchen') || l.contains('dining')) {
      return Icons.kitchen_outlined;
    }
    if (l.contains('gift') ||
        l.contains('birthday') ||
        l.contains('surprise')) {
      return Icons.card_giftcard_outlined;
    }

    return Icons.local_offer_outlined;
  }
}
