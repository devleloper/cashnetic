import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final BiometricType? biometryType;
  const BiometryButton({Key? key, this.onPressed, this.biometryType})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    switch (biometryType) {
      case BiometricType.face:
        icon = Icons.face;
        label = 'Face ID';
        break;
      case BiometricType.fingerprint:
        icon = Icons.fingerprint;
        label = 'Touch ID';
        break;
      case BiometricType.iris:
        icon = Icons.remove_red_eye;
        label = 'Iris';
        break;
      default:
        icon = Icons.fingerprint;
        label = 'Biometrics';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 36),
          onPressed: onPressed,
          tooltip: 'Use $label',
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
