import 'package:flutter/material.dart';
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
                                    userData.age != null || userData.location != null
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
                        if (userData.age != null || userData.location != null) ...[
                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          _ProfileRow(
                            icon: Icons.cake_rounded,
                            label: 'Age',
                            value: userData.age ?? '—',
                          ),
                          const SizedBox(height: 12),
                          _ProfileRow(
                            icon: Icons.location_on_rounded,
                            label: 'Location',
                            value: userData.location ?? '—',
                          ),
                        ],
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () => _showEditProfileDialog(context, userData),
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          label: Text(
                            userData.age != null || userData.location != null
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
                      'Your age and location are stored only on this device. Professor Owl does not send your data anywhere.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context, UserData userData) {
    final ageController = TextEditingController(text: userData.age ?? '');
    final locationController = TextEditingController(text: userData.location ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age (optional)',
                  hintText: 'e.g. 25',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  hintText: 'e.g. New York',
                ),
                textCapitalization: TextCapitalization.words,
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
                ageController.text.trim(),
                locationController.text.trim(),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
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
