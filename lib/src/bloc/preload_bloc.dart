import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rr_video_player/rr_video_player.dart';
import 'package:rr_video_player/src/core/constants.dart';
import 'package:rr_video_player/src/utils/video_apis.dart';

part 'preload_bloc.freezed.dart';
part 'preload_event.dart';
part 'preload_state.dart';

@injectable
@prod
class PreloadBloc extends Bloc<PreloadEvent, PreloadState> {

  // String baseUrl='';
  
  List<String> get getvideos => videos;

   set setVideos (List<String> video) {
    videos = video; 
  }  
  
   List<String> videos = [];

  PreloadBloc() : super(PreloadState.initial()) {
    
    on(_mapEventToState);
    
  }

  void _mapEventToState(PreloadEvent event, Emitter<PreloadState> emit) async {
    
    await event.map(
      setLoading: (e) {
        emit(state.copyWith(isLoading: true));
      },
      getVideosFromApi: (e) async {
        /// Fetch first 5 videos from api
         List<String> _urls = await getVideos();
        state.urls.addAll(_urls);

        /// Initialize 1st video
        await _initializeControllerAtIndex(0);

        /// Play 1st video
        _playControllerAtIndex(0);

        /// Initialize 2nd video
        await _initializeControllerAtIndex(1);

        emit(state.copyWith(reloadCounter: state.reloadCounter + 1));
      },
      // initialize: (e) async* {},
      onVideoIndexChanged: (e) {
        /// Condition to fetch new videos
        final bool shouldFetch = (e.index + kPreloadLimit) % kNextLimit == 0 &&
            state.urls.length == e.index + kPreloadLimit;

        if (shouldFetch) {
          createIsolate(e.index);
        }

        /// Next / Prev video decider
        if (e.index > state.focusedIndex) {
          _playNext(e.index);
        } else {
          _playPrevious(e.index);
        }

        emit(state.copyWith(focusedIndex: e.index));
      },
      updateUrls: (e) {
        /// Add new urls to current urls
        state.urls.addAll(e.urls);

        /// Initialize new url
        _initializeControllerAtIndex(state.focusedIndex + 1);

        emit(state.copyWith(
            reloadCounter: state.reloadCounter + 1, isLoading: false));
        log('🚀🚀🚀 NEW VIDEOS ADDED');
      },
    );
  }

 Future<List<String>> getVideos({int id = 0}) async {
    // No more videos
    if ((id >= videos.length)) {
      return [];
    }
    await Future.delayed(const Duration(seconds: kLatency));

    if ((id + kNextLimit >= videos.length)) {
      return videos.sublist(id, videos.length);
    }

    return videos.sublist(id, id + kNextLimit);
  }

  

  void _playNext(int index) {
    /// Stop [index - 1] controller
    _stopControllerAtIndex(index - 1);

    /// Dispose [index - 2] controller
    _disposeControllerAtIndex(index - 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index + 1] controller
    _initializeControllerAtIndex(index + 1);
  }

  void _playPrevious(int index) {
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    _initializeControllerAtIndex(index - 1);
  }

  Future<List<VideoQalityUrls>> getVideoQualityUrlsFromYoutube(
    String youtubeIdOrUrl,
    bool live,
  ) async {
    return await VideoApis.getYoutubeVideoQualityUrls(youtubeIdOrUrl, live) ??
        [];
  }


  Future _initializeControllerAtIndex(int index) async {
    if (state.urls.length > index && index >= 0) {
      /// Create new controller
       
      if (state.urls[index].contains(RegExp('^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube(?:-nocookie)?\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|live\/|v\/)?)([\w\-]+)(\S+)?\$'))) {
           var urls  = await  getVideoQualityUrlsFromYoutube(
          state.urls[index],
          false
        );

        final url = await getUrlFromVideoQualityUrls(
          qualityList: [1080, 720, 360],
          videoUrls: urls,
        );

          final CachedVideoPlayerPlusController _controller =
          CachedVideoPlayerPlusController.networkUrl(Uri.parse(url));

                /// Add to [controllers] list
          state.controllers[index] = _controller;

          /// Initialize
          await _controller.initialize();

          log('🚀🚀🚀 INITIALIZED Youtube $index');

       } else {

             final CachedVideoPlayerPlusController _controller =
          CachedVideoPlayerPlusController.networkUrl(Uri.parse(state.urls[index]));

                /// Add to [controllers] list
          state.controllers[index] = _controller;

          /// Initialize
          await _controller.initialize();

          log('🚀🚀🚀 INITIALIZED $index');
       }
    
    }
  }

 
  List<VideoQalityUrls> sortQualityVideoUrls(
    List<VideoQalityUrls>? urls,
  ) {
    final urls0 = urls;

    ///has issues with 240p
    urls0?.removeWhere((element) => element.quality == 240);

    ///has issues with 144p in web
    // if (kIsWeb) {
    //   urls0?.removeWhere((element) => element.quality == 144);
    // }

    ///sort
    urls0?.sort((a, b) => a.quality.compareTo(b.quality));

    ///
    return urls0 ?? [];
  }

  Future<String> getUrlFromVideoQualityUrls({
    required List<int> qualityList,
    required List<VideoQalityUrls> videoUrls,
  }) async {
    final videoUrl = await sortQualityVideoUrls(videoUrls);

    VideoQalityUrls? urlWithQuality;
    final fallback = videoUrl[0];
    for (final quality in qualityList) {
      urlWithQuality = videoUrl.firstWhere(
        (url) => url.quality == quality,
        orElse: () => fallback,
      );

      if (urlWithQuality != fallback) {
        break;
      }
    }

    urlWithQuality ??= fallback;
     var _videoQualityUrl = urlWithQuality.url;
    return _videoQualityUrl;
  }


  void _playControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController _controller = state.controllers[index]!;

      /// Play controller
      _controller.play();

      log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController _controller = state.controllers[index]!;

      /// Pause
      _controller.pause();

      /// Reset postiton to beginning
      _controller.seekTo(const Duration());

      log('🚀🚀🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController? _controller = state.controllers[index];

      /// Dispose controller
      _controller?.dispose();

      if (_controller != null) {
        state.controllers.remove(_controller);
      }

      log('🚀🚀🚀 DISPOSED $index');
    }
  }
}
