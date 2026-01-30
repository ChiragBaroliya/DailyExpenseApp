import 'package:flutter/material.dart';
import '../../core/mock/mock_users.dart';

class FamilyManagementPage extends StatelessWidget {
  const FamilyManagementPage({super.key});

  void _showInviteDialog(BuildContext context) {
    final _emailController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite family member (mock)'),
        content: TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final email = _emailController.text.trim();
              Navigator.of(context).pop();
              if (email.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invitation sent to $email (mock)')));
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Management')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: mockUsers.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = mockUsers[index];
            final name = user['name'] as String? ?? 'Unknown';
            final email = user['email'] as String? ?? '';
            final role = user['role'] as String? ?? 'member';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(email),
                trailing: Chip(label: Text(role.toUpperCase())),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Invite'),
        onPressed: () => _showInviteDialog(context),
      ),
    );
  }
}
