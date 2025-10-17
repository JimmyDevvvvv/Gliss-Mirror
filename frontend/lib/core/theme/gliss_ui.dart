import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'design_system.dart';

/// A collection of exceptional UI components for Gliss Mirror
/// that create memorable interactions and stand out in competition
class GlissUI {
  /// Gets the appropriate color for a damage score based on severity
  static Color getDamageColor(int score) {
    if (score <= 3) return AppTheme.sageGreen;
    if (score <= 6) return AppTheme.freshYellow;
    if (score <= 8) return AppTheme.brightOrange;
    return AppTheme.henkelRed;
  }

  /// Premium primary button with advanced micro-interactions and haptic feedback
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return AnimatedButton(
      onPressed: isLoading ? null : onPressed,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing3,
          vertical: DesignTokens.spacing2,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.henkelRed, Color(0xFFB8000C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppTheme.henkelRed.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pureWhite),
                ),
              )
            : Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppTheme.pureWhite, size: 20),
                    SizedBox(width: DesignTokens.spacing1),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppTheme.pureWhite,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Elevated secondary button with glassmorphism effect
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return AnimatedButton(
      onPressed: onPressed,
      scaleValue: 0.97,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing3,
          vertical: DesignTokens.spacing2,
        ),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          border: Border.all(color: AppTheme.henkelRed, width: 2),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppTheme.henkelRed.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.henkelRed, size: 20),
              SizedBox(width: DesignTokens.spacing1),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppTheme.henkelRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Premium card with smooth elevation transitions
  static Widget card({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    Color? backgroundColor,
    List<BoxShadow>? elevation,
    bool enableHoverEffect = true,
  }) {
    return AnimatedCard(
      onTap: onTap,
      enableHoverEffect: enableHoverEffect && onTap != null,
      child: Container(
        padding: padding ?? EdgeInsets.all(DesignTokens.spacing2),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          boxShadow: elevation ?? DesignTokens.elevation1,
        ),
        child: child,
      ),
    );
  }

  /// Advanced damage score indicator with circular progress and animations
  static Widget damageScoreIndicator({
    required int score,
    required String label,
    bool animate = true,
    String? subtitle,
  }) {
    final Color scoreColor = _getDamageColor(score);
    final String scoreLabel = _getDamageLabel(score);

    return card(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      backgroundColor: scoreColor.withOpacity(0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkBlue,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: DesignTokens.spacing3),
          // Circular progress indicator
          TweenAnimationBuilder<double>(
            duration: animate
                ? const Duration(milliseconds: 1500)
                : Duration.zero,
            tween: Tween(begin: 0, end: score.toDouble()),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: value / 10,
                      backgroundColor: AppTheme.warmGreyLight,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: scoreColor,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '/ 10',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.darkBlue.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: DesignTokens.spacing2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              scoreLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scoreColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: DesignTokens.spacing1),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.darkBlue.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Premium product card with enhanced visuals and interactions
  static Widget productCard({
    required String name,
    required String description,
    required String imageUrl,
    required double price,
    VoidCallback? onTap,
    String? badge,
    bool isRecommended = false,
  }) {
    return AnimatedCard(
      onTap: onTap,
      enableHoverEffect: true,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: isRecommended
              ? Border.all(color: AppTheme.deepViolet, width: 2)
              : null,
          boxShadow: DesignTokens.elevation2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(DesignTokens.radiusLarge),
                    topRight: Radius.circular(DesignTokens.radiusLarge),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.softBlue.withOpacity(0.3),
                            AppTheme.softMint.withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.warmGreyLight,
                            child: const Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: AppTheme.warmGrey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (badge != null || isRecommended)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isRecommended
                              ? [AppTheme.deepViolet, AppTheme.darkLilac]
                              : [AppTheme.brightOrange, AppTheme.henkelRed],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        badge ?? 'RECOMMENDED',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.pureWhite,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content section
            Padding(
              padding: EdgeInsets.all(DesignTokens.spacing2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkBlue,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: DesignTokens.spacing1),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkBlue.withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: DesignTokens.spacing2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EGP ${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.deepViolet,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Best Value',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.sageGreen,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.henkelRed, Color(0xFFB8000C)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.henkelRed.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppTheme.pureWhite,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Damage category breakdown card
  static Widget damageBreakdownCard({
    required String title,
    required int score,
    required IconData icon,
    String? description,
  }) {
    final Color scoreColor = _getDamageColor(score);

    return card(
      padding: EdgeInsets.all(DesignTokens.spacing2),
      backgroundColor: scoreColor.withOpacity(0.05),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: scoreColor, size: 24),
          ),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkBlue,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkBlue.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0, end: score.toDouble()),
            builder: (context, value, child) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: scoreColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Progress comparison widget for before/after
  static Widget progressComparison({
    required int previousScore,
    required int currentScore,
    required String timeframe,
  }) {
    final int difference = currentScore - previousScore;
    final bool improved = difference < 0; // Lower score is better

    return card(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      backgroundColor: improved
          ? AppTheme.brightMint.withOpacity(0.1)
          : AppTheme.warmGreyLight,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreColumn('Before', previousScore, false),
              Icon(
                improved ? Icons.trending_down : Icons.trending_up,
                color: improved ? AppTheme.sageGreen : AppTheme.brightOrange,
                size: 32,
              ),
              _buildScoreColumn('After', currentScore, true),
            ],
          ),
          SizedBox(height: DesignTokens.spacing2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: improved
                  ? AppTheme.sageGreen.withOpacity(0.15)
                  : AppTheme.brightOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              improved
                  ? '${difference.abs()} points improved in $timeframe! 🎉'
                  : 'Keep going! Continue your routine',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: improved ? AppTheme.deepGreen : AppTheme.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Info card with icon and description
  static Widget infoCard({
    required String title,
    required String description,
    required IconData icon,
    Color? iconColor,
  }) {
    return card(
      padding: EdgeInsets.all(DesignTokens.spacing2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.freshBlue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? AppTheme.freshBlue, size: 22),
          ),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.darkBlue.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  static Color _getDamageColor(int score) {
    if (score <= 3) return AppTheme.sageGreen;
    if (score <= 6) return AppTheme.freshYellow;
    if (score <= 8) return AppTheme.brightOrange;
    return AppTheme.henkelRed;
  }

  static String _getDamageLabel(int score) {
    if (score <= 3) return 'HEALTHY';
    if (score <= 6) return 'MODERATE';
    if (score <= 8) return 'DAMAGED';
    return 'SEVERE';
  }

  static Widget _buildScoreColumn(String label, int score, bool isHighlighted) {
    final Color color = _getDamageColor(score);
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.darkBlue.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: isHighlighted ? 36 : 28,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Custom animated button widget with press effects and haptic feedback
class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double scaleValue;

  const AnimatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.scaleValue = 0.95,
  }) : super(key: key);

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
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Animated card with hover/press effects
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableHoverEffect;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.enableHoverEffect = false,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableHoverEffect && widget.onTap != null) {
      _controller.forward();
      HapticFeedback.selectionClick();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableHoverEffect) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableHoverEffect) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    if (widget.enableHoverEffect && widget.onTap != null) {
      content = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: ScaleTransition(scale: _scaleAnimation, child: content),
      );
    } else if (widget.onTap != null) {
      content = GestureDetector(onTap: widget.onTap, child: content);
    }

    return content;
  }
}
