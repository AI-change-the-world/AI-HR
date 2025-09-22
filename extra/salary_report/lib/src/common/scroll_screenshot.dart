import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

/// 更稳健的滚动拼接长图工具
class ScrollableStitcher {
  final GlobalKey repaintBoundaryKey;
  final ScrollController scrollController;

  /// overlap 单位是 logical pixels (dp)，用于消除拼接缝隙。默认 60 dp。
  /// waitForPaint 是每次滚动后等待的毫秒数，保证界面渲染稳定。默认 250 ms。
  ScrollableStitcher({
    required this.repaintBoundaryKey,
    required this.scrollController,
  });

  /// 主方法：captureAndSave
  /// filename: 保存文件名（png）
  /// fromTop: 是否先滚动到顶部再开始（true 推荐，若不想跳动可传 false）
  /// overlap: 每段重叠高度（dp）
  /// waitForPaint: 每次滚动后等待毫秒数
  Future<File?> captureAndSave({
    required String filename,
    bool fromTop = true,
    double overlap = 60.0,
    int waitForPaint = 250,
  }) async {
    if (!scrollController.hasClients) {
      throw Exception('ScrollController has no clients');
    }
    final position = scrollController.position;
    final double viewport = position.viewportDimension;
    final double maxScroll = position.maxScrollExtent;
    final double devicePixelRatio = ui.window.devicePixelRatio;

    // 保存原始 offset（后面恢复）
    final double originalOffset = position.pixels;

    // 决定起始 offset（0 或 当前）
    final double startOffset = fromTop ? 0.0 : originalOffset;

    // 校正 overlap，不要超过 viewport
    final double effOverlap = overlap.clamp(1.0, viewport / 2);

    // 计算每次滚动的步长（逻辑像素）
    final double step = (viewport - effOverlap);

    // 生成要访问的 offset 列表
    final List<double> offsets = [];
    double o = startOffset.clamp(0.0, maxScroll);
    offsets.add(o);

    while (true) {
      double next = (o + step).clamp(0.0, maxScroll);
      if ((next - o).abs() < 0.5) {
        // 步长太小或到达尽头
        if (o < maxScroll) {
          offsets.add(maxScroll);
        }
        break;
      }
      // 若 next 已经接近上一次加入的 offset，则直接加入 maxScroll 并停止
      if (next >= maxScroll - 0.5) {
        offsets.add(maxScroll);
        break;
      }
      offsets.add(next);
      o = next;
    }

    // 确保最后包含 maxScroll（避免最后一段不足一屏造成丢失）
    if (offsets.isEmpty || (offsets.last < maxScroll - 0.5)) {
      offsets.add(maxScroll);
    }

    final List<ui.Image> images = [];

    try {
      // 依次滚动并截图
      for (int i = 0; i < offsets.length; i++) {
        final target = offsets[i];
        await scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );

        // 等待渲染稳定（可调整）
        await Future.delayed(Duration(milliseconds: waitForPaint));

        // 捕获当前 RepaintBoundary（屏幕可见区域）
        final boundary =
            repaintBoundaryKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary == null) {
          throw Exception(
            'RepaintBoundary not found. 请确保你把可滚动区域包在 RepaintBoundary 且 key 可访问。',
          );
        }
        final ui.Image img = await boundary.toImage(
          pixelRatio: devicePixelRatio,
        );
        images.add(img);
      }

      if (images.isEmpty) {
        throw Exception('没有截到任何图片');
      }

      // 合并图片（注意：overlap 转为像素）
      final int overlapPx = (effOverlap * devicePixelRatio).round();
      final ui.Image merged = await _mergeImages(
        images,
        overlapPx,
        cropLeft: (10 * devicePixelRatio).round(), // 裁掉左边 20dp
        cropRight: (10 * devicePixelRatio).round(),
        background: const ui.Color.fromARGB(223, 156, 219, 248),
      );

      // 保存为文件
      final ByteData? pngBytes = await merged.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (pngBytes == null) throw Exception('导出 png 失败');

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(pngBytes.buffer.asUint8List());
      return file;
    } finally {
      // 无论成功失败都尝试恢复原始滚动位置
      try {
        await scrollController.animateTo(
          originalOffset.clamp(0.0, maxScroll),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } catch (_) {}
    }
  }

  /// 合并截图，使用 overlapPx（像素）裁掉每张图片顶部的重叠部分（从第 2 张开始）
  /// 合并截图并支持左右裁剪和背景色
  Future<ui.Image> _mergeImages(
    List<ui.Image> images,
    int overlapPx, {
    int cropLeft = 0, // 左裁剪像素
    int cropRight = 0, // 右裁剪像素
    Color background = const Color(0xFFFFFFFF), // 背景色，默认白色
  }) async {
    if (images.isEmpty) throw Exception('images empty');

    final int rawWidth = images[0].width;
    final int usableWidth = rawWidth - cropLeft - cropRight;
    if (usableWidth <= 0) throw Exception('裁剪宽度不合法');

    // 计算最终高度
    int totalHeight = images[0].height;
    for (int i = 1; i < images.length; i++) {
      final int h = images[i].height;
      final int add = (h - overlapPx).clamp(0, h);
      totalHeight += add;
    }

    final recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // 绘制背景色（避免透明）
    final paint = Paint()..color = background;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, usableWidth.toDouble(), totalHeight.toDouble()),
      paint,
    );

    double dy = 0.0;

    // 第一张完整绘制（裁掉左右）
    {
      final img = images[0];
      final src = Rect.fromLTWH(
        cropLeft.toDouble(),
        0,
        (img.width - cropLeft - cropRight).toDouble(),
        img.height.toDouble(),
      );
      final dst = Rect.fromLTWH(
        0,
        0,
        usableWidth.toDouble(),
        img.height.toDouble(),
      );
      canvas.drawImageRect(img, src, dst, Paint());
      dy += img.height.toDouble();
    }

    // 后续图片（裁掉顶部 overlapPx + 左右）
    for (int i = 1; i < images.length; i++) {
      final img = images[i];
      final cropTop = overlapPx.clamp(0, img.height - 1);

      final src = Rect.fromLTWH(
        cropLeft.toDouble(),
        cropTop.toDouble(),
        (img.width - cropLeft - cropRight).toDouble(),
        (img.height - cropTop).toDouble(),
      );
      final dst = Rect.fromLTWH(
        0,
        dy,
        usableWidth.toDouble(),
        (img.height - cropTop).toDouble(),
      );
      canvas.drawImageRect(img, src, dst, Paint());

      dy += (img.height - cropTop).toDouble();
    }

    final picture = recorder.endRecording();
    return await picture.toImage(usableWidth, totalHeight);
  }
}
