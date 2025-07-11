import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class CategorySearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const CategorySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<CategorySearchField> createState() => _CategorySearchFieldState();
}

class _CategorySearchFieldState extends State<CategorySearchField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  // --- Cross icon animation: controller, fade, and rotation ---
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _rotationAnim;
  // --- End: cross icon animation ---
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    // --- Cross icon animation initialization ---
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _rotationAnim = Tween<double>(begin: -0.5, end: 0.0).animate(_fadeAnim);
    // --- End of animation initialization ---
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      // --- Start cross icon animation ---
      if (_isFocused) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
      // --- End of animation start ---
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    // --- Dispose animation resources ---
    _animController.dispose();
    // --- End of resource disposal ---
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      settings: LiquidGlassSettings(
        thickness: 18,
        blur: 4,
        blend: 0.5,
        lightIntensity: 2,
        lightAngle: 180,
        refractiveIndex: 2,
        glassColor: const Color.fromARGB(19, 0, 0, 0),
      ),
      shape: LiquidRoundedSuperellipse(borderRadius: Radius.circular(16)),
      glassContainsChild: false,
      child: TextField(
        focusNode: _focusNode,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),

          hintText: S.of(context).searchCategory,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: AnimatedBuilder(
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
        controller: widget.controller,
        onChanged: widget.onChanged,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }
}
