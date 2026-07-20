import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/key_provider.dart';
import '../theme/app_theme.dart';
import 'add_key_screen.dart';
import 'key_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<KeyProvider>().loadKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      appBar: AppBar(
        title: const Text('KeyManager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<KeyProvider>().loadKeys(),
          ),
        ],
      ),
      body: Consumer<KeyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return _buildShimmer();
          if (provider.error != null) return _buildError(provider.error!);

          return Column(
            children: [
              _buildStats(provider),
              Expanded(child: _buildKeyList(provider)),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'bulk',
            backgroundColor: AppTheme.secondary,
            onPressed: () => _showBulkDialog(context),
            child: const Icon(Icons.auto_fix_high),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddKeyScreen()),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(KeyProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF8B80FF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total', provider.totalCount.toString()),
          _statItem('Active', provider.activeCount.toString()),
          _statItem('Inactive',
              (provider.totalCount - provider.activeCount).toString()),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildKeyList(KeyProvider provider) {
    final keys = provider.keys;
    if (keys.isEmpty) {
      return const Center(
        child: Text('No keys found', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: key.statusColor.withOpacity(0.2),
              child: Icon(Icons.vpn_key, color: key.statusColor),
            ),
            title: Text(key.key,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${key.duration} ${key.unit} | ${key.expiryText}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: key.statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                key.statusText,
                style: TextStyle(
                  color: key.statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KeyDetailScreen(licenseKey: key),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideX();
      },
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.cardDark,
      highlightColor: AppTheme.dark.withOpacity(0.5),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.all(16),
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.accent, size: 60),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<KeyProvider>().loadKeys(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showBulkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Generate Bulk Keys'),
        content: const Text(
            'This will generate 90 keys:\n• 30 Monthly\n• 30 Weekly\n• 30 Daily\n\nContinue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () {
              context.read<KeyProvider>().generateBulkKeys();
              Navigator.pop(context);
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}
