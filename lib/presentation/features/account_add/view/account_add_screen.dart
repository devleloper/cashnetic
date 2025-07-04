import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/account_add/bloc/account_add_bloc.dart';
import 'package:cashnetic/presentation/features/account_add/bloc/account_add_event.dart';
import 'package:cashnetic/presentation/features/account_add/bloc/account_add_state.dart';
import '../widgets/account_name_field.dart';
import '../widgets/account_balance_field.dart';
import '../widgets/account_currency_picker.dart';
import '../widgets/account_add_submit_button.dart';

class AccountAddScreen extends StatefulWidget {
  const AccountAddScreen({super.key});

  @override
  State<AccountAddScreen> createState() => _AccountAddScreenState();
}

class _AccountAddScreenState extends State<AccountAddScreen> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _balanceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountAddBloc, AccountAddState>(
      listener: (context, state) {
        if (state is AccountAddSuccess) {
          Navigator.pop(context, true);
        } else if (state is AccountAddError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is AccountAddLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is! AccountAddLoaded) {
          return Scaffold(
            body: Center(child: Text(S.of(context).formInitializationError)),
          );
        }
        _nameController.value = TextEditingValue(
          text: state.name,
          selection: TextSelection.collapsed(offset: state.name.length),
        );
        _balanceController.value = TextEditingValue(
          text: state.balance,
          selection: TextSelection.collapsed(offset: state.balance.length),
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).createAccount),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: () {
                  context.read<AccountAddBloc>().add(AccountAddSubmitted());
                },
              ),
            ],
          ),
          body: Column(
            children: [
              AccountNameField(
                controller: _nameController,
                onChanged: (v) => context.read<AccountAddBloc>().add(
                  AccountAddNameChanged(v),
                ),
              ),
              AccountBalanceField(
                controller: _balanceController,
                onChanged: (v) => context.read<AccountAddBloc>().add(
                  AccountAddBalanceChanged(v),
                ),
              ),
              const SizedBox(height: 16),
              AccountCurrencyPicker(
                currency: state.currency,
                onChanged: (val) => context.read<AccountAddBloc>().add(
                  AccountAddCurrencyChanged(val),
                ),
              ),
              const Spacer(),
              AccountAddSubmitButton(
                onPressed: () {
                  context.read<AccountAddBloc>().add(AccountAddSubmitted());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
