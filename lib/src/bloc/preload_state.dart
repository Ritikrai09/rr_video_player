part of 'preload_bloc.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class PreloadState with _$PreloadState {
   factory PreloadState({
    required String url,
    required List<String> urls,
    required Map<int, CachedVideoPlayerPlusController> controllers,
    required int focusedIndex,
    required int reloadCounter,
    required bool isLoading,
  }) = _PreloadState;

  factory PreloadState.initial() => PreloadState(
        focusedIndex: 0,
        reloadCounter: 0,
        url: '',
        isLoading: false,
        urls: [],
        controllers: {},
      );

}
