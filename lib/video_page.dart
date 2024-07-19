import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/provider/preload_provider.dart';
import 'package:provider/provider.dart';

class VideoPage extends StatelessWidget {
  const VideoPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<PreloadProvider>(
        builder: (context, provider, _) {
          return PageView.builder(
            itemCount: provider.urls.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) => provider.onVideoIndexChanged(index),
            itemBuilder: (context, index) {
              return provider.focusedIndex == index
                  ? CachedVideoPlayerPlus(provider.controllers[index]!)
                  : const SizedBox();
            },
          );
        },
      ),
    );
  }
}
