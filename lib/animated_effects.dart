import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// مؤثرات حركية قابلة لإعادة الاستخدام
class AnimatedEffects {
  // مؤثر التحميل
  static Widget loading({
    double size = 100,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.network(
        'https://assets7.lottiefiles.com/packages/lf20_x62chJ.json',
        fit: BoxFit.contain,
      ),
    );
  }

  // مؤثر النجاح
  static Widget success({
    double size = 100,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.network(
        'https://assets10.lottiefiles.com/packages/lf20_vyqtshrp.json',
        fit: BoxFit.contain,
      ),
    );
  }

  // مؤثر الخطأ
  static Widget error({
    double size = 100,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.network(
        'https://assets8.lottiefiles.com/packages/lf20_rz2ymwxz.json',
        fit: BoxFit.contain,
      ),
    );
  }

  // مؤثر إرسال الرسائل
  static Widget messageSent({
    double size = 100,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.network(
        'https://assets9.lottiefiles.com/packages/lf20_dtj3k2nb.json',
        fit: BoxFit.contain,
      ),
    );
  }

  // مؤثر الانتظار
  static Widget waiting({
    double size = 100,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.network(
        'https://assets4.lottiefiles.com/packages/lf20_qw0f6h9q.json',
        fit: BoxFit.contain,
      ),
    );
  }

  // مؤثر مكالمة هاتفية
  static Widget phoneCall({
    double size = 100,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.network(
        'https://assets1.lottiefiles.com/packages/lf20_qhn7xh0z.json',
        fit: BoxFit.contain,
      ),
    );
  }

  // مؤثر التوصيل
  static Widget delivery({
    double size = 100,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.network(
        'https://assets7.lottiefiles.com/packages/lf20_bp5lntrf.json',
        fit: BoxFit.contain,
      ),
    );
  }
}

// تأثير الظهور التدريجي
class FadeInEffect extends StatelessWidget {
  final Widget child;
  final int delay;

  const FadeInEffect({required this.child, this.delay = 0, super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 700 + delay),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}

// مؤثرات حركية للأزرار
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? color;
  final double scale;
  final Duration duration;

  const AnimatedButton({
    required this.child,
    required this.onPressed,
    this.color,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 150),
    super.key,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// تأثيرات ظهور واختفاء للعناصر
class FadeSlideInEffect extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;

  const FadeSlideInEffect({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.offset = const Offset(0, 50),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              offset.dx * (1 - value),
              offset.dy * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
