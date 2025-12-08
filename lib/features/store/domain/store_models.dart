import 'package:flutter/material.dart';

class StoreModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final double distanceKm;
  final Color color; // لون مميز لكل متجر

  StoreModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.distanceKm,
    required this.color,
  });
}

class StoreProduct {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final Color color;

  StoreProduct({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.color,
  });
}

/// متاجر تجريبية
final List<StoreModel> kStores = [
  StoreModel(
    id: 'coffee-mood',
    name: 'Coffee Mood',
    category: 'كافيه',
    rating: 4.7,
    distanceKm: 1.3,
    color: const Color(0xFF6A1B9A),
  ),
  StoreModel(
    id: 'fit-zone',
    name: 'FitZone Gym',
    category: 'نادي رياضي',
    rating: 4.6,
    distanceKm: 3.2,
    color: const Color(0xFF1B5E20),
  ),
  StoreModel(
    id: 'tech-corner',
    name: 'Tech Corner',
    category: 'الكترونيات',
    rating: 4.5,
    distanceKm: 4.8,
    color: const Color(0xFF0D47A1),
  ),
];

/// منتجات تجريبية للمتاجر
final List<StoreProduct> kStoreProducts = [
  StoreProduct(
    id: 'coffee-latte',
    storeId: 'coffee-mood',
    name: 'آيس لاتيه',
    description: 'قهوة لاتيه باردة مع حليب طازج ونكهة فانيلا.',
    price: 2.5,
    color: const Color(0xFF6A1B9A),
  ),
  StoreProduct(
    id: 'coffee-caramel',
    storeId: 'coffee-mood',
    name: 'كاراميل ماكياتو',
    description: 'إسبريسو مع حليب وكاراميل غني.',
    price: 3.0,
    color: const Color(0xFFAB47BC),
  ),
  StoreProduct(
    id: 'gym-month',
    storeId: 'fit-zone',
    name: 'اشتراك شهر',
    description: 'اشتراك شهر كامل مع دخول غير محدود للنادي.',
    price: 35.0,
    color: const Color(0xFF1B5E20),
  ),
  StoreProduct(
    id: 'gym-3months',
    storeId: 'fit-zone',
    name: 'اشتراك 3 أشهر',
    description: 'عرض خاص على اشتراك 3 أشهر.',
    price: 90.0,
    color: const Color(0xFF388E3C),
  ),
  StoreProduct(
    id: 'earbuds-pro',
    storeId: 'tech-corner',
    name: 'سماعات لاسلكية Pro',
    description: 'سماعات بجودة عالية وعزل ضوضاء.',
    price: 49.0,
    color: const Color(0xFF0D47A1),
  ),
  StoreProduct(
    id: 'power-bank',
    storeId: 'tech-corner',
    name: 'باور بانك 20,000mAh',
    description: 'شحن سريع مع سعة كبيرة.',
    price: 29.0,
    color: const Color(0xFF1976D2),
  ),
];

StoreModel? getStoreById(String id) {
  try {
    return kStores.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
}

StoreProduct? getProductById(String id) {
  try {
    return kStoreProducts.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}

List<StoreProduct> getProductsForStore(String storeId) {
  return kStoreProducts.where((p) => p.storeId == storeId).toList();
}
