import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lock_bloc.dart';
import '../bloc/lock_event.dart';
import '../bloc/lock_state.dart' as lock_bloc;
import 'pin_input_field.dart';
import 'biometry_button.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../router/router.dart';
import '../../../../main.dart';

import '../../settings/repositories/pin_service.dart';
import '../../settings/repositories/biometry_service.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget implements AutoRouteWrapper {
  final bool biometryEnabled;
  final VoidCallback? onUnlock;
  const LockScreen({Key? key, this.biometryEnabled = false, this.onUnlock})
    : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<LockBloc>(
      create: (_) => LockBloc(
        pinService: PinService(),
        biometryService: BiometryService(),
        biometryEnabled: biometryEnabled,
      ),
      child: this,
    );
  }
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  BiometricType? _biometryType;

  @override
  void initState() {
    super.initState();
    context.read<LockBloc>().add(LoadLock());
    if (widget.biometryEnabled) {
      _detectBiometryType();
      context.read<LockBloc>().add(const AuthenticateBiometry());
    }
  }

  Future<void> _detectBiometryType() async {
    final service = BiometryService();
    final types = await service.getAvailableBiometrics();
    if (types.contains(BiometricType.face)) {
      setState(() => _biometryType = BiometricType.face);
    } else if (types.contains(BiometricType.fingerprint)) {
      setState(() => _biometryType = BiometricType.fingerprint);
    } else if (types.contains(BiometricType.iris)) {
      setState(() => _biometryType = BiometricType.iris);
    } else {
      setState(() => _biometryType = null);
    }
  }

  void _onUnlock() {
    isAppUnlocked = true;
    widget.onUnlock?.call();
    context.router.replace(const HomeRoute());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LockBloc, lock_bloc.LockState>(
      listener: (context, state) {
        if (state is lock_bloc.LockUnlocked) {
          _onUnlock();
        } else if (state is lock_bloc.LockError) {
          setState(() => _error = state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is lock_bloc.LockLoading;
        final isLocked = state is lock_bloc.LockLocked;
        final showBiometry =
            isLocked && (state as lock_bloc.LockLocked).biometryEnabled;
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter PIN', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 16),
                  PinInputField(
                    controller: _controller,
                    errorText: _error,
                    onSubmitted: (pin) {
                      context.read<LockBloc>().add(EnterPin(pin));
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<LockBloc>().add(
                            EnterPin(_controller.text.trim()),
                          ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Unlock'),
                  ),
                  SizedBox(height: 16),
                  BiometryButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<LockBloc>().add(
                            const AuthenticateBiometry(),
                          ),
                    biometryType: _biometryType,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
