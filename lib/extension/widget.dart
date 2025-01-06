import 'dart:ui';

import 'package:flutter/material.dart';

extension WidgetExt on Widget {
  Widget align({double? widthFactor, double? heightFactor, AlignmentGeometry alignment = Alignment.center}) {
    return Align(
      child: this,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      alignment: alignment,
    );
  }

  /// 宽高比
  Widget aspectRatio(double aspectRatio) {
    return AspectRatio(child: this, aspectRatio: aspectRatio);
  }

  Widget baseline(double baseline, TextBaseline baselineType) {
    return Baseline(
      baseline: baseline,
      baselineType: baselineType,
      child: this,
    );
  }

  Widget center() {
    return Center(child: this);
  }

  Widget constrained(
      {double minWidth = 0.0,
      double minHeight = 0.0,
      double maxWidth = double.infinity,
      double maxHeight = double.infinity}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth, minHeight: minHeight, minWidth: minWidth),
      child: this,
    );
  }

  Widget expanded([int flex = 1]) {
    return Expanded(child: this, flex: flex);
  }

  Widget fitted({
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    Clip clipBehavior = Clip.none,
  }) {
    return FittedBox(child: this, fit: fit, clipBehavior: clipBehavior, alignment: alignment);
  }

  Widget fraction({AlignmentGeometry alignment = Alignment.center, double? widthFactor, double? heightFactor}) {
    return FractionallySizedBox(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }

  Widget intrinsicH() {
    return IntrinsicHeight(child: this);
  }

  Widget intrinsicW() {
    return IntrinsicWidth(child: this);
  }

  Widget limited({double maxWidth = double.infinity, double maxHeight = double.infinity}) {
    return LimitedBox(child: this, maxWidth: maxWidth, maxHeight: maxHeight);
  }

  Widget offstage([bool offstage = true]) {
    return Offstage(child: this, offstage: offstage);
  }

  Widget margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Padding(
      child: this,
      padding: EdgeInsets.only(
        left: left ?? horizontal ?? all ?? 0,
        right: right ?? horizontal ?? all ?? 0,
        top: top ?? vertical ?? all ?? 0,
        bottom: bottom ?? vertical ?? all ?? 0,
      ),
    );
  }

  Widget size({double? width, double? height}) {
    return SizedBox(child: this, width: width, height: height);
  }

  Widget visible({
    Widget replacement = const SizedBox.shrink(),
    bool visible = true,
    bool maintainState = false,
    bool maintainAnimation = false,
    bool maintainSize = false,
    bool maintainSemantics = false,
    bool maintainInteractivity = false,
  }) {
    return Visibility(
      child: this,
      replacement: replacement,
      visible: visible,
      maintainState: maintainState,
      maintainAnimation: maintainAnimation,
      maintainSize: maintainSize,
      maintainSemantics: maintainSemantics,
      maintainInteractivity: maintainInteractivity,
    );
  }

  Widget rotate(
    double angle, {
    Offset? origin,
    AlignmentGeometry alignment = Alignment.center,
    bool transformHitTests = true,
    FilterQuality? filterQuality,
  }) {
    return Transform.rotate(
      origin: origin,
      alignment: alignment,
      transformHitTests: transformHitTests,
      angle: angle,
      filterQuality: filterQuality,
      child: this,
    );
  }

  Widget scale({
    double? scale,
    double? scaleX,
    double? scaleY,
    Offset? origin,
    AlignmentGeometry alignment = Alignment.center,
    bool transformHitTests = true,
    FilterQuality? filterQuality,
  }) {
    return Transform.scale(
      scale: scale,
      scaleX: scaleX,
      scaleY: scaleY,
      origin: origin,
      alignment: alignment,
      transformHitTests: transformHitTests,
      filterQuality: filterQuality,
      child: this,
    );
  }

  Widget flip({
    bool flipX = false,
    bool flipY = false,
    Offset? origin,
    bool transformHitTests = true,
    FilterQuality? filterQuality,
  }) {
    return Transform.flip(
      flipX: flipX,
      flipY: flipY,
      origin: origin,
      transformHitTests: transformHitTests,
      filterQuality: filterQuality,
      child: this,
    );
  }

  Widget translate({
    double dx = 0,
    double dy = 0,
    Offset? origin,
    bool transformHitTests = true,
    FilterQuality? filterQuality,
  }) {
    return Transform.translate(
      transformHitTests: transformHitTests,
      filterQuality: filterQuality,
      offset: Offset(dx, dy),
      child: this,
    );
  }

  Widget scrollBar({
    ScrollController? controller,
    bool? thumbVisibility,
    bool? trackVisibility,
    double? thickness,
    Radius? radius,
    ScrollNotificationPredicate? notificationPredicate,
    ScrollbarOrientation? scrollbarOrientation,
  }) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      trackVisibility: trackVisibility,
      thickness: thickness,
      radius: radius,
      notificationPredicate: notificationPredicate,
      scrollbarOrientation: scrollbarOrientation,
      child: this,
    );
  }

  Widget clip({Clip clipBehavior = Clip.antiAlias, CustomClipper<Path>? clipper}) {
    return ClipPath(
      clipBehavior: clipBehavior,
      clipper: clipper,
      child: this,
    );
  }

  Widget clipRect({Clip clipBehavior = Clip.antiAlias, BorderRadius borderRadius = BorderRadius.zero}) {
    return ClipRRect(
      clipBehavior: clipBehavior,
      borderRadius: borderRadius,
      child: this,
    );
  }

  Widget clipOval({Clip clipBehavior = Clip.antiAlias}) {
    return ClipOval(
      clipBehavior: clipBehavior,
      child: this,
    );
  }

  /// 毛玻璃效果
  Widget blur({double sigmaX = 5.0, double sigmaY = 5.0, BlendMode blendMode = BlendMode.srcIn}) {
    return BackdropFilter(
      blendMode: blendMode,
      filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: this,
    );
  }

  Widget dilate({double radiusX = 0, double radiusY = 0, BlendMode blendMode = BlendMode.srcIn}) {
    return BackdropFilter(
      blendMode: blendMode,
      filter: ImageFilter.dilate(radiusX: radiusX, radiusY: radiusY),
      child: this,
    );
  }

  Widget erode({double radiusX = 0, double radiusY = 0, BlendMode blendMode = BlendMode.srcIn}) {
    return BackdropFilter(
      blendMode: blendMode,
      filter: ImageFilter.erode(radiusX: radiusX, radiusY: radiusY),
      child: this,
    );
  }

  Widget safeArea({
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    bool maintainBottomViewPadding = false,
  }) {
    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: this,
    );
  }

  Widget opacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  Widget card({
    Color? color,
    double elevation = 1.0,
    ShapeBorder? shape,
    Clip clipBehavior = Clip.none,
    Color shadowColor = const Color(0xFF000000),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    return Card(
      color: color,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      shadowColor: shadowColor,
      margin: margin,
      child: this,
    );
  }

  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(child: this, flex: flex, fit: fit);
  }

  Widget listenNotification<T extends Notification>(NotificationListenerCallback<T> onNotification) {
    return NotificationListener<T>(onNotification: onNotification, child: this);
  }

  Widget draggable() {
    return Draggable(
      child: this,
      feedback: this,
      childWhenDragging: this,
    );
  }

  Widget hero({required Object tag}) {
    return Hero(tag: tag, child: this);
  }

  Widget interactive({
    bool panEnabled = true,
    bool scaleEnabled = true,
    bool constrained = true,
    EdgeInsets boundaryMargin = EdgeInsets.zero,
    Clip clipBehavior = Clip.hardEdge,
    PanAxis panAxis = PanAxis.free,
    Alignment? alignment,
    double minScale = 0.8,
    double maxScale = 2.5,
    double scaleFactor = 200,
    GestureScaleStartCallback? onInteractionStart,
    GestureScaleUpdateCallback? onInteractionUpdate,
    GestureScaleEndCallback? onInteractionEnd,
  }) {
    return InteractiveViewer(
      child: this,
      minScale: minScale,
      maxScale: maxScale,
      scaleEnabled: scaleEnabled,
      scaleFactor: scaleFactor,
      alignment: alignment,
      panEnabled: panEnabled,
      boundaryMargin: boundaryMargin,
      clipBehavior: clipBehavior,
      panAxis: panAxis,
      constrained: constrained,
      onInteractionStart: onInteractionStart,
      onInteractionUpdate: onInteractionUpdate,
      onInteractionEnd: onInteractionEnd,
    );
  }

  Widget onTab(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }

  Widget onDoubleTab(VoidCallback onDoubleTap) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: this,
    );
  }

  Widget onLongPress(VoidCallback onLongPress) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: this,
    );
  }

}
