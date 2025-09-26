import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

/// A robust tool for capturing and stitching a long scrollable widget into a single image.
class ScrollableStitcher {
  final GlobalKey repaintBoundaryKey;
  final ScrollController scrollController;

  /// [repaintBoundaryKey] is the key attached to the RepaintBoundary wrapping your scrollable widget.
  /// [scrollController] is the controller attached to your scrollable widget.
  ScrollableStitcher({
    required this.repaintBoundaryKey,
    required this.scrollController,
  });

  /// Captures the scrollable content and saves it as a single image file.
  ///
  /// [filename]: The name of the output file (e.g., "screenshot.png").
  /// [fromTop]: If true, scrolls to the top before starting the capture. Recommended for consistency.
  /// [overlap]: The overlap in logical pixels (dp) for each stitch to avoid seams.
  /// [waitForPaint]: Milliseconds to wait after each scroll for the UI to settle before capturing.
  /// [cropLeft]/[cropRight]: Logical pixels (dp) to crop from the sides of the final image.
  /// [background]: The background color for the final composite image.
  Future<File?> captureAndSave({
    required String filename,
    bool fromTop = true,
    double overlap = 60.0,
    int waitForPaint = 250,
    double cropLeft = 0.0,
    double cropRight = 0.0,
    Color background = Colors.white,
  }) async {
    if (!scrollController.hasClients) {
      throw Exception('ScrollController has no clients');
    }
    final position = scrollController.position;
    final double viewport = position.viewportDimension;
    final double maxScroll = position.maxScrollExtent;
    final double devicePixelRatio = ui.window.devicePixelRatio;

    // Save the original scroll offset to restore it later.
    final double originalOffset = position.pixels;

    // Determine the starting offset.
    final double startOffset = fromTop ? 0.0 : originalOffset;

    // Clamp the overlap to a reasonable value.
    final double effOverlap = overlap.clamp(1.0, viewport / 2);

    // Calculate the scroll step for each capture.
    final double step = viewport - effOverlap;

    // Generate the list of scroll offsets to capture.
    final List<double> offsets = [];
    double currentOffset = startOffset.clamp(0.0, maxScroll);
    while (true) {
      offsets.add(currentOffset);
      if (currentOffset >= maxScroll) {
        break;
      }
      currentOffset = (currentOffset + step).clamp(0.0, maxScroll);
      // Avoid adding a new offset if it's too close to the last one.
      if (offsets.isNotEmpty && (currentOffset - offsets.last).abs() < 1.0) {
        if (offsets.last < maxScroll) {
          offsets.add(maxScroll); // Ensure the very end is captured
        }
        break;
      }
    }
    // Ensure the final offset is unique.
    if (offsets.length > 1 && offsets.last == offsets[offsets.length - 2]) {
      offsets.removeLast();
    }

    final List<ui.Image> images = [];

    try {
      // Scroll and capture at each offset.
      for (final target in offsets) {
        scrollController.jumpTo(target);

        // Wait for the UI to render.
        await Future.delayed(Duration(milliseconds: waitForPaint));

        final boundary =
            repaintBoundaryKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary == null) {
          throw Exception(
            'RepaintBoundary not found. Ensure your scrollable widget is wrapped in a RepaintBoundary with the provided key.',
          );
        }
        final img = await boundary.toImage(pixelRatio: devicePixelRatio);
        images.add(img);
      }

      if (images.isEmpty) {
        throw Exception('No images were captured.');
      }

      // Merge the captured images into a single one.
      final ui.Image merged = await _mergeImages(
        images: images,
        offsets: offsets,
        devicePixelRatio: devicePixelRatio,
        fullContentHeight: maxScroll + viewport,
        cropLeftPx: (cropLeft * devicePixelRatio).round(),
        cropRightPx: (cropRight * devicePixelRatio).round(),
        background: background,
      );

      // Encode the final image to PNG format.
      final ByteData? pngBytes = await merged.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (pngBytes == null) throw Exception('Failed to export PNG.');

      // Save the image to a file.
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(pngBytes.buffer.asUint8List());
      return file;
    } finally {
      // Restore the original scroll position.
      scrollController.jumpTo(originalOffset.clamp(0.0, maxScroll));
    }
  }

  /// **Corrected Merging Logic**
  /// Merges a list of images using their exact scroll offsets.
  Future<ui.Image> _mergeImages({
    required List<ui.Image> images,
    required List<double> offsets,
    required double devicePixelRatio,
    required double fullContentHeight,
    int cropLeftPx = 0,
    int cropRightPx = 0,
    Color background = Colors.white,
  }) async {
    if (images.isEmpty) throw Exception('Image list cannot be empty.');

    final ui.Image firstImage = images.first;
    final int usableWidth = firstImage.width - cropLeftPx - cropRightPx;
    if (usableWidth <= 0) {
      throw Exception('Invalid crop values result in zero or negative width.');
    }

    final int finalHeightPx = (fullContentHeight * devicePixelRatio).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw the background color.
    final paint = Paint()..color = background;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, usableWidth.toDouble(), finalHeightPx.toDouble()),
      paint,
    );

    // Draw each captured image at its corresponding scroll offset.
    for (int i = 0; i < images.length; i++) {
      final img = images[i];
      final offset = offsets[i];
      final dy = offset * devicePixelRatio;

      // The source rectangle to crop from the captured image.
      final src = Rect.fromLTWH(
        cropLeftPx.toDouble(),
        0,
        (img.width - cropLeftPx - cropRightPx).toDouble(),
        img.height.toDouble(),
      );

      // The destination rectangle on the final canvas.
      final dst = Rect.fromLTWH(
        0,
        dy,
        usableWidth.toDouble(),
        img.height.toDouble(),
      );

      canvas.drawImageRect(img, src, dst, Paint());
    }

    final picture = recorder.endRecording();
    return await picture.toImage(usableWidth, finalHeightPx);
  }
}
