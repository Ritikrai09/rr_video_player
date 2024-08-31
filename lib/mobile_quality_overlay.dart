import 'package:flutter/material.dart';

// ignore: unused_element
class VideoQualitySelectorMob extends StatelessWidget {
  final void Function()? onTap;
  final List<int> quality;

  const VideoQualitySelectorMob({
    required this.onTap,
    required this.quality,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: quality
            .map(
              (e) => ListTile(
                title: Text('${e}p'),
                onTap: () {
                  onTap != null ? onTap!() : Navigator.of(context).pop();

                  // podCtr.changeVideoQuality(e.quality);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}