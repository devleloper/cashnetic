import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatelessWidget {
  MyFloatingActionButton({super.key, required this.icon, this.onPressesd});

  IconData icon;
  VoidCallback? onPressesd;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'expenses_fab',

      onPressed: onPressesd,
      child: Icon(icon, size: 32, color: Colors.white),
    );
  }
}
