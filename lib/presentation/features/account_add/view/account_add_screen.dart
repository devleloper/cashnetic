import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/account_add/bloc/account_add_bloc.dart';
import 'package:cashnetic/presentation/features/account_add/bloc/account_add_event.dart';
import 'package:cashnetic/presentation/features/account_add/bloc/account_add_state.dart';
import 'package:cashnetic/presentation/features/account_edit/widgets/balance_edit_row.dart';

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

  void _showCurrencyPicker(BuildContext context, String currentCurrency) async {
    final sel = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('₽ Российский рубль'),
            onTap: () => Navigator.pop(context, '₽'),
          ),
          ListTile(
            title: const Text(' Доллар'),
            onTap: () => Navigator.pop(context, ''),
          ),
          ListTile(
            title: const Text('€ Евро'),
            onTap: () => Navigator.pop(context, '€'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Отмена'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    if (sel != null && sel != currentCurrency) {
      context.read<AccountAddBloc>().add(AccountAddCurrencyChanged(sel));
    }
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
          return const Scaffold(
            body: Center(child: Text('Ошибка инициализации формы')),
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
            title: const Text('Создать счёт'),
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название счёта',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => context.read<AccountAddBloc>().add(
                    AccountAddNameChanged(v),
                  ),
                ),
              ),
              BalanceEditRow(controller: _balanceController),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _showCurrencyPicker(context, state.currency),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.currency_exchange, color: Colors.green),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Валюта', style: TextStyle(fontSize: 16)),
                      ),
                      Text(
                        state.currency,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onPressed: () {
                      context.read<AccountAddBloc>().add(AccountAddSubmitted());
                    },
                    child: const Text('Создать'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
