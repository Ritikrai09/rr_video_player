import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter_preload_videos/models/vimeo_models.dart';


enum RRVideoPlayerType {
  network,
  networkQualityUrls,
  file,
  asset,
  vimeo,
  youtube,
  vimeoPrivateVideos,
}


class PlayVideoFrom {
  final String? dataSource;
  final String? hash;
  final RRVideoPlayerType playerType;
  final VideoFormat? formatHint;
  final String? package;
  final File? file;
  final List<VideoQalityUrls>? videoQualityUrls;
  final Future<ClosedCaptionFile>? closedCaptionFile;
  final VideoPlayerOptions? videoPlayerOptions;
  final Map<String, String> httpHeaders;
  final bool live;

  const PlayVideoFrom._({
    required this.playerType,
    this.live = false,
    this.dataSource,
    this.hash,
    this.formatHint,
    this.package,
    this.file,
    this.videoQualityUrls,
    this.closedCaptionFile,
    this.videoPlayerOptions,
    this.httpHeaders = const {},
  });

  factory PlayVideoFrom.network(
    String dataSource, {
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const {},
  }) {
    return PlayVideoFrom._(
      playerType: RRVideoPlayerType.network,
      dataSource: dataSource,
      formatHint: formatHint,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
      httpHeaders: httpHeaders,
    );
  }

  factory PlayVideoFrom.asset(
    String dataSource, {
    String? package,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  }) {
    return PlayVideoFrom._(
      playerType: RRVideoPlayerType.asset,
      dataSource: dataSource,
      package: package,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
    );
  }

  ///File Doesnot support web apps
  ///[file] is `File` Datatype import it from `dart:io`
  factory PlayVideoFrom.file(
    File file, {
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  }) {
    return PlayVideoFrom._(
      file: file,
      playerType: RRVideoPlayerType.file,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
    );
  }

  factory PlayVideoFrom.vimeo(
    String dataSource, {
    String? hash,
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const {},
  }) {
    return PlayVideoFrom._(
      playerType: RRVideoPlayerType.vimeo,
      dataSource: dataSource,
      hash: hash,
      formatHint: formatHint,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
      httpHeaders: httpHeaders,
    );
  }

  factory PlayVideoFrom.vimeoPrivateVideos(
    String dataSource, {
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const {},
  }) {
    return PlayVideoFrom._(
      playerType: RRVideoPlayerType.vimeoPrivateVideos,
      dataSource: dataSource,
      formatHint: formatHint,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
      httpHeaders: httpHeaders,
    );
  }
  factory PlayVideoFrom.youtube(
    String dataSource, {
    bool live = false,
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const {},
  }) {
    return PlayVideoFrom._(
      live: live,
      playerType: RRVideoPlayerType.youtube,
      dataSource: dataSource,
      formatHint: formatHint,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
      httpHeaders: httpHeaders,
    );
  }
  factory PlayVideoFrom.networkQualityUrls({
    required List<VideoQalityUrls> videoUrls,
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const {},
  }) {
    return PlayVideoFrom._(
      playerType: RRVideoPlayerType.networkQualityUrls,
      videoQualityUrls: videoUrls,
      formatHint: formatHint,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
      httpHeaders: httpHeaders,
    );
  }
}
