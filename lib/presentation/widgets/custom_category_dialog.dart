import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';

class CustomCategoryDialog extends StatefulWidget {
  final void Function(String name, String emoji) onCreate;
  final VoidCallback onCancel;
  final bool isIncome;
  const CustomCategoryDialog({
    Key? key,
    required this.onCreate,
    required this.onCancel,
    required this.isIncome,
  }) : super(key: key);

  @override
  State<CustomCategoryDialog> createState() => _CustomCategoryDialogState();
}

class _CustomCategoryDialogState extends State<CustomCategoryDialog> {
  late TextEditingController nameController;
  late TextEditingController emojiController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emojiController = TextEditingController(text: '💰');
  }

  @override
  void dispose() {
    nameController.dispose();
    emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).createCategory),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: S.of(context).categoryName,
              hintText: S.of(context).enterName,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: emojiController,
            decoration: InputDecoration(
              labelText: S.of(context).emoji,
              hintText: '💰',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              widget.onCreate(
                nameController.text,
                emojiController.text.isNotEmpty ? emojiController.text : '💰',
              );
            }
          },
          child: Text(S.of(context).create),
        ),
      ],
    );
  }
}
