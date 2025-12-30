import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoofha/core/theme/app_colors.dart';
import 'package:shoofha/features/feed/application/feed_controller.dart';

enum ExploreFilter { all, near, topRated, newest, recommended }

/// ✅ Persisted Search History (SharedPreferences)
class ExploreSearchHistoryController extends StateNotifier<List<String>> {
  ExploreSearchHistoryController() : super(const []) {
    _load();
  }

  static const _prefsKey = 'explore_search_history_v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKey) ?? const <String>[];
      state = list;
    } catch (_) {
      // ignore (keep empty)
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, state);
    } catch (_) {
      // ignore
    }
  }

  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;

    final next = <String>[
      q,
      ...state.where((e) => e.toLowerCase() != q.toLowerCase()),
    ];

    state = next.take(12).toList();
    _save();
  }

  void remove(String q) {
    state = state.where((e) => e.toLowerCase() != q.toLowerCase()).toList();
    _save();
  }

  void clear() {
    state = const [];
    _save();
  }
}

final exploreSearchHistoryProvider =
    StateNotifierProvider<ExploreSearchHistoryController, List<String>>(
      (ref) => ExploreSearchHistoryController(),
    );

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  ExploreFilter _selectedFilter = ExploreFilter.all;

  bool _showSearchPanel = false;

  String get _query => _searchController.text.trim().toLowerCase();

  @override
  void initState() {
    super.initState();

    _searchFocus.addListener(() {
      if (!mounted) return;
      setState(() => _showSearchPanel = _searchFocus.hasFocus);
    });

    _searchController.addListener(() {
      if (!mounted) return;
      // ✅ UX: لو المستخدم عم يكتب وهو focused، خلّي البانل دايمًا ظاهر
      if (_searchFocus.hasFocus && !_showSearchPanel) {
        setState(() => _showSearchPanel = true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openFiltersSheet() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            w * 0.06,
            h * 0.015,
            w * 0.06,
            h * 0.02 + MediaQuery.of(context).viewPadding.bottom,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(h * 0.03)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.light ? 0.08 : 0.55,
                ),
                blurRadius: h * 0.03,
                offset: Offset(0, -h * 0.01),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: w * 0.12,
                height: h * 0.006,
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: h * 0.02),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'فلاتر',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: h * 0.01),
              Text(
                'قريباً رح نخليها فلترة متقدمة (تصنيف، سعر، تقييم، مسافة).',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: h * 0.02),
              SizedBox(
                width: double.infinity,
                height: h * 0.06,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'تمام',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _closeSearchPanel() {
    _searchFocus.unfocus();
    setState(() => _showSearchPanel = false);
  }

  /// ✅ execute search + update explore + signal feed + close keyboard/panel
  void _submitExploreQuery({String? overrideQuery}) {
    final q = (overrideQuery ?? _searchController.text).trim();
    if (q.isEmpty) return;

    if (overrideQuery != null) {
      _searchController.text = q;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    // ✅ سجل آخر بحث
    ref.read(exploreSearchHistoryProvider.notifier).add(q);

    // ✅ signal للـ feed (ذكاء + synonyms بدون ما نزعج)
    final expanded = _expandTokens(q);
    ref.read(feedControllerProvider.notifier).registerSearchSignal(q);
    for (final t
        in expanded.where((e) => e.toLowerCase() != q.toLowerCase()).take(2)) {
      ref.read(feedControllerProvider.notifier).registerSearchSignal(t);
    }

    // ✅ سكّر الكيبورد والبانل
    _closeSearchPanel();
  }

  void _openStore(_StoreItem store) {
    _closeSearchPanel();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => StoreProfileScreen(store: store)));
  }

  void _openReel(_ReelItem reel) {
    _closeSearchPanel();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ReelViewerScreen(reel: reel)));
  }

  List<String> _expandTokens(String q) {
    final base = q
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final out = <String>{...base};

    const syn = <String, List<String>>{
      'عطر': ['عطور', 'perfume', 'fragrance', 'كولونيا'],
      'عطور': ['عطر', 'perfume', 'fragrance', 'كولونيا'],
      'مكياج': ['ميكب', 'makeup', 'cosmetics', 'جمال'],
      'جمال': ['عناية', 'skincare', 'beauty', 'مكياج'],
      'الكترونيات': ['تقنية', 'electronics', 'tech', 'أجهزة'],
      'تقنية': ['الكترونيات', 'electronics', 'tech', 'أجهزة'],
      'قهوة': ['كافيه', 'coffee', 'لاتيه', 'كابتشينو'],
      'كافيه': ['قهوة', 'coffee', 'لاتيه', 'كابتشينو'],
      'هدايا': ['gift', 'gifts', 'مناسبات', 'بوكس'],
      'مطاعم': ['restaurant', 'food', 'برجر', 'بيتزا'],
      'pizza': ['بيتزا', 'pizzeria', 'pizza house'],
      'بيتزا': ['pizza', 'pizzeria', 'pizza house'],
      'ملابس': ['موضة', 'أزياء', 'fashion'],
    };

    for (final t in base) {
      final s = syn[t];
      if (s != null) out.addAll(s);
    }

    return out.take(12).toList();
  }

  bool _matchAnyToken(String value, List<String> tokens) {
    if (tokens.isEmpty) return true;
    final v = value.toLowerCase();
    return tokens.any((t) => v.contains(t));
  }

  IconData _iconForSuggestion(String s) {
    final t = s.toLowerCase();
    if (t.contains('عطر') || t.contains('perfume') || t.contains('fragrance')) {
      return Icons.local_florist_outlined;
    }
    if (t.contains('بيتزا') || t.contains('pizza') || t.contains('pizzeria')) {
      return Icons.local_pizza_outlined;
    }
    if (t.contains('قهوة') || t.contains('كافيه') || t.contains('coffee')) {
      return Icons.coffee_outlined;
    }
    if (t.contains('الكترون') || t.contains('تقنية') || t.contains('tech')) {
      return Icons.devices_other;
    }
    if (t.contains('هدايا') || t.contains('gift')) {
      return Icons.card_giftcard;
    }
    if (t.contains('مكياج') || t.contains('makeup') || t.contains('beauty')) {
      return Icons.brush_outlined;
    }
    if (t.contains('ملابس') || t.contains('موضة') || t.contains('fashion')) {
      return Icons.checkroom_outlined;
    }
    return Icons.search;
  }

  /// ✅ Suggestions داخل البانل:
  /// - defaults
  /// - based on query tokens
  /// - + اقتراحات من الداتا (stores/collections) + (reels آخر اشي)
  List<String> _buildPanelSuggestions({
    required List<_CollectionItem> collections,
    required List<_ReelItem> reels,
    required List<_StoreItem> stores,
  }) {
    const defaults = <String>[
      'عطر',
      'عطور',
      'مكياج',
      'جمال',
      'قهوة',
      'كافيه',
      'بيتزا',
      'pizza',
      'الكترونيات',
      'هدايا',
      'مطاعم',
      'ملابس',
    ];

    final q = _query;
    final out = <String>[];

    if (q.isEmpty) {
      out.addAll(defaults);
      return out.take(10).toList();
    }

    final expanded = _expandTokens(q);

    final merged = <String>{
      q,
      ...expanded,
      if (!q.endsWith('ات')) '${q}ات',
      if (q.length >= 2) '$q عروض',
      if (q.length >= 2) '$q قريب',
    }.where((e) => e.trim().isNotEmpty).toList();

    final tokens = expanded.isEmpty ? [q] : expanded;

    final storeHits = stores
        .where((s) => _matchAnyToken('${s.name} ${s.category}', tokens))
        .map((s) => s.name)
        .toList();

    final colHits = collections
        .where((c) => _matchAnyToken(c.title, tokens))
        .map((c) => c.title)
        .toList();

    final reelHits = reels
        .where((r) => _matchAnyToken('${r.store} ${r.title}', tokens))
        .map((r) => r.title)
        .toList();

    out
      ..addAll(merged)
      ..addAll(storeHits)
      ..addAll(colHits)
      ..addAll(reelHits);

    final dedup = <String>[];
    final seen = <String>{};
    for (final s in out) {
      final key = s.toLowerCase().trim();
      if (key.isEmpty) continue;
      if (seen.contains(key)) continue;
      seen.add(key);
      dedup.add(s.trim());
      if (dedup.length >= 10) break;
    }
    return dedup;
  }

  // ✅ “اللمسة”: نتائج سريعة (Top 3 stores + Top 3 reels) داخل البانل
  List<_StoreItem> _quickStoreResults(
    List<_StoreItem> stores,
    List<String> tokens,
  ) {
    if (tokens.isEmpty) return const [];
    final hits = stores
        .where((s) => _matchAnyToken('${s.name} ${s.category}', tokens))
        .toList();
    hits.sort((a, b) {
      final as = (5 - a.distanceKm).clamp(0, 5) + a.rating;
      final bs = (5 - b.distanceKm).clamp(0, 5) + b.rating;
      return bs.compareTo(as);
    });
    return hits.take(3).toList();
  }

  List<_ReelItem> _quickReelResults(
    List<_ReelItem> reels,
    List<String> tokens,
  ) {
    if (tokens.isEmpty) return const [];
    final hits = reels
        .where((r) => _matchAnyToken('${r.store} ${r.title}', tokens))
        .toList();
    return hits.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding = width * 0.06;
    final vSpaceXs = height * 0.012;
    final vSpaceSm = height * 0.018;
    final vSpaceMd = height * 0.026;
    final vSpaceLg = height * 0.034;

    // ✅ Dummy Data
    final collections = const [
      _CollectionItem('موضة وأزياء', Icons.checkroom_outlined),
      _CollectionItem('المطاعم والكافيهات', Icons.restaurant_menu),
      _CollectionItem('الكترونيات وتقنية', Icons.devices_other),
      _CollectionItem('الجمال والعناية', Icons.brush_outlined),
    ];

    final reels = const [
      _ReelItem('Coffee Mood', 'خصم على المشروبات الباردة', AppColors.navy),
      _ReelItem('FitZone Gym', 'اشتراك + شهر مجاناً', AppColors.purple),
      _ReelItem('Tech Corner', 'عروض باور بانك وسماعات', AppColors.teal),
      _ReelItem('Rose Home', 'ديكورات جديدة للبيت', Color(0xFFB23A48)),
      _ReelItem('Gifts Box', 'هدايا جاهزة لكل مناسبة', Color(0xFF3D155F)),
      _ReelItem('Burger Hub', 'برجر مع عرض مميز', Color(0xFFBF360C)),
      _ReelItem('Perfume Lab', 'خصم على عطور الشتاء', Color(0xFF7B1FA2)),
      _ReelItem('Pizza House', 'عرض العائلة على البيتزا', Color(0xFFD32F2F)),
    ];

    final stores = const [
      _StoreItem('Coffee Mood', 'كافيه', 1.2, 4.7),
      _StoreItem('FitZone Gym', 'نادي رياضي', 3.5, 4.5),
      _StoreItem('Tech Corner', 'الكترونيات', 5.4, 4.3),
      _StoreItem('Rose Home Decor', 'ديكور منزلي', 2.1, 4.8),
      _StoreItem('Beauty House', 'عطور وجمال', 2.9, 4.6),
      _StoreItem('Perfume Lab', 'عطور', 4.1, 4.4),
      _StoreItem('Pizza House', 'مطعم بيتزا', 1.0, 4.2),
    ];

    final history = ref.watch(exploreSearchHistoryProvider);
    final tokens = _query.isEmpty ? const <String>[] : _expandTokens(_query);

    // ✅ content filtering
    var filteredCollections = collections
        .where((c) => _matchAnyToken(c.title, tokens))
        .toList();

    var filteredReels = reels
        .where(
          (r) =>
              _matchAnyToken(r.store, tokens) ||
              _matchAnyToken(r.title, tokens),
        )
        .toList();

    var filteredStores = stores
        .where(
          (s) =>
              _matchAnyToken(s.name, tokens) ||
              _matchAnyToken(s.category, tokens),
        )
        .toList();

    switch (_selectedFilter) {
      case ExploreFilter.all:
        break;
      case ExploreFilter.near:
        filteredStores = filteredStores
          ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case ExploreFilter.topRated:
        filteredStores = filteredStores
          ..sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ExploreFilter.newest:
        filteredReels = filteredReels.reversed.toList();
        break;
      case ExploreFilter.recommended:
        if (filteredStores.length > 2) {
          filteredStores = filteredStores.take(2).toList();
        }
        break;
    }

    final hasAnyResults =
        filteredCollections.isNotEmpty ||
        filteredReels.isNotEmpty ||
        filteredStores.isNotEmpty;

    // ✅ panel data
    final panelSuggestions = _buildPanelSuggestions(
      collections: collections,
      reels: reels,
      stores: stores,
    );

    final quickStores = _quickStoreResults(stores, tokens);
    final quickReels = _quickReelResults(reels, tokens);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () async {
          // ✅ Back button: لو البانل مفتوح سكّره بدل ما يطلع من الشاشة
          if (_showSearchPanel) {
            _closeSearchPanel();
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: cs.surface,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // ✅ Tap خارج السيرتش/البانل = سكّر
              if (_showSearchPanel) _closeSearchPanel();
            },
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: height * 0.014,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استكشاف',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: vSpaceXs),
                        Text(
                          'اكتشف متاجر جديدة، تصنيفات، وريلز تشبه اهتماماتك.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: vSpaceSm),

                        // ✅ Search field
                        _ExploreSearchBarInline(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          onChanged: (_) => setState(() {}),
                          onSubmit: () => _submitExploreQuery(),
                          onClear: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          onOpenFilters: _openFiltersSheet,
                        ),

                        // ✅ PANEL (جزء من الصفحة وبدفع المحتوى لتحت)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 170),
                          curve: Curves.easeOutCubic,
                          child: !_showSearchPanel
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: EdgeInsets.only(top: height * 0.012),
                                  child: _ExploreInlineSearchPanel(
                                    query: _query,
                                    history: history,
                                    suggestions: panelSuggestions,
                                    quickStores: quickStores,
                                    quickReels: quickReels,
                                    iconForSuggestion: _iconForSuggestion,
                                    onPick: (v) =>
                                        _submitExploreQuery(overrideQuery: v),
                                    onPickStore: _openStore,
                                    onPickReel: _openReel,
                                    onClearAll: () {
                                      ref
                                          .read(
                                            exploreSearchHistoryProvider
                                                .notifier,
                                          )
                                          .clear();
                                    },
                                    onRemoveHistory: (q) {
                                      ref
                                          .read(
                                            exploreSearchHistoryProvider
                                                .notifier,
                                          )
                                          .remove(q);
                                    },
                                    onClose: _closeSearchPanel,
                                  ),
                                ),
                        ),

                        SizedBox(height: vSpaceSm),

                        _ExploreFilterChips(
                          selected: _selectedFilter,
                          onSelected: (f) =>
                              setState(() => _selectedFilter = f),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: !hasAnyResults
                            ? _EmptyExplore(
                                query: _searchController.text.trim(),
                              )
                            : SingleChildScrollView(
                                key: ValueKey(
                                  'content-$_query-${_selectedFilter.name}',
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: vSpaceSm),

                                    if (filteredCollections.isNotEmpty) ...[
                                      Text(
                                        'مجموعات مقترحة',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      SizedBox(height: vSpaceXs),
                                      SizedBox(
                                        height: height * 0.20,
                                        child: _ExploreCollectionsList(
                                          items: filteredCollections,
                                        ),
                                      ),
                                      SizedBox(height: vSpaceMd),
                                    ],

                                    if (filteredReels.isNotEmpty) ...[
                                      Text(
                                        'استكشف الريلز',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      SizedBox(height: vSpaceXs),
                                      _ExploreReelsGrid(
                                        items: filteredReels,
                                        onOpenReel: (r) => _openReel(r),
                                      ),
                                      SizedBox(height: vSpaceMd),
                                    ],

                                    if (filteredStores.isNotEmpty) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'متاجر قريبة منك',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: Text(
                                              'عرض الكل',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: cs.secondary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: vSpaceXs),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: filteredStores.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: height * 0.014),
                                        itemBuilder: (context, index) {
                                          return _NearbyStoreTile(
                                            item: filteredStores[index],
                                            onTap: () => _openStore(
                                              filteredStores[index],
                                            ),
                                          );
                                        },
                                      ),
                                    ],

                                    SizedBox(height: vSpaceLg),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ✅ Panel (Inline) — scrollable + ما يغطي الشاشة + فيه “نتائج سريعة”
class _ExploreInlineSearchPanel extends StatelessWidget {
  final String query;
  final List<String> history;
  final List<String> suggestions;

  final List<_StoreItem> quickStores;
  final List<_ReelItem> quickReels;

  final IconData Function(String) iconForSuggestion;

  final ValueChanged<String> onPick;
  final ValueChanged<_StoreItem> onPickStore;
  final ValueChanged<_ReelItem> onPickReel;

  final VoidCallback onClearAll;
  final ValueChanged<String> onRemoveHistory;

  final VoidCallback onClose;

  const _ExploreInlineSearchPanel({
    required this.query,
    required this.history,
    required this.suggestions,
    required this.quickStores,
    required this.quickReels,
    required this.iconForSuggestion,
    required this.onPick,
    required this.onPickStore,
    required this.onPickReel,
    required this.onClearAll,
    required this.onRemoveHistory,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final maxH = (h * 0.38).clamp(220.0, 360.0);

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      padding: EdgeInsets.fromLTRB(w * 0.04, h * 0.012, w * 0.04, h * 0.010),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(h * 0.022),
        border: Border.all(color: cs.outline.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.10 : 0.55,
            ),
            blurRadius: h * 0.025,
            offset: Offset(0, h * 0.012),
          ),
        ],
      ),
      child: Column(
        children: [
          // header row (خفيف)
          Expanded(
            child: Scrollbar(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ✅ “نتائج سريعة” (بس لما في query)
                  if (query.isNotEmpty &&
                      (quickStores.isNotEmpty || quickReels.isNotEmpty)) ...[
                    SizedBox(height: h * 0.010),
                    Text(
                      'نتائج سريعة',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: h * 0.008),

                    if (quickStores.isNotEmpty) ...[
                      ...quickStores.map(
                        (s) => _QuickResultTile(
                          icon: Icons.storefront_outlined,
                          title: s.name,
                          subtitle:
                              '${s.category} • ${s.distanceKm.toStringAsFixed(1)} كم • ${s.rating.toStringAsFixed(1)}⭐',
                          onTap: () => onPickStore(s),
                        ),
                      ),
                      SizedBox(height: h * 0.006),
                    ],

                    if (quickReels.isNotEmpty) ...[
                      ...quickReels.map(
                        (r) => _QuickResultTile(
                          icon: Icons.play_circle_outline,
                          title: r.title,
                          subtitle: r.store,
                          onTap: () => onPickReel(r),
                        ),
                      ),
                    ],

                    SizedBox(height: h * 0.010),
                    Divider(color: cs.outline.withOpacity(0.16), height: 1),
                  ],

                  // ✅ history
                  if (history.isNotEmpty) ...[
                    SizedBox(height: h * 0.010),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'عمليات البحث الأخيرة',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: onClearAll,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('مسح الكل'),
                        ),
                      ],
                    ),
                    ...history.map(
                      (q) => _HistoryTile(
                        query: q,
                        onTap: () => onPick(q),
                        onRemove: () => onRemoveHistory(q),
                      ),
                    ),
                    SizedBox(height: h * 0.006),
                    Divider(color: cs.outline.withOpacity(0.16), height: 1),
                  ],

                  // ✅ suggestions (list rows with icons)
                  SizedBox(height: h * 0.010),
                  Text(
                    'اقتراحات',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: h * 0.010),
                  ...suggestions.map(
                    (s) => _SuggestionRow(
                      icon: iconForSuggestion(s),
                      text: s,
                      onTap: () => onPick(s),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickResultTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final h = size.height;
    final w = size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(h * 0.018),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: h * 0.008),
        child: Row(
          children: [
            Container(
              width: h * 0.040,
              height: h * 0.040,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(
                  theme.brightness == Brightness.light ? 0.55 : 0.16,
                ),
                borderRadius: BorderRadius.circular(h * 0.012),
                border: Border.all(color: cs.outline.withOpacity(0.14)),
              ),
              child: Icon(
                icon,
                size: h * 0.022,
                color: cs.onSurface.withOpacity(0.75),
              ),
            ),
            SizedBox(width: w * 0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: h * 0.002),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.70),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: h * 0.018,
              color: cs.onSurface.withOpacity(0.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SuggestionRow({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final h = size.height;
    final w = size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(h * 0.018),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: h * 0.008),
        child: Row(
          children: [
            Icon(icon, size: h * 0.022, color: cs.onSurface.withOpacity(0.70)),
            SizedBox(width: w * 0.02),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.north_west_rounded,
              size: h * 0.018,
              color: cs.onSurface.withOpacity(0.45),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Search Bar Inline (نفس الصفحة)
class _ExploreSearchBarInline extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  final VoidCallback onOpenFilters;

  const _ExploreSearchBarInline({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmit,
    required this.onClear,
    required this.onOpenFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.022;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.03 : 0.40,
            ),
            blurRadius: height * 0.02,
            offset: Offset(0, height * 0.008),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.006,
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onSubmit,
            child: Padding(
              padding: EdgeInsets.all(height * 0.006),
              child: Icon(
                Icons.search,
                size: height * 0.026,
                color: theme.iconTheme.color?.withOpacity(0.9),
              ),
            ),
          ),
          SizedBox(width: width * 0.01),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmit(), // ✅ Enter = Search
              textInputAction: TextInputAction.search, // ✅ زر Search بالكيبورد
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'ابحث عن متجر، منتج أو ريل...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
            ),
          ),
          if (controller.text.trim().isNotEmpty) ...[
            SizedBox(width: width * 0.01),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onClear,
              child: Padding(
                padding: EdgeInsets.all(height * 0.006),
                child: Icon(
                  Icons.close,
                  size: height * 0.022,
                  color: cs.onSurface.withOpacity(0.85),
                ),
              ),
            ),
          ],
          SizedBox(width: width * 0.01),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onOpenFilters,
            child: Padding(
              padding: EdgeInsets.all(height * 0.006),
              child: Icon(
                Icons.tune,
                size: height * 0.024,
                color: theme.iconTheme.color?.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryTile({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final h = size.height;
    final w = size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(h * 0.018),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: h * 0.008),
        child: Row(
          children: [
            Icon(
              Icons.history,
              size: h * 0.022,
              color: cs.onSurface.withOpacity(0.65),
            ),
            SizedBox(width: w * 0.02),
            Expanded(
              child: Text(
                query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.close,
                size: h * 0.022,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter Chips
class _ExploreFilterChips extends StatelessWidget {
  final ExploreFilter selected;
  final ValueChanged<ExploreFilter> onSelected;

  const _ExploreFilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    const filters = <(ExploreFilter, String)>[
      (ExploreFilter.all, 'الكل'),
      (ExploreFilter.near, 'قريب منك'),
      (ExploreFilter.topRated, 'تقييم عالي'),
      (ExploreFilter.newest, 'جديد'),
      (ExploreFilter.recommended, 'موصى به لك'),
    ];

    return SizedBox(
      height: height * 0.045,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: width * 0.02),
        itemBuilder: (context, index) {
          final f = filters[index].$1;
          final label = filters[index].$2;
          final isSelected = f == selected;

          return GestureDetector(
            onTap: () => onSelected(f),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.005,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.022),
                color: isSelected
                    ? cs.secondary
                    : cs.surfaceContainerHighest.withOpacity(
                        theme.brightness == Brightness.light ? 0.55 : 0.16,
                      ),
                border: Border.all(
                  color: cs.outline.withOpacity(isSelected ? 0.0 : 0.22),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? cs.onSecondary
                        : cs.onSurface.withOpacity(0.85),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Collections List
class _ExploreCollectionsList extends StatelessWidget {
  final List<_CollectionItem> items;
  const _ExploreCollectionsList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.026;

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(width: width * 0.04),
      itemBuilder: (context, index) {
        final item = items[index];

        final gradient = index.isEven
            ? const LinearGradient(colors: [AppColors.navy, AppColors.purple])
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  AppColors.purple.withOpacity(0.9),
                ],
              );

        return Container(
          width: width * 0.60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: gradient,
          ),
          child: Padding(
            padding: EdgeInsets.all(width * 0.045),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: height * 0.04, color: Colors.white),
                SizedBox(height: height * 0.012),
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: height * 0.006),
                Text(
                  'اكتشف متاجر ومنتجات مختارة بعناية ضمن هذا القسم.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'استكشاف الآن',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Reels Grid
class _ExploreReelsGrid extends StatelessWidget {
  final List<_ReelItem> items;
  final ValueChanged<_ReelItem> onOpenReel;

  const _ExploreReelsGrid({required this.items, required this.onOpenReel});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
    final radius = height * 0.028;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: width * 0.02,
        mainAxisSpacing: height * 0.012,
        childAspectRatio: 9 / 16,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ReelPreviewCard(
          radius: radius,
          storeName: item.store,
          title: item.title,
          baseColor: item.color,
          onTap: () => onOpenReel(item),
        );
      },
    );
  }
}

class _ReelPreviewCard extends StatelessWidget {
  final double radius;
  final String storeName;
  final String title;
  final Color baseColor;
  final VoidCallback onTap;

  const _ReelPreviewCard({
    required this.radius,
    required this.storeName,
    required this.title,
    required this.baseColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  baseColor.withOpacity(0.95),
                  baseColor.withOpacity(0.6),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.30),
                  Colors.transparent,
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(width * 0.025),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: height * 0.004),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: width * 0.01),
                        Text(
                          'رييل',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.volume_mute,
                      color: Colors.white.withOpacity(0.9),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

/// Store Tile
class _NearbyStoreTile extends StatelessWidget {
  final _StoreItem item;
  final VoidCallback onTap;

  const _NearbyStoreTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final radius = height * 0.022;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.light ? 0.03 : 0.28,
              ),
              blurRadius: height * 0.02,
              offset: Offset(0, height * 0.01),
            ),
          ],
        ),
        padding: EdgeInsets.all(width * 0.035),
        child: Row(
          children: [
            Container(
              width: height * 0.07,
              height: height * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius * 0.8),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.navy, AppColors.purple],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.storefront,
                  color: Colors.white,
                  size: height * 0.032,
                ),
              ),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: height * 0.004),
                  Text(
                    item.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: height * 0.004),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: height * 0.022,
                        color: Colors.amber,
                      ),
                      SizedBox(width: width * 0.008),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Icon(
                        Icons.location_on_outlined,
                        size: height * 0.022,
                        color: cs.secondary,
                      ),
                      Text(
                        '${item.distanceKm.toStringAsFixed(1)} كم',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.8,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              size: height * 0.030,
              color: theme.iconTheme.color?.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExplore extends StatelessWidget {
  final String query;
  const _EmptyExplore({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: w * 0.16,
              color: cs.onSurface.withOpacity(0.55),
            ),
            SizedBox(height: h * 0.015),
            Text(
              'ما في نتائج',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: h * 0.008),
            Text(
              query.isEmpty
                  ? 'جرّب تدور على متجر أو منتج.'
                  : 'ما لقينا نتائج لـ "$query".',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------------
/// ✅ Simple navigation screens
/// (بدّلهم لاحقاً بشاشاتك الحقيقية)
/// ----------------------------

class StoreProfileScreen extends StatelessWidget {
  final _StoreItem store;

  const StoreProfileScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(store.name),
          backgroundColor: cs.surface,
          foregroundColor: cs.onSurface,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                store.category,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    store.rating.toStringAsFixed(1),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on_outlined, color: cs.secondary),
                  const SizedBox(width: 6),
                  Text(
                    '${store.distanceKm.toStringAsFixed(1)} كم',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'هذي شاشة تجريبية — اربطها بصفحة المتجر الحقيقية عندك.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReelViewerScreen extends StatelessWidget {
  final _ReelItem reel;

  const ReelViewerScreen({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(reel.store),
        ),
        body: Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  reel.color.withOpacity(0.95),
                  reel.color.withOpacity(0.65),
                ],
              ),
              border: Border.all(color: cs.outline.withOpacity(0.18)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  reel.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'شاشة ريل تجريبية — اربطها بالـ Reels Viewer الحقيقي.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Models
class _CollectionItem {
  final String title;
  final IconData icon;
  const _CollectionItem(this.title, this.icon);
}

class _ReelItem {
  final String store;
  final String title;
  final Color color;
  const _ReelItem(this.store, this.title, this.color);
}

class _StoreItem {
  final String name;
  final String category;
  final double distanceKm;
  final double rating;
  const _StoreItem(this.name, this.category, this.distanceKm, this.rating);
}
