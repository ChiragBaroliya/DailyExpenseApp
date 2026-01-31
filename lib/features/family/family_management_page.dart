import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/mock/mock_users.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/services/family_service.dart';
import '../../data/models/family_group.dart';

class FamilyManagementPage extends StatelessWidget {
  const FamilyManagementPage({super.key});

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite family member (mock)'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final email = emailController.text.trim();
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

  void _showCreateFamilyDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create family group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Family name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              Navigator.of(context).pop();
              if (name.isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final user = auth.currentUser;
              if (user == null) {
                messenger.showSnackBar(const SnackBar(content: Text('Not authenticated')));
                return;
              }
              final service = FamilyService();
              final req = FamilyGroupRequest(name: name, adminUserId: user.id, adminEmail: user.email);
              try {
                await service.createFamilyGroup(req);
                messenger.showSnackBar(const SnackBar(content: Text('Family group created')));
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Failed to create family: $e')));
              }
            },
            child: const Text('Create'),
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
        onPressed: () {
          // Offer both actions: invite member (mock) and create family group
          showModalBottomSheet<void>(
            context: context,
            builder: (context) => SafeArea(
              child: Wrap(children: [
                ListTile(leading: const Icon(Icons.person_add), title: const Text('Invite member'), onTap: () { Navigator.of(context).pop(); _showInviteDialog(context); }),
                ListTile(leading: const Icon(Icons.group_add), title: const Text('Create family group'), onTap: () { Navigator.of(context).pop(); _showCreateFamilyDialog(context); }),
              ]),
            ),
          );
        },
      ),
    );
  }
}
