
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/app_database.dart';
import 'package:drift/drift.dart' as drift;

class SettingGeneralTab extends StatefulWidget {
  const SettingGeneralTab({super.key});

  @override
  State<SettingGeneralTab> createState() => _SettingGeneralTabState();
}

class _SettingGeneralTabState extends State<SettingGeneralTab> {
  final _eurController = TextEditingController();
  final _usdController = TextEditingController();

  String _selectedLanguage = 'cs';
  String _selectedCurrency = 'czk';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dao = Provider.of<AppDatabase>(context, listen: false).settingsDao;
    final setting = await dao.getCurrentSettings();

    if (setting != null) {
      setState(() {
        _selectedLanguage = setting.language;
        _selectedCurrency = setting.currency;
        _eurController.text = setting.eurToCzk?.toString() ?? '';
        _usdController.text = setting.usdToCzk?.toString() ?? '';
      });
    }
  }

  Future<void> _saveSettings() async {
    final dao = Provider.of<AppDatabase>(context, listen: false).settingsDao;

    final eurRate = double.tryParse(_eurController.text);
    final usdRate = double.tryParse(_usdController.text);

    await dao.insertOrUpdateSettings(AppSettingsCompanion(
      language: drift.Value(_selectedLanguage),
      currency: drift.Value(_selectedCurrency),
      eurToCzk: drift.Value(eurRate),
      usdToCzk: drift.Value(usdRate),
    ));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cài đặt')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final vatDao = db.vatRateDao;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('Ngôn ngữ', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            items: const [
              DropdownMenuItem(value: 'cs', child: Text('Tiếng Séc')),
              DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('Tiền tệ', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            items: const [
              DropdownMenuItem(value: 'czk', child: Text('CZK (Kč)')),
              DropdownMenuItem(value: 'eur', child: Text('EUR (€)')),
              DropdownMenuItem(value: 'usd', child: Text('USD (\$)')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCurrency = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('Tỷ giá', style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _eurController,
            decoration: const InputDecoration(labelText: 'EUR → CZK'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _usdController,
            decoration: const InputDecoration(labelText: 'USD → CZK'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          const Text('Cấu hình VAT (%)', style: TextStyle(fontWeight: FontWeight.bold)),
          StreamBuilder<List<VatRate>>(
            stream: vatDao.watchAll(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final vatRates = snapshot.data!;
              return Column(
                children: [
                  for (final rate in vatRates)
                    ListTile(
                      title: Text('${rate.rate.toStringAsFixed(0)}%'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => vatDao.deleteRate(rate.id),
                      ),
                    ),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm mức VAT'),
                    onPressed: () async {
                      final newRate = await showDialog<double>(
                        context: context,
                        builder: (_) => const _AddVatRateDialog(),
                      );
                      if (newRate != null) {
                        await vatDao.insertOrUpdate(
                          VatRatesCompanion(rate: drift.Value(newRate)),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

class _AddVatRateDialog extends StatefulWidget {
  const _AddVatRateDialog();

  @override
  State<_AddVatRateDialog> createState() => _AddVatRateDialogState();
}

class _AddVatRateDialogState extends State<_AddVatRateDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm VAT mới'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Nhập VAT (VD: 15)'),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            final rate = double.tryParse(_controller.text.trim());
            if (rate != null) {
              Navigator.pop(context, rate);
            }
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
