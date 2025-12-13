import 'package:flutter_riverpod/legacy.dart';

class ReactionsState {
  final Set<String> likedStoreIds;
  final Set<String> savedStoreIds;
  final Set<String> favoriteStoreIds;

  const ReactionsState({
    this.likedStoreIds = const {},
    this.savedStoreIds = const {},
    this.favoriteStoreIds = const {},
  });

  ReactionsState copyWith({
    Set<String>? likedStoreIds,
    Set<String>? savedStoreIds,
    Set<String>? favoriteStoreIds,
  }) {
    return ReactionsState(
      likedStoreIds: likedStoreIds ?? this.likedStoreIds,
      savedStoreIds: savedStoreIds ?? this.savedStoreIds,
      favoriteStoreIds: favoriteStoreIds ?? this.favoriteStoreIds,
    );
  }
}

class ReactionsController extends StateNotifier<ReactionsState> {
  ReactionsController() : super(const ReactionsState());

  bool isLiked(String storeId) => state.likedStoreIds.contains(storeId);
  bool isSaved(String storeId) => state.savedStoreIds.contains(storeId);
  bool isFavorite(String storeId) => state.favoriteStoreIds.contains(storeId);

  void toggleLike(String storeId) {
    final next = {...state.likedStoreIds};
    if (next.contains(storeId)) {
      next.remove(storeId);
    } else {
      next.add(storeId);
    }
    state = state.copyWith(likedStoreIds: next);
  }

  void toggleSave(String storeId) {
    final next = {...state.savedStoreIds};
    if (next.contains(storeId)) {
      next.remove(storeId);
    } else {
      next.add(storeId);
    }
    state = state.copyWith(savedStoreIds: next);
  }

  void toggleFavorite(String storeId) {
    final next = {...state.favoriteStoreIds};
    if (next.contains(storeId)) {
      next.remove(storeId);
    } else {
      next.add(storeId);
    }
    state = state.copyWith(favoriteStoreIds: next);
  }
}

final reactionsControllerProvider =
    StateNotifierProvider<ReactionsController, ReactionsState>(
      (ref) => ReactionsController(),
    );
