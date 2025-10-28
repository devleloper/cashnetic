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
  String selectedEmoji = '💰';

  // Список популярных эмодзи для категорий (без повторений)
  static const List<String> popularEmojis = [
    // Деньги и финансы
    '💰', '💸', '💳', '💎', '🏦', '📈', '📊', '💵', '💴', '💶',
    // Дом и быт
    '🏠', '🏡', '🏢', '🏨', '🏥', '🏪', '🏬', '🏭', '🏗️', '🔧',
    // Еда и напитки
    '🍕', '🍔', '🌭', '🥪', '🌮', '🌯', '🍜', '🍝', '🍛', '🍚',
    '🍙', '🍣', '🍤', '🍥', '🍡', '🍢', '🍳', '🥞', '🧀', '🍖',
    '🐟', '🍰', '🍪', '🍫', '🍬', '🍭', '🍮', '🍯', '🥤', '☕',
    // Транспорт
    '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐',
    '🚚', '🚛', '🚜', '🏍️', '🛵', '🚲', '✈️', '🚁', '🚀', '⛽',
    // Покупки и шопинг
    '🛒', '🛍️', '💄', '👕', '👗', '👔', '👖', '👘', '👙', '👚',
    '👛', '👜', '🎒', '👞', '👟', '👠', '👡', '👢', '🎁', '🎀',
    // Развлечения и хобби
    '🎬', '🎭', '🎪', '🎨', '🎯', '🎮', '🕹️', '🎲', '🃏', '🎴',
    '🎵', '🎶', '🎤', '🎧', '🎸', '🎹', '🥁', '🎺', '🎷', '🎻',
    // Спорт и активность
    '🏋️', '🏃', '🚴', '🏊', '🏄', '🏇', '🏂', '⛷️', '🏌️', '🏓',
    '🏸', '🏒', '🏑', '🏏', '🎾', '🏐', '🏀', '⚽', '🏈', '🏉',
    // Работа и учеба
    '💼', '📊', '💡', '🔧', '🎓', '📚', '📖', '📝', '✏️', '✒️',
    '📏', '📐', '📌', '📍', '📎', '🔗', '💻', '📱', '⌨️', '🖥️',
    // Здоровье и медицина
    '💊', '💉', '🩺', '🏥', '🚑', '⚕️', '🧬', '🔬', '🔭', '🧪',
    // Природа и погода
    '🌞', '🌙', '⭐', '🌟', '☀️', '🌤️', '⛅', '🌦️', '🌧️', '⛈️',
    '🌩️', '❄️', '☃️', '⛄', '🌨️', '🌬️', '💨', '🌪️', '🌊', '🏔️',
    // Праздники и события
    '🎉', '🎊', '🎈', '🎂', '🍰', '🥳', '🎁', '🎀', '🏆', '🥇',
    '🥈', '🥉', '🏅', '🎖️', '🏵️', '🎗️', '🎫', '🎟️', '🎪', '🎭',
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).createCategory),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
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
            Text(
              S.of(context).emoji,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Показываем выбранный эмодзи
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                selectedEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            // Список эмодзи-кнопок
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: popularEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = popularEmojis[index];
                  final isSelected = emoji == selectedEmoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedEmoji = emoji;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
                selectedEmoji,
              );
            }
          },
          child: Text(S.of(context).create),
        ),
      ],
    );
  }
}
