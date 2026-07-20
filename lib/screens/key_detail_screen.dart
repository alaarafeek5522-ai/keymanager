import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../models/key_model.dart';
import '../providers/key_provider.dart';
import '../theme/app_theme.dart';

class KeyDetailScreen extends StatelessWidget {
  final LicenseKey licenseKey;

  const KeyDetailScreen({super.key, required this.licenseKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      appBar: AppBar(
        title: Text(licenseKey.key),
        actions: [
          IconButton(
            icon: Icon(
              licenseKey.active ? Icons.block : Icons.check_circle,
              color: licenseKey.active ? AppTheme.accent : AppTheme.secondary,
            ),
            onPressed: () => _toggleKey(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _infoRow('Status', licenseKey.statusText, licenseKey.statusColor),
            const Divider(color: Colors.white24),
            _infoRow('Duration', '${licenseKey.duration} ${licenseKey.unit}'),
            const Divider(color: Colors.white24),
            _infoRow('Device ID', licenseKey.deviceId ?? 'Not registered'),
            const Divider(color: Colors.white24),
            _infoRow('Registered', licenseKey.registeredAt?.toString() ?? 'Never'),
            const Divider(color: Colors.white24),
            _infoRow('Expires', licenseKey.expiresAt?.toString() ?? 'Not set'),
            const Divider(color: Colors.white24),
            _infoRow('Remaining', licenseKey.expiryText,
                licenseKey.expiryText.contains('EXPIRED') ? AppTheme.accent : null),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _actionButton(
          'Reset Device',
          Icons.phonelink_erase,
          Colors.orange,
          () => _resetDevice(context),
        ),
        const SizedBox(height: 12),
        _actionButton(
          'Renew Key',
          Icons.update,
          AppTheme.secondary,
          () => _renewKey(context),
        ),
        const SizedBox(height: 12),
        _actionButton(
          'Delete Key',
          Icons.delete_forever,
          AppTheme.accent,
          () => _deleteKey(context),
        ),
      ],
    );
  }

  Widget _actionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _toggleKey(BuildContext context) async {
    await context.read<KeyProvider>().toggleKey(licenseKey.key, !licenseKey.active);
    Fluttertoast.showToast(msg: 'Key ${licenseKey.active ? 'blocked' : 'activated'}');
    if (context.mounted) Navigator.pop(context);
  }

  void _resetDevice(BuildContext context) async {
    await context.read<KeyProvider>().resetDevice(licenseKey.key);
    Fluttertoast.showToast(msg: 'Device reset');
  }

  void _renewKey(BuildContext context) async {
    await context.read<KeyProvider>().renewKey(licenseKey.key, 1, 'months');
    Fluttertoast.showToast(msg: 'Key renewed');
    if (context.mounted) Navigator.pop(context);
  }

  void _deleteKey(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Delete Key?'),
        content: Text('Are you sure you want to delete ${licenseKey.key}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () async {
              await context.read<KeyProvider>().deleteKey(licenseKey.key);
              Fluttertoast.showToast(msg: 'Key deleted');
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
