import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rr_video_player/rr_video_player.dart';
import 'package:rr_video_player/src/bloc/preload_bloc.dart';

class VideoPage extends StatelessWidget {
  const VideoPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<PreloadBloc, PreloadState>(
        builder: (context, state) {
          return PageView.builder(
            itemCount: state.urls.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) =>
                BlocProvider.of<PreloadBloc>(context, listen: false)
                    .add(PreloadEvent.onVideoIndexChanged(index)),
            itemBuilder: (context, index) {
              // Is at end and isLoading
              final bool _isLoading =
                  (state.isLoading && index == state.urls.length - 1);

              return state.focusedIndex == index
                  ? VideoWidget(
                      isLoading: _isLoading,
                      controller: state.controllers[index]!,
                    )
                  : const SizedBox();
            },
          );
        },
      ),
    );
  }
}

/// Custom Feed Widget consisting video
class VideoWidget extends StatelessWidget {
  const VideoWidget({
    Key? key,
    required this.isLoading,
    required this.controller,
  });

  final bool isLoading;
  final CachedVideoPlayerPlusController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: CachedVideoPlayerPlus(controller)),
        AnimatedCrossFade(
          alignment: Alignment.bottomCenter,
          sizeCurve: Curves.decelerate,
          duration: const Duration(milliseconds: 400),
          firstChild: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CupertinoActivityIndicator(
              color: Colors.white,
              radius: 8,
            ),
          ),
          secondChild: const SizedBox(),
          crossFadeState: isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ],
    );
  }
}
