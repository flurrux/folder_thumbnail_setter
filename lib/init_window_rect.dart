
import 'package:flutter/widgets.dart';
import 'package:window_size/window_size.dart';

// make the window relatively small and place it close to
// the screens right edge, so it won't take up much space
// in the middle.
// this makes it easier to position the folder on the left
// side and drag in images.
Future<void> initWindowRect() async {
  final screen = await getCurrentScreen();
  if (screen == null) return;

  final Rect screenFrame = screen.visibleFrame;
  const double targetWidth = 550;
  const double targetHeight = 600;

  setWindowFrame(
    Rect.fromLTWH(
      screenFrame.right - targetWidth - 50,
      (screenFrame.height - targetHeight) / 2,
      targetWidth,
      targetHeight
    )
  );
}
