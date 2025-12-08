// lib/features/cart/application/cart_controller.dart

import 'package:flutter_riverpod/legacy.dart';

import 'package:shoofha/features/store/domain/store_models.dart';

class CartItem {
  final StoreProduct product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => items.isEmpty ? 0.0 : 1.5;

  double get total => subTotal + deliveryFee;
}

class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState());

  /// إضافة منتج للسلة
  void addItem(StoreProduct product, {int quantity = 1}) {
    final existingIndex = state.items.indexWhere(
      (i) => i.product.id == product.id,
    );

    if (existingIndex == -1) {
      state = CartState(
        items: [
          ...state.items,
          CartItem(product: product, quantity: quantity),
        ],
      );
    } else {
      final existing = state.items[existingIndex];
      final updated = existing.copyWith(quantity: existing.quantity + quantity);
      final newItems = [...state.items];
      newItems[existingIndex] = updated;
      state = CartState(items: newItems);
    }
  }

  /// حذف منتج من السلة
  void removeItem(String productId) {
    state = CartState(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  /// تغيير الكمية
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;

    final updated = state.items[index].copyWith(quantity: quantity);
    final newItems = [...state.items];
    newItems[index] = updated;
    state = CartState(items: newItems);
  }

  /// مسح السلة بالكامل
  void clear() {
    state = const CartState(items: []);
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>(
  (ref) => CartController(),
);
