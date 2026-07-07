import 'package:flutter/material.dart';

class AnimatedBubble extends StatefulWidget {
  const AnimatedBubble({
    super.key,
    required this.child,
    required this.isUser,
    this.animate = false,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });
  final Widget child;
  final bool animate;
  final bool isUser;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeAnimations();
      _isInitialized = true;
    }
  }

  void _initializeAnimations() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final startOffset =
        widget.isUser ? (isRTL ? -0.3 : 0.3) : (isRTL ? 0.3 : -0.3);

    _slideAnimation = Tween<Offset>(
      begin: Offset(startOffset, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        ),
      );
}
