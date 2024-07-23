import 'dart:async';
import 'dart:developer';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_preload_videos/models/play_video_from.dart';
import 'package:flutter_preload_videos/models/vimeo_models.dart';
import 'package:flutter_preload_videos/video_apis.dart';

class PreloadProvider extends ChangeNotifier {

  List<String> _urls = const [];

  //  List<String> _postAndLiveVideos = const [];
  
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


// ----------- Shorts Video -------------

    set urls(List<String> videoUrls){
        _urls = videoUrls;
        notifyListeners();
    }

    set updateUrls(List<String> videoUrls){
        _urls.addAll(videoUrls.toSet().toList());
        notifyListeners();
    }

     List<String> get urls => _urls;
     
    final Map<int, CachedVideoPlayerPlusController?> _controllers = {};

    Map<int, CachedVideoPlayerPlusController?> get controllers => _controllers;

   
// ----------- Post And Live Videos -------------

    // set postAndLiveUrls(List<String> videoUrls){
    //     _postAndLiveVideos = videoUrls;
    //     notifyListeners();
    // }

    // set updatePostAndLiveUrls(List<String> videoUrls){
    //     _postAndLiveVideos.addAll(videoUrls.toSet().toList());
    //     notifyListeners();
    // }

    //  List<String> get getPostAndLiveVideos => _postAndLiveVideos;

    // final Map<int, CachedVideoPlayerPlusController?> _postAndLiveVideoControllers = {};

    //  Map<int, CachedVideoPlayerPlusController?> get postLiveControllers => _postAndLiveVideoControllers;


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


  // Future disposeNormalVideo({required int index, required int id}) async {
  //     if (_postAndLiveVideos.length > index && index >= 0 && postLiveControllers[id] != null) {
  //     /// Get controller at [index]
  //     final CachedVideoPlayerPlusController _controller = postLiveControllers[id] as CachedVideoPlayerPlusController;

  //     /// Dispose controller
  //     _controller.dispose();

  //     postLiveControllers.remove(_controller);

  //     postLiveControllers[id] = null;

  //     log('🚀🚀🚀 DISPOSED Post Video $index');
  //   }
  // }


  
  // Future _initializeNormalVideos({ bool isLive=false, required int index, required int id, Duration? durationCache}) async {

  //   if (_postAndLiveVideos.length > index && index >= 0) {
  //     /// Create new controller
  //      CachedVideoPlayerPlusController _controller;

  //       if (_postAndLiveVideos[index].contains('youtube') || _postAndLiveVideos[index].contains('youtu.be')) {
          
  //         var urlss = await  getVideoQualityUrlsFromYoutube(
  //         PlayVideoFrom.youtube(_postAndLiveVideos[index]).dataSource ?? "",
  //         isLive
  //       );

  //       final youtubeurl = await getUrlFromVideoQualityUrls(
  //         qualityList: [480 ,360],
  //         videoUrls: urlss,
  //       );

  //          _controller = CachedVideoPlayerPlusController.networkUrl(Uri.parse(youtubeurl), 
  //         invalidateCacheIfOlderThan:durationCache ?? Duration(days: 15));


  //      } else {

  //        _controller = CachedVideoPlayerPlusController.networkUrl(Uri.parse(_postAndLiveVideos[index]),
  //          invalidateCacheIfOlderThan:durationCache ?? Duration(days: 15));

  //      }


  //         _controller.setLooping(_looping);

  //         _controller.setVolume(_isMute == true ? 0 : 100);

  //               /// Add to [controllers] list
  //         controllers[id] = _controller;

  //         /// Initialize
  //         await _controller.initialize();

  //         log('🚀🚀🚀 INITIALIZED $index');
  //     }
  // }


  Future _initializeControllerAtIndex(int index) async {

    if (_urls.length > index && index >= 0) {
      /// Create new controller
        if (_urls[index].contains('youtube') || _urls[index].contains('youtu.be')) {
          
          var urlss = await  getVideoQualityUrlsFromYoutube(
          PlayVideoFrom.youtube(_urls[index]).dataSource ?? "",
          false
        );

        final youtubeurl = await getUrlFromVideoQualityUrls(
          qualityList: [480 ,360],
          videoUrls: urlss,
        );

          final CachedVideoPlayerPlusController _controller =
          CachedVideoPlayerPlusController.networkUrl(Uri.parse(youtubeurl), 
          invalidateCacheIfOlderThan: Duration(days: 15));

          _controller.setLooping(_looping);

          _controller.setVolume(_isMute == true ? 0 : 100);

           _controller.pause();

                /// Add to [controllers] list
          controllers[index] = _controller;

          /// Initialize
          await _controller.initialize();

          log('🚀🚀🚀 INITIALIZED Youtube $index');

       } else {

             final CachedVideoPlayerPlusController _controller =
          CachedVideoPlayerPlusController.networkUrl(Uri.parse(_urls[index]),
           invalidateCacheIfOlderThan: Duration(days: 15));

                /// Add to [controllers] list
          controllers[index] = _controller;

           _controller.setLooping(_looping);

          _controller.setVolume(_isMute == true ? 0 : 100);

          /// Initialize
          await _controller.initialize();

          log('🚀🚀🚀 INITIALIZED $index');
       }
    }
  }

  void _playControllerAtIndex(int index) {
    if (_urls.length > index && index >= 0 && _controllers[index] != null) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController _controller = _controllers[index]!;
      
      _controller.setVolume(_isMute == true ? 0 : 100);
      /// Play controller
      _controller.play();

      log('🚀🚀🚀 PLAYING $index');
    }
  }


Future<CachedVideoPlayerPlusController> playYoutubeVideo({
  required String url, bool isLive =false, Duration? cacheDuration}) async {

     CachedVideoPlayerPlusController _controller;

     var urlss = await  getVideoQualityUrlsFromYoutube(
          PlayVideoFrom.youtube(url).dataSource ?? "",
          isLive
        );

        final youtubeurl = await getUrlFromVideoQualityUrls(
          qualityList: [480 ,360],
          videoUrls: urlss,
        );

          _controller = CachedVideoPlayerPlusController.networkUrl(Uri.parse(youtubeurl), 
          invalidateCacheIfOlderThan: cacheDuration ?? Duration(days: 15));

          _controller.setLooping(_looping);

          _controller.setVolume(_isMute == true ? 0 : 100);

          /// Initialize
          await _controller.initialize();
          
          return  _controller;

  }



Future<CachedVideoPlayerPlusController> playNormalVideo({
  required String url, 
  bool isLive =false, 
  Duration cacheDuration = const Duration(days: 15),
  VideoFormat? formatHint,
  Future<ClosedCaptionFile>? closedCaptionFile,
  VideoPlayerOptions? videoPlayerOptions,
  Map<String, String> httpHeaders = const <String, String>{},
  }) async {

      CachedVideoPlayerPlusController _controller;

      _controller = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(url), 
      formatHint:formatHint,
      closedCaptionFile : closedCaptionFile,
      videoPlayerOptions : videoPlayerOptions,
      httpHeaders : httpHeaders,
      invalidateCacheIfOlderThan: cacheDuration);

      _controller.setLooping(_looping);

      _controller.setVolume(_isMute == true ? 0 : 100);
          /// Add to [controllers] list
    // controllers[index] = _controller;

    /// Initialize
    await _controller.initialize();
    
    return  _controller;

  }

  // void _playPostLiveControllerAtIndex(int index, int id) {

  //   if (_postAndLiveVideos.length > index && index >= 0 && _controllers[index] != null) {
  //     /// Get controller at [index]
  //     final CachedVideoPlayerPlusController _controller = _postAndLiveVideoControllers[id]!;
      
  //     _controller.setVolume(_isMute == true ? 0 : 100);
  //     /// Play controller
  //     _controller.play();

  //     log('🚀🚀🚀 PLAYING $index');
  //   }
  // }

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

  //  void _postOrLivePauseControllerAtIndex(int index, int id) {
  //   if (_postAndLiveVideos.length > index && index >= 0) {
  //     /// Get live or post controller at [index]
  //     final CachedVideoPlayerPlusController _controller = _postAndLiveVideoControllers[id]!;

  //     /// Pause
  //     _controller.pause();

  //     log('🚀🚀🚀 Paused $index');
  //   }
  // }

  void _disposeControllerAtIndex(int index) {
    if (_urls.length > index && index >= 0 && controllers[index] != null) {
      /// Get controller at [index]
      final CachedVideoPlayerPlusController _controller = controllers[index] as CachedVideoPlayerPlusController;

      /// Dispose controller
      _controller.dispose();

      controllers.remove(_controller);

      controllers[index] = null;

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
    // if(index < _urls.length-1){
      _initializeControllerAtIndex(index + 1);
    // }
    //  if(index < _urls.length-3){
    //   _initializeControllerAtIndex(index + 2);
    //  }
  }

  void _playPrevious(int index) {
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2);

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



  // Future<void> initializePostorLiveVideo({required int index, required int id}) async {
  //   /// Initialize 1st video
  //   await _initializeNormalVideos(index: 0,id: id);

  // }

  // Future postOrLivePlayVideoAtIndex(int index,int id) async {
  //   _playPostLiveControllerAtIndex(index, id);
  // }

  // Future pausetOrLivePlayVideoAtIndex(int index, int id) async {
  //   _postOrLivePauseControllerAtIndex(index ,id);
  // }


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
