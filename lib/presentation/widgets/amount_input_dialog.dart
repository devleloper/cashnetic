import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AmountInputDialog extends StatelessWidget {
  final String currentAmount;
  final ValueChanged<String> onSubmit;
  const AmountInputDialog({
    Key? key,
    required this.currentAmount,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: currentAmount);
    final locale = Localizations.localeOf(context).toString();
    final separator = NumberFormat.simpleCurrency(
      locale: locale,
    ).symbols.DECIMAL_SEP;
    return AlertDialog(
      title: Text(S.of(context).enterAmount),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp('[0-9${separator == '.' ? '\\.' : ','}]'),
          ),
          _SingleDecimalSeparatorInputFormatter(separator),
        ],
        autofocus: true,
        decoration: InputDecoration(hintText: '0${separator}00'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onSubmit(controller.text);
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Formatter: only one decimal separator allowed
class _SingleDecimalSeparatorInputFormatter extends TextInputFormatter {
  final String separator;
  _SingleDecimalSeparatorInputFormatter(this.separator);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final firstIndex = text.indexOf(separator);
    if (firstIndex == -1) return newValue;
    // Only one separator allowed
    final lastIndex = text.lastIndexOf(separator);
    if (firstIndex != lastIndex) {
      return oldValue;
    }
    return newValue;
  }
}
