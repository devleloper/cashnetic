// pin_screen.dart
import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pin_bloc.dart';
import '../bloc/pin_event.dart';
import '../bloc/pin_state.dart';
import '../widgets/pin_input_field.dart';
import '../repositories/pin_repository.dart';

enum PinScreenMode { set, edit, check }

class PinScreen extends StatefulWidget {
  final PinScreenMode mode;
  const PinScreen({super.key, required this.mode});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PinBloc(pinRepository: PinRepositoryImpl())..add(LoadPin()),
      child: BlocConsumer<PinBloc, PinState>(
        listener: (context, state) {
          if (state is PinError) {
            setState(() => _error = state.message);
          } else if (state is PinSet && widget.mode != PinScreenMode.check) {
            // Показываем SnackBar, но не закрываем экран автоматически
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(S.of(context).pinSetSuccessfully)),
            );
          } else if (state is PinChecked) {
            if (state.isValid) {
              Navigator.pop(context, true);
            } else {
              setState(() => _error = S.of(context).invalidPin);
            }
          } else if (state is PinNotSet && widget.mode == PinScreenMode.edit) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(S.of(context).pinDeleted)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PinLoading;
          return Scaffold(
            appBar: AppBar(
              title: Text(_getTitle()),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PinInputField(
                      controller: _controller,
                      enabled: !isLoading,
                      errorText: _error,
                      onSubmitted: (_) => _onAction(context),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _onAction(context),
                      child: Text(_getButtonText()),
                    ),
                    // Кнопка удаления PIN появляется, если PIN установлен (PinSet) или в режиме edit и PIN ещё не удалён
                    if ((state is PinSet || (widget.mode == PinScreenMode.edit && state is! PinNotSet)) && !isLoading)
                      TextButton(
                        onPressed: () => context.read<PinBloc>().add(DeletePin()),
                        child:  Text(S.of(context).deletePin),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getTitle() {
    switch (widget.mode) {
      case PinScreenMode.set:
        return S.of(context).setPin;
      case PinScreenMode.edit:
        return S.of(context).editPin;
      case PinScreenMode.check:
        return S.of(context).enterPin;
    }
  }

  String _getButtonText() {
    switch (widget.mode) {
      case PinScreenMode.set:
        return S.of(context).set;
      case PinScreenMode.edit:
        return S.of(context).save;
      case PinScreenMode.check:
        return S.of(context).check;
    }
  }

  void _onAction(BuildContext context) {
    final pin = _controller.text.trim();
    if (pin.length != 4) {
      setState(() => _error = S.of(context).pinMustBe4Digits);
      return;
    }
    final bloc = context.read<PinBloc>();
    switch (widget.mode) {
      case PinScreenMode.set:
      case PinScreenMode.edit:
        bloc.add(SetPin(pin));
        break;
      case PinScreenMode.check:
        bloc.add(CheckPin(pin));
        break;
    }
  }
} 