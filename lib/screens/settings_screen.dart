import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Appearance Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Dark Mode Toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.blue,
                  ),
                ),
              );
            },
          ),
          
          const Divider(),
          
          // Currency Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Currency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.attach_money, color: Colors.green),
            ),
            title: const Text('Currency'),
            subtitle: const Text('Indian Rupee (₹)'),
            onTap: () {
              // Show currency selection dialog
            },
          ),
          
          const Divider(),
          
          // Data Management Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.backup, color: Colors.orange),
            ),
            title: const Text('Backup Data'),
            subtitle: const Text('Export your expenses'),
            onTap: () {
              // Implement backup functionality
            },
          ),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restore, color: Colors.red),
            ),
            title: const Text('Restore Data'),
            subtitle: const Text('Import from backup'),
            onTap: () {
              // Implement restore functionality
            },
          ),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_sweep, color: Colors.purple),
            ),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all expenses'),
            onTap: () {
              _showClearDataDialog(context);
            },
          ),
          
          const Divider(),
          
          // About Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info, color: Colors.teal),
            ),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all expenses? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement clear all data functionality
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}