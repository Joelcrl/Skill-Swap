import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import '../theme.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/primary_button.dart';
import '../widgets/tag_input.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  List<String> _skillsOffered = [];
  List<String> _skillsWanted = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _aliasController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skillsOffered.isEmpty) {
      setState(() => _error = 'Add at least one skill you can teach.');
      return;
    }
    if (_skillsWanted.isEmpty) {
      setState(() => _error = 'Add at least one skill you want to learn.');
      return;
    }
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final svc = ref.read(profileServiceProvider);
      await svc.createProfile(
        uid: user.uid,
        email: user.email ?? '',
        alias: _aliasController.text.trim(),
        skillsOffered: _skillsOffered,
        skillsWanted: _skillsWanted,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not save profile. Try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(authServiceProvider).signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Set up your profile'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _signOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.xxxl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero — alias preview that updates as they type.
                    Center(
                      child: Column(
                        children: [
                          InitialsAvatar(
                            alias: _aliasController.text.isEmpty
                                ? '?'
                                : _aliasController.text,
                            radius: 44,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _aliasController.text.trim().isEmpty
                                ? 'Pick an alias'
                                : _aliasController.text.trim(),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your avatar is built from your alias.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _SectionLabel('IDENTITY'),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _aliasController,
                      decoration: const InputDecoration(
                        labelText: 'Alias',
                        helperText: 'A handle, not your real name.',
                      ),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.length < 3) return 'At least 3 characters';
                        if (s.length > 24) return 'At most 24 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionLabel('YOU TEACH'),
                    const SizedBox(height: AppSpacing.sm),
                    TagInput(
                      label: 'Skills you can teach',
                      helperText: 'e.g. drawing, python, guitar',
                      tags: _skillsOffered,
                      onChanged: (v) => setState(() => _skillsOffered = v),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionLabel('YOU WANT TO LEARN'),
                    const SizedBox(height: AppSpacing.sm),
                    TagInput(
                      label: 'Skills you want to learn',
                      helperText: 'e.g. video editing, spanish',
                      tags: _skillsWanted,
                      onChanged: (v) => setState(() => _skillsWanted = v),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _ValidationOrErrorMessage(message: _error!),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: 'Continue',
                      loading: _loading,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _ValidationOrErrorMessage extends StatelessWidget {
  const _ValidationOrErrorMessage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
