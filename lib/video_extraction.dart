import 'package:flutter_preload_videos/models/vimeo_models.dart';
import 'package:flutter_preload_videos/video_apis.dart';

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
    // urls0?.removeWhere((element) => element.quality == 240);

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
    required int initQuality
  }) async {

    final videoUrl = await sortQualityVideoUrls(videoUrls);


    VideoQalityUrls? urlWithQuality;
    final fallback = videoUrl[0];
    for (final quality in qualityList) {
      urlWithQuality = videoUrl.firstWhere(
        (url) => url.quality == initQuality,
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
