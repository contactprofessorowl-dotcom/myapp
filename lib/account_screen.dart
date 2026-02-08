import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(
            'Account',
            style: theme.appBarTheme.titleTextStyle,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Consumer<UserData>(
                builder: (context, userData, _) {
                  return _AccountCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 40,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your profile',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userData.name != null || userData.age != null || userData.expertiseLevel != null
                                        ? 'Tap below to edit'
                                        : 'Add your details (optional)',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (userData.name != null || userData.age != null || userData.expertiseLevel != null) ...[
                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          _ProfileRow(
                            icon: Icons.person_rounded,
                            label: 'Name',
                            value: userData.name ?? '—',
                          ),
                          if (userData.age != null && userData.age!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _ProfileRow(
                              icon: Icons.cake_rounded,
                              label: 'Age',
                              value: userData.age ?? '—',
                            ),
                          ],
                          const SizedBox(height: 12),
                          _ProfileRow(
                            icon: Icons.school_rounded,
                            label: 'Expertise level',
                            value: _expertiseLabel(userData.expertiseLevel ?? 'intermediate'),
                          ),
                        ],
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () => _showEditProfileDialog(context, userData),
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          label: Text(
                            userData.name != null || userData.age != null || userData.expertiseLevel != null
                                ? 'Edit profile'
                                : 'Add profile details',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _AccountCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About your data',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your name and age are stored only on this device. Flash does not send your data anywhere.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _LogoutSection(),
            ]),
          ),
        ),
      ],
    );
  }

  static String _expertiseLabel(String level) {
    switch (level) {
      case 'beginner':
        return 'Beginner';
      case 'advanced':
        return 'Advanced';
      default:
        return 'Intermediate';
    }
  }

  void _showEditProfileDialog(BuildContext context, UserData userData) {
    final nameController = TextEditingController(text: userData.name ?? '');
    final ageController = TextEditingController(text: userData.age ?? '');
    String expertise = userData.expertiseLevel ?? 'intermediate';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    hintText: 'e.g. Alex',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age (optional)',
                    hintText: 'e.g. 25',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: expertise,
                  decoration: const InputDecoration(
                    labelText: 'Expertise level',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  ],
                  onChanged: (v) => setDialogState(() => expertise = v ?? 'intermediate'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                userData.setUserData(
                  nameController.text.trim(),
                  ageController.text.trim(),
                  expertise,
                );
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = Provider.of<UserData>(context);

    return _AccountCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log out',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clear your profile data and sign out.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, userData),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('Log out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, UserData userData) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Your profile data (name, age) will be cleared. You will need to enter them again next time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              userData.clearUserData();
              Navigator.of(ctx).pop();
              context.go('/welcome');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
