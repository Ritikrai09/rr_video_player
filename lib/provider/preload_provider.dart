import 'dart:developer';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_preload_videos/models/play_video_from.dart';
import 'package:flutter_preload_videos/models/vimeo_models.dart';
import 'package:flutter_preload_videos/video_apis.dart';

class PreloadProvider extends ChangeNotifier {

  List<String> _urls = const [];
  
  bool _looping = true;

  get getLoop => _looping;
  
  set setLooping (bool loop){
    _looping = loop;
    notifyListeners();
  } 

  bool _isMute = false;

  bool get isMute => _isMute;

  set setMute (int index ){
     _isMute = !_isMute;
     _controllers[index]!.setVolume(_isMute == true ? 0 : 100);
     notifyListeners();
  }


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
        if (_urls[index].contains('youtube') || _urls[index].contains('youtu.be')) {
          
          var urlss = await  getVideoQualityUrlsFromYoutube(
          PlayVideoFrom.youtube(_urls[index]).dataSource ?? "",
          false
        );

        final youtubeurl = await getUrlFromVideoQualityUrls(
          qualityList: [ 720, 360],
          videoUrls: urlss,
        );

          final CachedVideoPlayerPlusController _controller =
          CachedVideoPlayerPlusController.networkUrl(Uri.parse(youtubeurl));

          _controller.setLooping(_looping);

          _controller.setVolume(_isMute == true ? 0 : 100);
                /// Add to [controllers] list
          controllers[index] = _controller;

          /// Initialize
          await _controller.initialize();

        // int dur = controllers[index]!.value.duration.inMilliseconds;
        // int pos = controllers[index]!.value.position.inMilliseconds;
        // int buf = controllers[index]!.value.buffered.last.end.inMilliseconds;
     
        //  var _position,_buffer;
       
        //   if (dur <= pos) {
        //    _position = 0;
        //     return;
        //   }

        //   _position = pos / dur;
        //   _buffer = buf / dur;
       
        // if (dur - pos < 1) {
        //   if (index < _urls.length - 1) {
        //     _playControllerAtIndex(index+1);
        //   }
        // }

          log('🚀🚀🚀 INITIALIZED Youtube $index');

       } else {

             final CachedVideoPlayerPlusController _controller =
          CachedVideoPlayerPlusController.networkUrl(Uri.parse(_urls[index]));

                /// Add to [controllers] list
          controllers[index] = _controller;

           _controller.setLooping(_looping);

          _controller.setVolume(_isMute == true ? 0 : 100);

           _controller.pause();

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
      
      _controller.setVolume(_isMute == true ? 0 : 100);
      /// Play controller
      _controller.play();

      log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (_urls.length > index && index >= 0 && _controllers[index] != null) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController _controller = _controllers[index]!;

      /// Pause
      _controller.pause();

      /// Reset postiton to beginning
      // _controller.seekTo(const Duration());

      log('🚀🚀🚀 STOPPED $index');
    }
  }

   void _pauseControllerAtIndex(int index) {
    if (_urls.length > index && index >= 0) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController _controller = _controllers[index]!;

      /// Pause
      _controller.pause();

      log('🚀🚀🚀 Paused $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (_urls.length > index && index >= 0 && _controllers[index] != null) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController _controller = _controllers[index] as CachedVideoPlayerPlusController;

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
    _disposeControllerAtIndex(index - 3);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index + 1] controller
    // if(index < _urls.length-1){
      _initializeControllerAtIndex(index + 1);
    // }
    //  if(index < _urls.length-3){
       _initializeControllerAtIndex(index + 2);
    //  }
  }

  void _playPrevious(int index) {
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 3);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    // if(index > 0){
      _initializeControllerAtIndex(index - 1);
    // }
    //  if(index > 2){
    //   _initializeControllerAtIndex(index - 2);
    //  }
  }
 




  Future<void> initialize() async {
    /// Initialize 1st video
    await _initializeControllerAtIndex(0);


    /// Initialize 2nd vide
    await _initializeControllerAtIndex(1);
  }

  Future playVideoAtIndex(int? index) async {
    _playControllerAtIndex(index ?? 0);
  }

  Future pauseVideoAtIndex(int? index) async {
    _pauseControllerAtIndex(index ?? 0);
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
