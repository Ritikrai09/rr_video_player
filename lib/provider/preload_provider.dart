import 'dart:developer';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_preload_videos/models/vimeo_models.dart';
import 'package:flutter_preload_videos/video_apis.dart';

class PreloadProvider extends ChangeNotifier {

  List<String> _urls = const [];

  List<String> get urls => _urls;

    set urls(List<String> videoUrls){
        _urls = videoUrls;
        notifyListeners();
    }

  final Map<int, CachedVideoPlayerPlusController> _controllers = {};
  Map<int, CachedVideoPlayerPlusController> get controllers => _controllers;

  int _focusedIndex = 0;
  int get focusedIndex => _focusedIndex;

  
  Future<List<VideoQalityUrls>> getVideoQualityUrlsFromYoutube(
    String youtubeIdOrUrl,
    bool live,
  ) async {
    return await VideoApis.getYoutubeVideoQualityUrls(youtubeIdOrUrl, live) ??
        [];
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

  Future _initializeControllerAtIndex(int index) async {
    
    if (_urls.length > index && index >= 0) {
      /// Create new controller
        if (urls[index].contains(RegExp('^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube(?:-nocookie)?\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|live\/|v\/)?)([\w\-]+)(\S+)?\$'))) {
           var urlss  = await  getVideoQualityUrlsFromYoutube(
          urls[index],
          false
        );

        final url = await getUrlFromVideoQualityUrls(
          qualityList: [1080, 720, 360],
          videoUrls: urlss,
        );

          final CachedVideoPlayerPlusController _controller =
          CachedVideoPlayerPlusController.networkUrl(Uri.parse(url));

                /// Add to [controllers] list
          controllers[index] = _controller;

          /// Initialize
          await _controller.initialize();

          log('🚀🚀🚀 INITIALIZED Youtube $index');

       } else {

             final CachedVideoPlayerPlusController _controller =
          CachedVideoPlayerPlusController.networkUrl(Uri.parse(urls[index]));

                /// Add to [controllers] list
          controllers[index] = _controller;

          /// Initialize
          await _controller.initialize();

          log('🚀🚀🚀 INITIALIZED $index');
       }
    }
  }

  void _playControllerAtIndex(int index) {
    if (_urls.length > index && index >= 0) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController _controller = _controllers[index]!;

      /// Play controller
      _controller.play();

      log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (_urls.length > index && index >= 0) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController _controller = _controllers[index]!;

      /// Pause
      _controller.pause();

      /// Reset postiton to beginning
      _controller.seekTo(const Duration());

      log('🚀🚀🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (_urls.length > index && index >= 0) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController _controller = _controllers[index]!;

      /// Dispose controller
      _controller.dispose();

      _controllers.remove(_controller);

      log('🚀🚀🚀 DISPOSED $index');
    }
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
 




  Future<void> initialize() async {
    /// Initialize 1st video
    await _initializeControllerAtIndex(0);

    /// Play 1st video
    _playControllerAtIndex(0);

    /// Initialize 2nd vide
    await _initializeControllerAtIndex(1);
  }

  void onVideoIndexChanged(int index) {
    if (index > _focusedIndex) {
      _playNext(index);
    } else {
      _playPrevious(index);
    }
    _focusedIndex = index;
    notifyListeners();
  }
}
