import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import '../providers/theme_providers.dart';
import '../theme.dart';
import '../widgets/initials_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final profile = ref.watch(currentProfileProvider).value;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          tooltip: 'Back',
          onPressed: () => context.go('/me'),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        children: [
          if (profile != null) ...[
            const _SectionLabel('ACCOUNT'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: scheme.outline, width: 1),
              ),
              child: Row(
                children: [
                  InitialsAvatar(alias: profile.alias, radius: 26),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.alias,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.go('/profile-edit'),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          const _SectionLabel('APPEARANCE'),
          const SizedBox(height: AppSpacing.sm),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: mode,
            title: const Text('System'),
            subtitle: const Text('Match your device'),
            secondary: const Icon(Icons.brightness_auto_rounded),
            onChanged: (m) => _setMode(ref, m),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: mode,
            title: const Text('Light'),
            subtitle: const Text('Warm linen'),
            secondary: const Icon(Icons.light_mode_rounded),
            onChanged: (m) => _setMode(ref, m),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: mode,
            title: const Text('Dark'),
            subtitle: const Text('Cocoa night'),
            secondary: const Icon(Icons.dark_mode_rounded),
            onChanged: (m) => _setMode(ref, m),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('SESSION'),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            leading: Icon(Icons.logout_rounded, color: scheme.error),
            title: Text(
              'Sign out',
              style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              HapticFeedback.selectionClick();
              await ref.read(authServiceProvider).signOut();
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'Skill Swap · v1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _setMode(WidgetRef ref, ThemeMode? m) {
    if (m == null) return;
    HapticFeedback.selectionClick();
    ref.read(themeModeProvider.notifier).set(m);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
