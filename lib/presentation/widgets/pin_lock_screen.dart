import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/settings/bloc/settings_bloc.dart';
import '../features/settings/bloc/settings_event.dart';
import '../features/settings/bloc/settings_state.dart';

class PinLockScreen extends StatefulWidget {
  final bool showBiometry;
  final VoidCallback? onUnlock;
  const PinLockScreen({Key? key, this.showBiometry = true, this.onUnlock})
    : super(key: key);

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  bool _biometryFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget.showBiometry) {
      _tryBiometry();
    }
  }

  void _tryBiometry() async {
    context.read<SettingsBloc>().add(
      AuthenticateBiometry(reason: 'Unlock with biometrics'),
    );
    // В реальном приложении слушать состояние Bloc и реагировать на успех/ошибку
  }

  void _checkPin() async {
    final pin = _controller.text.trim();
    if (pin.length != 4) {
      setState(() => _error = 'Enter 4 digits');
      return;
    }
    context.read<SettingsBloc>().add(CheckPin(pin));
    // В реальном приложении слушать состояние Bloc и реагировать на успех/ошибку
    // Здесь для примера просто вызываем onUnlock
    widget.onUnlock?.call();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsError) {
          setState(() => _error = state.message);
        }
        // Здесь можно добавить обработку успешной аутентификации
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                final showBiometry =
                    state is SettingsLoaded && state.biometryEnabled;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Enter PIN', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        errorText: _error,
                        counterText: '',
                      ),
                      onChanged: (_) => setState(() => _error = null),
                      onSubmitted: (_) => _checkPin(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkPin,
                      child: const Text('Unlock'),
                    ),
                    if (showBiometry)
                      IconButton(
                        icon: const Icon(Icons.fingerprint, size: 36),
                        onPressed: _tryBiometry,
                        tooltip: 'Use biometrics',
                      ),
                    if (_biometryFailed)
                      const Text(
                        'Biometric authentication failed',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
