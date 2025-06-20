import 'package:flutter/material.dart';

class TransactionsFlyChip extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String emoji;
  final Color bgColor;
  const TransactionsFlyChip({
    required this.start,
    required this.end,
    required this.emoji,
    required this.bgColor,
    super.key,
  });

  @override
  State<TransactionsFlyChip> createState() => _TransactionsFlyChipState();
}

class _TransactionsFlyChipState extends State<TransactionsFlyChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _positionAnim = Tween<Offset>(begin: widget.start, end: widget.end).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeInOutCubic),
      ),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeIn),
      ),
    );
    _opacityAnim = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 75),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pos = _positionAnim.value;
        final left = (pos.dx - 28).clamp(0.0, screenSize.width - 56);
        final top = (pos.dy - 28).clamp(0.0, screenSize.height - 56);
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: left,
              top: top,
              child: Opacity(
                opacity: _opacityAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.bgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 28),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
