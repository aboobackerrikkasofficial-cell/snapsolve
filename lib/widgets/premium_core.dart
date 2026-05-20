import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PremiumButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final bool isLoading;
  final double? width;
  final double height;

  const PremiumButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? const Color(0xFF6C63FF);
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey[300] : themeColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isHovered && !isDisabled
                  ? [
                      BoxShadow(
                        color: themeColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ]
                  : [],
              gradient: !isDisabled
                  ? LinearGradient(
                      colors: [themeColor, themeColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : DefaultTextStyle(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      child: widget.child,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const PremiumShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      onPlay: (controller) => controller.repeat(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ).shimmer(
      duration: const Duration(milliseconds: 1500),
      color: Colors.white.withOpacity(0.1),
      angle: 45,
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool animate;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.02),
            highlightColor: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );

    if (animate) {
      content = Animate(child: content)
          .fadeIn(duration: const Duration(milliseconds: 400))
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
    }

    return content;
  }
}
