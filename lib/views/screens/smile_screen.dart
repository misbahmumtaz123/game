import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Screen displaying a floating bubble with emoji & text that stays until the user hits the emoji (or pops after optional duration).
class SmileScreen extends StatefulWidget {
  final String emoji;
  final String text;
  final List<Color> backgroundColors;
  final Duration? displayDuration;

  const SmileScreen({
    super.key,
    this.emoji = '😊',
    this.text = 'Please smile',
    this.backgroundColors = const [
      Color(0xFF0F172A),
      Color(0xFF1E3A8A),
      Color(0xFF38BDF8),
    ],
    this.displayDuration,
  });

  @override
  State<SmileScreen> createState() => _SmileScreenState();
}

class _SmileScreenState extends State<SmileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _popController;

  Timer? _autoPopTimer;
  Timer? _dismissTimer;
  bool _isPopping = false;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    // Auto-pop bubble only if a display duration is provided; otherwise stays until emoji is hit
    if (widget.displayDuration != null) {
      _autoPopTimer = Timer(widget.displayDuration!, () {
        _popBubble();
      });
    }
  }

  void _popBubble() {
    if (_isPopping || !mounted) return;
    _isPopping = true;
    _autoPopTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {});

    _popController.forward(from: 0.0);
    _dismissTimer = Timer(const Duration(milliseconds: 380), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoPopTimer?.cancel();
    _dismissTimer?.cancel();
    _floatController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _popBubble,
        onPanDown: (_) {},
        onPanUpdate: (details) {
          if (!_isPopping) {
            setState(() {
              _dragOffset += details.delta;
            });
          }
        },
        onPanEnd: (details) {
          // Immediately pop on fling / swipe in any direction
          _popBubble();
        },
        onPanCancel: () {
          if (!_isPopping && mounted) {
            setState(() {
              _dragOffset = Offset.zero;
            });
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.backgroundColors,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double availableWidth = constraints.maxWidth;
                  final double availableHeight = constraints.maxHeight;
                  final double shortest = min(availableWidth, availableHeight);
                  final bool isLongText = widget.text.length > 25;

                  // Responsively calculate bubble size ensuring it fits both width and height
                  final double maxBubbleForHeight =
                      (availableHeight * (isLongText ? 0.38 : 0.46)).clamp(
                        110.0,
                        240.0,
                      );
                  final double maxBubbleForWidth =
                      (availableWidth * (isLongText ? 0.48 : 0.58)).clamp(
                        110.0,
                        240.0,
                      );
                  final double bubbleSize = min(
                    maxBubbleForHeight,
                    maxBubbleForWidth,
                  );

                  final double emojiSize = (bubbleSize * 0.54).clamp(
                    isLongText ? 58.0 : 72.0,
                    isLongText ? 105.0 : 126.0,
                  );
                  final double fontSize = isLongText
                      ? (shortest * 0.045).clamp(14.0, 19.5)
                      : (shortest * 0.080).clamp(22.0, 36.0);

                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _floatController,
                          _popController,
                        ]),
                        builder: (context, _) {
                          final floatOffset =
                              sin(_floatController.value * pi) * 8.0;
                          final popVal = _popController.value;

                          // Responsive drag offset with elastic damping
                          final double dragX = _dragOffset.dx.clamp(
                            -100.0,
                            100.0,
                          );
                          final double dragY = _dragOffset.dy.clamp(
                            -100.0,
                            100.0,
                          );
                          final double tiltAngle = (dragX / 100.0) * 0.22;

                          // Pop scale and fade
                          final double bubbleScale = _isPopping
                              ? (1.0 + popVal * 0.35)
                              : (0.95 + (_floatController.value * 0.07));
                          final double bubbleOpacity = _isPopping
                              ? (1.0 - popVal).clamp(0.0, 1.0)
                              : 1.0;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Bubble & Pop Particles Stack
                              Transform.translate(
                                offset: Offset(
                                  dragX * 0.5,
                                  floatOffset + (dragY * 0.5),
                                ),
                                child: Transform.rotate(
                                  angle: tiltAngle,
                                  child: SizedBox(
                                    width: bubbleSize * 1.6,
                                    height: bubbleSize * 1.6,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // 1. Expanding Shockwave Ring on pop
                                        if (_isPopping)
                                          Container(
                                            width:
                                                bubbleSize *
                                                (0.8 + popVal * 0.8),
                                            height:
                                                bubbleSize *
                                                (0.8 + popVal * 0.8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withAlpha(
                                                  ((1.0 - popVal) * 220)
                                                      .toInt(),
                                                ),
                                                width: (3.0 * (1.0 - popVal))
                                                    .clamp(0.5, 3.0),
                                              ),
                                            ),
                                          ),

                                        // 2. Flying burst droplet particles on pop
                                        if (_isPopping)
                                          for (int i = 0; i < 10; i++) ...[
                                            Builder(
                                              builder: (context) {
                                                final angle =
                                                    (i / 10.0) * 2.0 * pi;
                                                final dist =
                                                    popVal *
                                                    (bubbleSize * 0.72);
                                                final pOpacity = (1.0 - popVal)
                                                    .clamp(0.0, 1.0);
                                                final pSize =
                                                    (8.0 * (1.0 - popVal * 0.5))
                                                        .clamp(2.5, 8.0);
                                                return Transform.translate(
                                                  offset: Offset(
                                                    cos(angle) * dist,
                                                    sin(angle) * dist,
                                                  ),
                                                  child: Opacity(
                                                    opacity: pOpacity,
                                                    child: Container(
                                                      width: pSize,
                                                      height: pSize,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(
                                                              0xFFFFD54F,
                                                            ).withAlpha(180),
                                                            blurRadius: 6.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],

                                        // 3. The Soap Bubble Orb (Hit to pop)
                                        Opacity(
                                          opacity: bubbleOpacity,
                                          child: Transform.scale(
                                            scale: bubbleScale,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: _popBubble,
                                              child: Container(
                                                width: bubbleSize,
                                                height: bubbleSize,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient:
                                                      const RadialGradient(
                                                        center: Alignment(
                                                          -0.35,
                                                          -0.35,
                                                        ),
                                                        radius: 0.88,
                                                        colors: [
                                                          Color(0xD2FFFFFF),
                                                          Color(0x32FFFFFF),
                                                          Color(0x14FFFFFF),
                                                          Color(0x5AFFFFFF),
                                                          Color(0x96FFFFFF),
                                                        ],
                                                        stops: [
                                                          0.0,
                                                          0.35,
                                                          0.65,
                                                          0.88,
                                                          1.0,
                                                        ],
                                                      ),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withAlpha(180),
                                                    width: 2.2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFFFD54F,
                                                      ).withAlpha(100),
                                                      blurRadius: 36.0,
                                                      spreadRadius: 6.0,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withAlpha(90),
                                                      blurRadius: 18.0,
                                                      spreadRadius: 2.0,
                                                    ),
                                                  ],
                                                ),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    // Bubble Specular Shine Top-Left
                                                    Positioned(
                                                      top: bubbleSize * 0.16,
                                                      left: bubbleSize * 0.20,
                                                      child: Transform.rotate(
                                                        angle: -pi / 4.5,
                                                        child: Container(
                                                          width:
                                                              bubbleSize * 0.24,
                                                          height:
                                                              bubbleSize * 0.11,
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                  Radius.elliptical(
                                                                    bubbleSize *
                                                                        0.24,
                                                                    bubbleSize *
                                                                        0.11,
                                                                  ),
                                                                ),
                                                            color: Colors.white
                                                                .withAlpha(220),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // Secondary Reflection Bottom-Right
                                                    Positioned(
                                                      bottom: bubbleSize * 0.18,
                                                      right: bubbleSize * 0.22,
                                                      child: Container(
                                                        width:
                                                            bubbleSize * 0.09,
                                                        height:
                                                            bubbleSize * 0.09,
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors
                                                                  .white
                                                                  .withAlpha(
                                                                    140,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),

                                                    // Big Emoji inside bubble
                                                    Text(
                                                      widget.emoji,
                                                      style: TextStyle(
                                                        fontSize: emojiSize,
                                                        height: 1.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16.0),

                              // Text (e.g. "Please smile", "Please laugh", or life quote with separate line)
                              Opacity(
                                opacity: _isPopping
                                    ? (1.0 - popVal).clamp(0.0, 1.0)
                                    : 1.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: Text(
                                    widget.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w900,
                                      height: isLongText ? 1.38 : 1.1,
                                      letterSpacing: 0.6,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withAlpha(140),
                                          blurRadius: 12.0,
                                          offset: const Offset(0, 3),
                                        ),
                                        Shadow(
                                          color: const Color(
                                            0xFFFFD54F,
                                          ).withAlpha(160),
                                          blurRadius: 18.0,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
