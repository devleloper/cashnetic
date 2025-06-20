import 'dart:ui';
import 'package:flutter/material.dart';

class UnavailableFeatureDialog extends StatelessWidget {
  const UnavailableFeatureDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          Center(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                child: Text(
                  'Функция пока недоступна,\nно скоро появится!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
