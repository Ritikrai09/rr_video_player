import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter_preload_videos/models/play_video_from.dart';
import 'package:flutter_preload_videos/video_extraction.dart';

class CacheVideoController {
  
  Future<CachedVideoPlayerPlusController> playYoutubeVideo({
  required String url, bool isLive =false, Duration? cacheDuration, int initQuality = 480, Duration? setDuration,String? apiKey }) async {

     CachedVideoPlayerPlusController _controller;

     var urlss = await  getVideoQualityUrlsFromYoutube(
          PlayVideoFrom.youtube(url).dataSource ?? "",
          isLive,
          apiKey: apiKey
        );

        String? youtubeurl = await getUrlFromVideoQualityUrls(
          qualityList: [1080, 720, 480, 360, 240 ],
          videoUrls: urlss ?? [],
          initQuality: initQuality
        );

        if(youtubeurl != null ){

          _controller = CachedVideoPlayerPlusController.networkUrl(Uri.parse(youtubeurl), 
          invalidateCacheIfOlderThan: cacheDuration ?? Duration(days: 7));
          
          _controller.setLooping(true);

          if(setDuration != null){
            _controller.seekTo(setDuration);
          }
          // _controller.setVolume(_isMute == true ? 0 : 100);

          /// Initialize
          await _controller.initialize();

          _controller.play();
          
          return  _controller;
        }

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

     _controller.setLooping(true);
          /// Add to [controllers] list
    // controllers[index] = _controller;

    /// Initialize
    await _controller.initialize();
    
    return  _controller;

  }
}