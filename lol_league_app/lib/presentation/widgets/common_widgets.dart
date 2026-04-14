import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

// ==================== 高级背景组件 ====================
class CyberBackground extends StatelessWidget {
  final Widget child;

  const CyberBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundDeep,
            Color(0xFF050510),
            AppColors.backgroundPrimary,
            Color(0xFF080818),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 精密网格背景
          Positioned.fill(
            child: CustomPaint(
              painter: _AdvancedGridPainter(),
            ),
          ),
          // 渐变光晕叠加
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(0, 229, 255, 0.04),
                    Color.fromRGBO(170, 68, 255, 0.02),
                    Colors.transparent,
                  ],
                  center: Alignment.topRight,
                  radius: 1.8,
                ),
              ),
            ),
          ),
          // 左下角辅助光晕
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(255, 0, 153, 0.03),
                    Colors.transparent,
                  ],
                  center: Alignment.bottomLeft,
                  radius: 1.2,
                ),
              ),
            ),
          ),
          // 主内容
          child,
        ],
      ),
    );
  }
}

class _AdvancedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 主网格
    final paint = Paint()
      ..color = Color.fromRGBO(40, 40, 64, 0.15)
      ..strokeWidth = 0.5;

    const spacing = 50.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 辅助细网格
    final finePaint = Paint()
      ..color = Color.fromRGBO(40, 40, 64, 0.06)
      ..strokeWidth = 0.3;

    const fineSpacing = 10.0;

    for (double x = 0; x < size.width; x += fineSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), finePaint);
    }

    for (double y = 0; y < size.height; y += fineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), finePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== 高级玻璃卡片 ====================
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? borderColor;
  final Color? glowColor;
  final double borderRadius;
  final bool hasGlow;
  final bool isHero;
  final LinearGradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.glowColor,
    this.borderRadius = 20,
    this.hasGlow = false,
    this.isHero = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.borderDefault;
    final effectiveGlowColor = glowColor ?? AppColors.neonBlue;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient ?? AppConstants.deepCardGradient,
        border: Border.all(
          color: effectiveBorderColor.withAlpha(isHero ? 200 : 100),
          width: isHero ? 1.5 : 0.8,
        ),
        boxShadow: hasGlow && glowColor != null
            ? [
                ...AppConstants.neonGlowStrong(effectiveGlowColor),
                BoxShadow(
                  color: effectiveGlowColor.withAlpha(25),
                  blurRadius: 60,
                  spreadRadius: 0,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isHero ? 15 : 12, sigmaY: isHero ? 15 : 12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHero
                    ? [
                        Color.fromRGBO(30, 30, 60, 0.6),
                        Color.fromRGBO(15, 15, 30, 0.4),
                      ]
                    : [
                        Color.fromRGBO(25, 25, 50, 0.4),
                        Color.fromRGBO(12, 12, 28, 0.3),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ==================== 渐变边框卡片 ====================
class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final LinearGradient borderGradient;
  final double borderWidth;
  final double borderRadius;
  final Color? backgroundColor;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    required this.borderGradient,
    this.borderWidth = 2,
    this.borderRadius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: borderGradient,
        boxShadow: [
          BoxShadow(
            color: borderGradient.colors.first.withAlpha(51),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          color: backgroundColor ?? AppColors.backgroundCard,
        ),
        child: child,
      ),
    );
  }
}

// ==================== 高级霓虹按钮 ====================
class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;
  final IconData? icon;
  final bool isOutlined;
  final double? width;
  final bool isCompact;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.color = AppColors.neonBlue,
    this.icon,
    this.isOutlined = false,
    this.width,
    this.isCompact = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color;
    final horizontalPadding = widget.isCompact ? 20.0 : 28.0;
    final verticalPadding = widget.isCompact ? 12.0 : 16.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: widget.width,
              transform: Matrix4.identity()
                ..setEntry(0, 0, _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0)),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
              decoration: BoxDecoration(
                gradient: widget.isOutlined
                    ? null
                    : LinearGradient(
                        colors: [
                          effectiveColor,
                          effectiveColor.withAlpha(200),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: widget.isOutlined ? Colors.transparent : null,
                borderRadius: BorderRadius.circular(widget.isCompact ? 12 : 16),
                border: widget.isOutlined
                    ? Border.all(color: effectiveColor, width: 1.5)
                    : Border.all(color: effectiveColor.withAlpha(150), width: 0.5),
                boxShadow: widget.isOutlined
                    ? _isHovered
                        ? [
                            BoxShadow(
                              color: effectiveColor.withAlpha(76),
                              blurRadius: 16,
                              spreadRadius: 0,
                            ),
                          ]
                        : null
                    : [
                        BoxShadow(
                          color: effectiveColor.withAlpha((_glowAnimation.value * 200).toInt()),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: effectiveColor.withAlpha((_glowAnimation.value * 100).toInt()),
                          blurRadius: 32,
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: _buildChild(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: widget.isCompact ? 18 : 22,
          height: widget.isCompact ? 18 : 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: widget.isOutlined ? widget.color : Colors.white,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: widget.isCompact ? 18 : 20,
            color: widget.isOutlined ? widget.color : Colors.white,
          ),
          SizedBox(width: widget.isCompact ? 8 : 10),
        ],
        Text(
          widget.text,
          style: TextStyle(
            color: widget.isOutlined ? widget.color : Colors.white,
            fontSize: widget.isCompact ? 14 : 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ==================== 高级输入框 ====================
class PremiumTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final IconData? prefixIcon;
  final Color? accentColor;
  final bool enabled;

  const PremiumTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
    this.accentColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? const Color(0xFF00D4FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: accent.withAlpha(128), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textMuted, size: 20)
                : null,
            filled: true,
            fillColor: AppColors.backgroundElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF3366), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF3366), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== 加载遮罩 ====================
class PremiumLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const PremiumLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: const Color(0xB3000000),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderDefault),
                  boxShadow: AppConstants.neonGlow(const Color(0xFF00D4FF), 30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: const Color(0xFF00D4FF),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '加载中...',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ==================== 空状态 ====================
class PremiumEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const PremiumEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Icon(icon, size: 56, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 28),
              NeonButton(
                text: actionText!,
                onPressed: onAction,
                color: const Color(0xFF00D4FF),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== 霓虹状态徽章 ====================
class NeonBadge extends StatefulWidget {
  final String status;
  final bool showGlow;

  const NeonBadge({super.key, required this.status, this.showGlow = true});

  @override
  State<NeonBadge> createState() => _NeonBadgeState();
}

class _NeonBadgeState extends State<NeonBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(widget.status);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withAlpha(120),
              width: 1,
            ),
            boxShadow: widget.showGlow
                ? [
                    BoxShadow(
                      color: color.withAlpha((_animation.value * 80).toInt()),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.status,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待审核':
        return AppColors.neonOrange;
      case '待应战':
        return AppColors.neonBlue;
      case '已约战':
        return AppColors.neonGreen;
      case '已结束':
        return AppColors.textMuted;
      case '已取消':
        return AppColors.neonRed;
      case '未通过':
        return AppColors.neonRed;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ==================== 状态点 ====================
class StatusDot extends StatelessWidget {
  final String status;
  final double size;

  const StatusDot({super.key, required this.status, this.size = 10});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(150),
            blurRadius: size,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待审核':
        return AppColors.neonOrange;
      case '待应战':
        return AppColors.neonBlue;
      case '已约战':
        return AppColors.neonGreen;
      case '已结束':
        return AppColors.textMuted;
      case '已取消':
        return AppColors.neonRed;
      case '未通过':
        return AppColors.neonRed;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ==================== 高级排行卡片 ====================
class PremiumRankCard extends StatelessWidget {
  final int rank;
  final String name;
  final String value;
  final String? subtitle;
  final Color? accentColor;
  final bool showBorderGlow;

  const PremiumRankCard({
    super.key,
    required this.rank,
    required this.name,
    required this.value,
    this.subtitle,
    this.accentColor,
    this.showBorderGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;
    final rankColor = _getRankColor(rank);
    final accent = accentColor ?? rankColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: AppConstants.deepCardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTopThree ? rankColor.withAlpha(128) : AppColors.borderDefault.withAlpha(100),
          width: isTopThree ? 1.2 : 0.8,
        ),
        boxShadow: isTopThree && showBorderGlow
            ? [
                ...AppConstants.neonGlow(rankColor, 8),
                BoxShadow(
                  color: rankColor.withAlpha(13),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildRankBadge(rankColor, isTopThree),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent,
                    accent.withAlpha(180),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppConstants.softGlow(accent),
                border: Border.all(
                  color: accent.withAlpha(100),
                  width: 0.5,
                ),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(Color color, bool isTopThree) {
    if (isTopThree) {
      final emojis = ['🥇', '🥈', '🥉'];
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color, color.withAlpha(150)],
            center: Alignment.center,
            radius: 0.8,
          ),
          shape: BoxShape.circle,
          boxShadow: AppConstants.neonGlow(color, 12),
          border: Border.all(color: color.withAlpha(200), width: 1.5),
        ),
        child: Center(
          child: Text(
            emojis[rank - 1],
            style: const TextStyle(fontSize: 24),
          ),
        ),
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.neonGold;
      case 2:
        return const Color(0xFFE0E0E8);
      case 3:
        return const Color(0xFFFF8844);
      default:
        return AppColors.neonBlue;
    }
  }
}

// ==================== 高级统计卡片 ====================
class GamingStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final bool isAnimated;

  const GamingStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.isAnimated = true,
  });

  @override
  State<GamingStatCard> createState() => _GamingStatCardState();
}

class _GamingStatCardState extends State<GamingStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.identity()..setEntry(0, 0, _isPressed ? 0.97 : 1.0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppConstants.deepCardGradient,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.color.withAlpha(80),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withAlpha((_glowAnimation.value * 40).toInt()),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            widget.color.withAlpha(50),
                            widget.color.withAlpha(20),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.color.withAlpha(100),
                          width: 1,
                        ),
                        boxShadow: AppConstants.softGlow(widget.color),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 24),
                    ),
                    if (widget.subtitle != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.color.withAlpha(60),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          widget.subtitle!,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [widget.color, widget.color.withAlpha(180)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== 高级约战卡片 ====================
class MatchCard extends StatelessWidget {
  final String teamName;
  final String opponentName;
  final String mode;
  final String time;
  final String status;
  final VoidCallback? onTap;
  final String? region;

  const MatchCard({
    super.key,
    required this.teamName,
    required this.opponentName,
    required this.mode,
    required this.time,
    required this.status,
    this.onTap,
    this.region,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: AppConstants.deepCardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.borderDefault.withAlpha(120),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 顶部: 模式标签
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.neonBlue.withAlpha(40),
                          AppColors.neonPurple.withAlpha(40),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.neonBlue.withAlpha(60),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sports_esports,
                          size: 14,
                          color: AppColors.neonBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          mode,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (region != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.borderDefault,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            region!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              // 中间: 战队信息
              Row(
                children: [
                  Expanded(
                    child: _buildTeamColumn(teamName, true, AppColors.neonBlue),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderDefault,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.sports,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'VS',
                          style: TextStyle(
                            color: AppColors.neonPink,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildTeamColumn(opponentName, false, AppColors.neonPurple),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 分隔线
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.borderHighlight.withAlpha(100),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 底部: 时间和状态
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundElevated,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamColumn(String name, bool isLeft, Color accentColor) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                accentColor.withAlpha(60),
                accentColor.withAlpha(20),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor.withAlpha(120),
              width: 1.5,
            ),
            boxShadow: AppConstants.softGlow(accentColor),
          ),
          child: Icon(
            Icons.shield,
            size: 26,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withAlpha(100),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(51),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待审核':
        return AppColors.neonOrange;
      case '待应战':
        return AppColors.neonBlue;
      case '已约战':
        return AppColors.neonGreen;
      case '已结束':
        return AppColors.textMuted;
      case '已取消':
        return AppColors.neonRed;
      case '未通过':
        return AppColors.neonRed;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ==================== 高级用户头像卡片 ====================
class UserAvatarCard extends StatelessWidget {
  final String username;
  final String? subtitle;
  final bool isAdmin;
  final double size;
  final Color? accentColor;
  final bool showGlow;

  const UserAvatarCard({
    super.key,
    required this.username,
    this.subtitle,
    this.isAdmin = false,
    this.size = 80,
    this.accentColor,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.neonBlue;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(25),
            AppColors.backgroundCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withAlpha(80),
          width: 1,
        ),
        boxShadow: showGlow
            ? [
                ...AppConstants.softGlow(color),
                BoxShadow(
                  color: color.withAlpha(20),
                  blurRadius: 40,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [color, color.withAlpha(150)],
                center: Alignment.center,
                radius: 0.8,
              ),
              shape: BoxShape.circle,
              boxShadow: showGlow ? AppConstants.neonGlow(color, 15) : null,
              border: Border.all(
                color: color.withAlpha(200),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppConstants.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppConstants.softGlow(AppColors.neonGold),
                      border: Border.all(
                        color: AppColors.neonGold.withAlpha(150),
                        width: 0.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          '管理员',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 高级快捷操作卡片 ====================
class QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool showPulse;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.showPulse = false,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.identity()
              ..setEntry(0, 0, _isPressed ? 0.95 : 1.0)
              ..scale(widget.showPulse ? _pulseAnimation.value : 1.0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppConstants.deepCardGradient,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.color.withAlpha(100),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withAlpha(40),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        widget.color.withAlpha(60),
                        widget.color.withAlpha(20),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withAlpha(120),
                      width: 1.5,
                    ),
                    boxShadow: AppConstants.softGlow(widget.color),
                  ),
                  child: Icon(widget.icon, size: 28, color: widget.color),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 兼容旧组件名
class AppButton extends NeonButton {
  const AppButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isOutlined,
    super.color,
    super.icon,
  });
}

class AppTextField extends PremiumTextField {
  const AppTextField({
    super.key,
    required super.label,
    super.hint,
    super.controller,
    super.obscureText,
    super.keyboardType,
    super.validator,
    super.maxLines,
    super.prefixIcon,
  });
}

class LoadingOverlay extends PremiumLoadingOverlay {
  const LoadingOverlay({
    super.key,
    required super.isLoading,
    required super.child,
  });
}

class EmptyState extends PremiumEmptyState {
  const EmptyState({
    super.key,
    required super.message,
    super.icon,
    super.onAction,
    super.actionText,
  });
}

class StatusBadge extends NeonBadge {
  const StatusBadge({super.key, required super.status});
}

class RankCard extends PremiumRankCard {
  const RankCard({
    super.key,
    required super.rank,
    required super.name,
    required super.value,
    super.subtitle,
    super.accentColor,
  });
}

class StatCard extends GamingStatCard {
  const StatCard({
    super.key,
    required super.title,
    required super.value,
    required super.icon,
    required super.color,
    super.subtitle,
  });
}
