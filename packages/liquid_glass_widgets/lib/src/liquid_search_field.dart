import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Универсальное стеклянное поле поиска с анимацией продавливания и кастомизацией.
class LiquidSearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final Color? glassColor;
  final double borderRadius;
  final double thickness;
  final double blur;
  final double blend;
  final double lightIntensity;
  final double lightAngle;
  final double refractiveIndex;

  const LiquidSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.style,
    this.contentPadding,
    this.focusNode,
    this.glassColor,
    this.borderRadius = 16,
    this.thickness = 20,
    this.blur = 2,
    this.blend = 500,
    this.lightIntensity = 2,
    this.lightAngle = 250,
    this.refractiveIndex = 2,
  });

  @override
  State<LiquidSearchField> createState() => _LiquidSearchFieldState();
}

class _LiquidSearchFieldState extends State<LiquidSearchField>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _rotationAnim;
  bool _isFocused = false;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _rotationAnim = Tween<double>(begin: -0.5, end: 0.0).animate(_fadeAnim);
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
      value: 1.0,
      lowerBound: 0.96,
      upperBound: 1.0,
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.elasticOut,
    );
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (_isFocused) {
        _animController.forward();
      } else {
        _animController.reverse();
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.forward();
  }

  void _onTapCancel() {
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: LiquidGlass(
          settings: LiquidGlassSettings(
            thickness: widget.thickness,
            blur: widget.blur,
            blend: widget.blend,
            lightIntensity: widget.lightIntensity,
            lightAngle: widget.lightAngle,
            refractiveIndex: widget.refractiveIndex,
            glassColor: widget.glassColor ?? const Color.fromARGB(19, 0, 0, 0),
          ),
          shape: LiquidRoundedSuperellipse(
            borderRadius: Radius.circular(widget.borderRadius),
          ),
          glassContainsChild: false,
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            onChanged: widget.onChanged,
            style: widget.style ?? const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  widget.contentPadding ??
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              hintText: widget.hintText ?? 'Search',
              prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
              suffixIcon:
                  widget.suffixIcon ??
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnim.value,
                        child: Transform.rotate(
                          angle: _rotationAnim.value * 3.1415926,
                          child: IgnorePointer(
                            ignoring: !_isFocused,
                            child: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                widget.controller.clear();
                                FocusScope.of(context).unfocus();
                                widget.onChanged('');
                              },
                            ),
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
