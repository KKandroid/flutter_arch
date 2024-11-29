import 'package:flutter/material.dart';

class AutoDisappearWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDisappear;

  const AutoDisappearWidget({
    Key? key,
    required this.child,
    this.onDisappear,
  }) : super(key: key);

  @override
  _AutoDisappearWidgetState createState() => _AutoDisappearWidgetState();
}

class _AutoDisappearWidgetState extends State<AutoDisappearWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000), // 6 seconds (1 for scale + 5 for opacity)
      vsync: this,
    );

    // Scale animation: from 0 to 1 in the first second
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.05, curve: Curves.easeOut),
      ),
    );

    // Opacity animation: remains visible for 5 seconds, then fades out
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDisappear?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
