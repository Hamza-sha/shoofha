// lib/features/feed/application/feed_controller.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'feed_state.dart';

class FeedController extends StateNotifier<FeedState> {
  FeedController() : super(FeedState.initial()) {
    _load(mode: state.mode);
  }

  void setMode(FeedMode mode) {
    if (state.mode == mode) return;

    if (mode != FeedMode.search) {
      state = state.copyWith(mode: mode, activeQuery: () => null);
    } else {
      state = state.copyWith(mode: mode);
    }

    _load(mode: mode);
  }

  void setInterests(Iterable<String> interests) {
    final next = interests.map((e) => e.trim()).where((e) => e.isNotEmpty);
    state = state.copyWith(interests: {...next});

    if (state.mode == FeedMode.forYou) {
      _load(mode: FeedMode.forYou);
    }
  }

  /// ✅ NEW: هذا اللي رح يناديه Explore لما المستخدم يبحث (عطر/شوز/الخ..)
  /// بدون ما نحول الهوم لمود search كامل.
  void registerSearchSignal(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;

    final tokens = _tokenize(q);
    if (tokens.isEmpty) return;

    final decayed = _applyDecay(state.intentWeights);
    final next = <String, double>{...decayed};

    for (final t in tokens) {
      next[t] = (next[t] ?? 0) + 1.0;
    }

    // cap على الحجم
    if (next.length > 25) {
      final sorted = next.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final keep = sorted.take(25);
      next
        ..clear()
        ..addEntries(keep);
    }

    // cap على الوزن
    next.updateAll((k, v) => v.clamp(0.0, 6.0));

    state = state.copyWith(intentWeights: next);

    if (state.mode == FeedMode.forYou) {
      _load(mode: FeedMode.forYou);
    }
  }

  /// (اختياري) لو بدك تفضي إشارات البحث
  void clearIntentSignals() {
    state = state.copyWith(intentWeights: const <String, double>{});
    if (state.mode == FeedMode.forYou) {
      _load(mode: FeedMode.forYou);
    }
  }

  /// شغّال زي قبل (لو عملت صفحة بحث منفصلة)
  void submitSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;

    final sameQuery =
        (state.activeQuery ?? '').toLowerCase() == q.toLowerCase();
    state = state.copyWith(mode: FeedMode.search, activeQuery: () => q);

    if (!sameQuery) {
      _load(mode: FeedMode.search, query: q);
    }
  }

  void clearSearch({FeedMode backTo = FeedMode.forYou}) {
    state = state.copyWith(mode: backTo, activeQuery: () => null);
    _load(mode: backTo);
  }

  void setFollowingStores(Iterable<String> storeIds) {
    state = state.copyWith(followingStoreIds: {...storeIds});
    if (state.mode == FeedMode.following) {
      _load(mode: FeedMode.following);
    }
  }

  Future<void> refresh() async {
    await _load(mode: state.mode, query: state.activeQuery);
  }

  // ----------------------

  Future<void> _load({required FeedMode mode, String? query}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    await Future<void>.delayed(const Duration(milliseconds: 220));

    final reels = switch (mode) {
      FeedMode.forYou => _buildForYouReels(
        interests: state.interests,
        intents: state.intentWeights,
      ),
      FeedMode.following => _buildFollowingReels(
        following: state.followingStoreIds,
      ),
      FeedMode.search => _buildSearchReels(
        query: query ?? state.activeQuery ?? '',
      ),
    };

    state = state.copyWith(reels: reels, isLoading: false);
  }

  List<FeedReel> _buildForYouReels({
    required Set<String> interests,
    required Map<String, double> intents,
  }) {
    final base = _dummyAllReels;

    final lowerInterests = interests.map((e) => e.toLowerCase()).toSet();
    final intentEntries = intents.entries.toList();

    int interestScore(FeedReel r) {
      if (lowerInterests.isEmpty) return 0;
      final cat = r.category.toLowerCase();
      return lowerInterests.any((i) => cat.contains(i)) ? 6 : 0;
    }

    double intentScore(FeedReel r) {
      if (intentEntries.isEmpty) return 0.0;
      final hay = '${r.storeName} ${r.category} ${r.title} ${r.subtitle}'
          .toLowerCase();

      double score = 0.0;
      for (final e in intentEntries) {
        if (hay.contains(e.key)) {
          score += (1.2 * e.value); // boost حسب الوزن
        }
      }
      return score;
    }

    final scored = base.map((r) {
      final s = interestScore(r) + intentScore(r);
      return (score: s, reel: r);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));

    final boosted = scored
        .where((e) => e.score > 0)
        .map((e) => e.reel)
        .toList();
    final rest = scored.where((e) => e.score <= 0).map((e) => e.reel).toList();

    // ✅ Mix: 60% boosted + 40% باقي تنويع
    final total = base.length;
    final boostedTarget = (total * 0.60).round().clamp(0, total);

    final takeBoosted = boosted.take(boostedTarget).toList();
    final takeExplore = _shuffleStable(
      rest,
      seed: 19,
    ).take(total - takeBoosted.length).toList();

    final out = <FeedReel>[
      ..._shuffleStable(takeBoosted, seed: 7),
      ...takeExplore,
    ];

    return out.isEmpty ? _shuffleStable(base, seed: 13) : out;
  }

  List<FeedReel> _buildFollowingReels({required Set<String> following}) {
    if (following.isEmpty) return const <FeedReel>[];

    final filtered = _dummyAllReels
        .where((r) => following.contains(r.storeId))
        .toList();
    return _shuffleStable(filtered, seed: 31);
  }

  List<FeedReel> _buildSearchReels({required String query}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const <FeedReel>[];

    final hits = _dummyAllReels.where((r) {
      final hay = '${r.storeName} ${r.category} ${r.title} ${r.subtitle}'
          .toLowerCase();
      return hay.contains(q);
    }).toList();

    if (hits.isEmpty) return const <FeedReel>[];

    hits.sort((a, b) {
      final at = a.title.toLowerCase().contains(q) ? 1 : 0;
      final bt = b.title.toLowerCase().contains(q) ? 1 : 0;
      return bt.compareTo(at);
    });
    return hits;
  }

  List<String> _tokenize(String q) {
    final cleaned = q.replaceAll(
      RegExp(r'[^\p{L}\p{N}\s]+', unicode: true),
      ' ',
    );
    final raw = cleaned
        .split(RegExp(r'\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return raw.where((t) => t.length >= 2).take(5).toList();
  }

  Map<String, double> _applyDecay(Map<String, double> current) {
    if (current.isEmpty) return current;

    final out = <String, double>{};
    current.forEach((k, v) {
      final next = v * 0.93; // decay 7%
      if (next >= 0.25) out[k] = next;
    });
    return out;
  }

  List<FeedReel> _shuffleStable(List<FeedReel> items, {required int seed}) {
    final rnd = Random(seed);
    final list = [...items];
    for (int i = list.length - 1; i > 0; i--) {
      final j = rnd.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }
}

final feedControllerProvider = StateNotifierProvider<FeedController, FeedState>(
  (ref) => FeedController(),
);

const List<FeedReel> _dummyAllReels = [
  FeedReel(
    id: 'reel-coffee-mood',
    storeId: 'coffee-mood',
    storeName: 'Coffee Mood',
    storeInitial: 'C',
    category: 'كافيه',
    distanceKm: 1.2,
    likes: 12500,
    saves: 3200,
    title: 'خصم 30٪ على كل مشروبات القهوة المختصّة اليوم فقط!',
    subtitle: 'جرّب لاتيه البندق أو الكابتشينو المثلّج بسعر أقل.',
    priceLabel: 'متوسط السعر من 1.5 دينار',
    cta: 'شوف قائمة المشروبات',
    color: Color(0xFF6A1B9A),
  ),
  FeedReel(
    id: 'reel-fit-zone',
    storeId: 'fit-zone',
    storeName: 'Fit Zone Gym',
    storeInitial: 'F',
    category: 'نادي رياضي',
    distanceKm: 2.8,
    likes: 9800,
    saves: 4100,
    title: 'اشترك اليوم وخذ أول أسبوع مجاناً!',
    subtitle: 'أجهزة جديدة + حصص كروس فت وزومبا على مدار الأسبوع.',
    priceLabel: 'الباقات تبدأ من 25 دينار بالشهر',
    cta: 'شوف الباقات والعروض',
    color: Color(0xFF1B5E20),
  ),
  FeedReel(
    id: 'reel-pizza-house',
    storeId: 'pizza-house',
    storeName: 'Pizza House',
    storeInitial: 'P',
    category: 'مطعم بيتزا',
    distanceKm: 0.9,
    likes: 15700,
    saves: 5200,
    title: 'عرض العائلة: 2 بيتزا كبيرة + مشروبات',
    subtitle: 'اختر من منيو البيتزا الخاصة ووفّر لحد 35٪.',
    priceLabel: 'العرض بـ 14.99 دينار فقط',
    cta: 'اطلب العرض الآن',
    color: Color(0xFFD32F2F),
  ),
];
