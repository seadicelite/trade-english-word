import 'package:flutter/material.dart';
import 'dart:math';
import 'core/colors.dart';

class OverlaySplash extends StatefulWidget {
  final Widget child;
  const OverlaySplash({super.key, required this.child});

  @override
  State<OverlaySplash> createState() => _OverlaySplashState();
}

class _OverlaySplashState extends State<OverlaySplash>
    with SingleTickerProviderStateMixin {
  bool _hide = false;

  late AnimationController _waveController;
  late Animation<double> _shipY;

  @override
  void initState() {
    super.initState();

    // ⭐ 1秒後フェードアウト
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _hide = true);
    });

    // ⭐ 船をゆらゆら
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _shipY = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // ⭐ ここで overlay を画面全体に広げる
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _hide,
            child: AnimatedOpacity(
              opacity: _hide ? 0 : 1,
              duration: const Duration(milliseconds: 400),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFb3e5fc),
                      Color(0xFF81d4fa),
                      Color(0xFF4fc3f7),
                      Color(0xFF29b6f6),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 🌊 波（真ん中）
                    Positioned(
                      bottom: 120,
                      child: CustomPaint(
                        painter: WavePainter(),
                        size: const Size(200, 40),
                      ),
                    ),

                    // 🚢 船（上下ゆらゆら）
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _shipY.value),
                          child: const Icon(
                            Icons.directions_boat_filled,
                            size: 70,
                            color: sc.text,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ⭐ 波の描画
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    for (double x = 0; x <= size.width; x++) {
      double y = 10 * sin(x / 20);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
