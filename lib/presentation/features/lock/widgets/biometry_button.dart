import 'package:flutter/material.dart';

class BiometryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const BiometryButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.fingerprint, size: 36),
      onPressed: onPressed,
      tooltip: 'Use biometrics',
    );
  }
}
