import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../providers/key_provider.dart';
import '../theme/app_theme.dart';

class AddKeyScreen extends StatefulWidget {
  const AddKeyScreen({super.key});

  @override
  State<AddKeyScreen> createState() => _AddKeyScreenState();
}

class _AddKeyScreenState extends State<AddKeyScreen> {
  final _keyController = TextEditingController();
  final _durationController = TextEditingController(text: '1');
  String _unit = 'days';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      appBar: AppBar(title: const Text('Add Key')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _keyController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.text, // مش number
              decoration: InputDecoration(
                labelText: 'License Key',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'ABC-1234-5678',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Duration',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _unit,
                  isExpanded: true,
                  dropdownColor: AppTheme.cardDark,
                  style: const TextStyle(color: Colors.white),
                  items: ['hours', 'days', 'weeks', 'months']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _unit = v!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white, // ده بيخلي النص أبيض
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _addKey,
                child: const Text(
                  'ADD KEY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addKey() async {
    final key = _keyController.text.trim().toUpperCase();
    final duration = int.tryParse(_durationController.text) ?? 1;

    if (key.isEmpty) {
      _showMessage('Please enter a key');
      return;
    }

    try {
      await context.read<KeyProvider>().addKey(key, duration, _unit);
      if (mounted) {
        _showMessage('Key added successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _showMessage(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: AppTheme.cardDark,
      textColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
