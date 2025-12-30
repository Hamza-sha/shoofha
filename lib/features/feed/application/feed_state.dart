// lib/features/feed/application/feed_state.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// وضع الفيد في الهوم.
///
/// - [forYou]    : مبني على الاهتمامات + السلوك.
/// - [following] : متاجر المستخدم المتابَعة.
/// - [search]    : بحث مباشر (صفحة/مود بحث).
enum FeedMode { forYou, following, search }

/// موديل بسيط للـ Reel (إعلان متجر).
@immutable
class FeedReel {
  final String id;
  final String storeId;
  final String storeName;
  final String storeInitial;
  final String category;
  final double distanceKm;
  final int likes;
  final int saves;
  final String title;
  final String subtitle;
  final String priceLabel;
  final String cta;
  final Color color;

  const FeedReel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.storeInitial,
    required this.category,
    required this.distanceKm,
    required this.likes,
    required this.saves,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.cta,
    required this.color,
  });
}

@immutable
class FeedState {
  final FeedMode mode;

  /// اهتمامات المستخدم (Seed للـ forYou).
  final Set<String> interests;

  /// آخر query بحث فعّال (Search Mode).
  final String? activeQuery;

  /// ids متاجر المتابعة.
  final Set<String> followingStoreIds;

  /// ✅ NEW: إشارات البحث من Explore (Intent Weights) بدون ما نحول المود لـ search
  /// key = token ، value = weight
  final Map<String, double> intentWeights;

  /// بيانات الفيد الحالية.
  final List<FeedReel> reels;

  /// حالة تحميل بسيطة.
  final bool isLoading;

  const FeedState({
    required this.mode,
    required this.interests,
    required this.activeQuery,
    required this.followingStoreIds,
    required this.intentWeights,
    required this.reels,
    required this.isLoading,
  });

  factory FeedState.initial() {
    return const FeedState(
      mode: FeedMode.forYou,
      interests: <String>{},
      activeQuery: null,
      followingStoreIds: <String>{},
      intentWeights: <String, double>{},
      reels: <FeedReel>[],
      isLoading: false,
    );
  }

  FeedState copyWith({
    FeedMode? mode,
    Set<String>? interests,
    String? Function()? activeQuery,
    Set<String>? followingStoreIds,
    Map<String, double>? intentWeights,
    List<FeedReel>? reels,
    bool? isLoading,
  }) {
    return FeedState(
      mode: mode ?? this.mode,
      interests: interests ?? this.interests,
      activeQuery: activeQuery != null ? activeQuery() : this.activeQuery,
      followingStoreIds: followingStoreIds ?? this.followingStoreIds,
      intentWeights: intentWeights ?? this.intentWeights,
      reels: reels ?? this.reels,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
