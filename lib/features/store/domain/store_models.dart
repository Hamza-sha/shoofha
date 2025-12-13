import 'package:flutter/material.dart';

class StoreModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final double distanceKm;
  final Color color; // لون مميز لكل متجر

  const StoreModel({
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

  const StoreProduct({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.color,
  });
}

/// متاجر تجريبية
const List<StoreModel> kStores = [
  StoreModel(
    id: 'coffee-mood',
    name: 'Coffee Mood',
    category: 'كافيه',
    rating: 4.7,
    distanceKm: 1.3,
    color: Color(0xFF6A1B9A),
  ),
  StoreModel(
    id: 'fit-zone',
    name: 'Fit Zone Gym',
    category: 'نادي رياضي',
    rating: 4.5,
    distanceKm: 2.8,
    color: Color(0xFF1B5E20),
  ),
  StoreModel(
    id: 'pizza-house',
    name: 'Pizza House',
    category: 'مطعم بيتزا',
    rating: 4.6,
    distanceKm: 0.9,
    color: Color(0xFFD32F2F),
  ),
];

/// منتجات تجريبية لكل متجر
const List<StoreProduct> kStoreProducts = [
  // Coffee Mood
  StoreProduct(
    id: 'coffee-latte-hazelnut',
    storeId: 'coffee-mood',
    name: 'لاتيه بالبندق',
    description: 'قهوة اسبريسو مع حليب وبندق محمّص، ساخنة أو مثلّجة.',
    price: 3.25,
    color: Color(0xFF8D6E63),
  ),
  StoreProduct(
    id: 'coffee-spanish',
    storeId: 'coffee-mood',
    name: 'سبانيش لاتيه',
    description: 'مزيج قهوة غني مع حليب مكثّف وسيرب خاص.',
    price: 3.75,
    color: Color(0xFF5D4037),
  ),
  StoreProduct(
    id: 'coffee-cold-brew',
    storeId: 'coffee-mood',
    name: 'كولد برو',
    description: 'قهوة كولد برو من حبوب مختارة، منعشة ومركزة.',
    price: 3.00,
    color: Color(0xFF3E2723),
  ),

  // Fit Zone Gym
  StoreProduct(
    id: 'fit-monthly-basic',
    storeId: 'fit-zone',
    name: 'اشتراك شهري أساسي',
    description: 'دخول غير محدود للنادي خلال أوقات العمل.',
    price: 25.0,
    color: Color(0xFF1B5E20),
  ),
  StoreProduct(
    id: 'fit-monthly-plus',
    storeId: 'fit-zone',
    name: 'اشتراك شهري + حصص',
    description: 'يشمل حصص كروس فت وزومبا أسبوعية.',
    price: 35.0,
    color: Color(0xFF2E7D32),
  ),
  StoreProduct(
    id: 'fit-personal-session',
    storeId: 'fit-zone',
    name: 'جلسة تدريب شخصي',
    description: 'جلسة واحدة مع مدرب شخصي مع خطة مخصصة.',
    price: 12.0,
    color: Color(0xFF388E3C),
  ),

  // Pizza House
  StoreProduct(
    id: 'pizza-family-offer',
    storeId: 'pizza-house',
    name: 'عرض العائلة',
    description: '2 بيتزا كبيرة + مشروبات + صوصات خاصة.',
    price: 14.99,
    color: Color(0xFFD32F2F),
  ),
  StoreProduct(
    id: 'pizza-margherita',
    storeId: 'pizza-house',
    name: 'بيتزا مارجريتا',
    description: 'جبنة موزاريلا طازجة مع صوص طماطم إيطالي.',
    price: 6.50,
    color: Color(0xFFC62828),
  ),
  StoreProduct(
    id: 'pizza-pepperoni',
    storeId: 'pizza-house',
    name: 'بيتزا بيبروني',
    description: 'مغطاة بشرائح بيبروني حارة وجبنة موزاريلا.',
    price: 7.25,
    color: Color(0xFFB71C1C),
  ),
];
