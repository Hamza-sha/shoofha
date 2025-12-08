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

  Future<void> _onConfirm() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      // TODO: خزن _selectedSubInterests في API / local storage إذا حاب
      await Future<void>.delayed(const Duration(milliseconds: 600));

      authNotifier.completeInterests();

      if (mounted) {
        context.go('/app');
      }
    } catch (e) {
      debugPrint('Complete interests error: $e');
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AuthHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان الرئيسي
                    Text(
                      // TODO: استبدلها بـ ترجمة من AppLocalizations لما تجهز
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
                    SizedBox(height: height * 0.025),

                    // الكاتيجوري العامة (هوريزنتال)
                    SizedBox(
                      height: chipHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: width * 0.03),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = category.id == _selectedCategoryId;

                          final borderRadius = BorderRadius.circular(
                            height * 0.035,
                          );
                          final iconSize = height * 0.028;

                          final bgColor = isSelected
                              ? colorScheme.primary
                              : Colors.transparent;
                          final borderColor = isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.8);
                          final textColor = isSelected
                              ? colorScheme.onPrimary
                              : theme.textTheme.bodyMedium?.color;

                          return InkWell(
                            borderRadius: borderRadius,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = category.id;
                              });
                            },
                            child: Container(
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
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
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

                    // عنوان الفئات الفرعية
                    Text(
                      _currentCategory.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: height * 0.015),

                    // الفئات الفرعية
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: width * 0.03,
                          runSpacing: height * 0.012,
                          children: _currentCategory.subInterests.map((label) {
                            final isSelected = _selectedSubInterests.contains(
                              label,
                            );
                            return InterestChip(
                              label: label,
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
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    // زر التأكيد
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.065,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : FilledButton(
                              onPressed: _onConfirm,
                              child: Text(
                                'Confirm', // TODO: ترجمها لاحقاً
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(height: height * 0.025),
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
