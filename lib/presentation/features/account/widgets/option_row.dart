import 'package:flutter/material.dart';

class OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;
  final Widget? child;
  const OptionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            child ??
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ],
        ),
      ),
    );
  }
}
