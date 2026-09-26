import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import '../theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/primary_button.dart';
import '../widgets/tag_input.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _aliasController;
  List<String> _skillsOffered = [];
  List<String> _skillsWanted = [];
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController();
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
      await svc.updateProfile(
        uid: user.uid,
        alias: _aliasController.text.trim(),
        skillsOffered: _skillsOffered,
        skillsWanted: _skillsWanted,
      );
      if (mounted) context.go('/me');
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not save changes. Try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    return profileAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Edit profile')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: SkeletonAvatar(radius: 64)),
              SizedBox(height: 24),
              SkeletonBox(height: 56),
              SizedBox(height: 24),
              SkeletonBox(height: 80),
              SizedBox(height: 24),
              SkeletonBox(height: 80),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit profile')),
        body: AppErrorView(
          error: e,
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit profile')),
            body: const AppEmptyState(
              icon: Icons.person_off_outlined,
              title: 'No profile yet',
              body: "We can't find your profile. Try signing out and back in.",
            ),
          );
        }
        if (!_initialized) {
          _aliasController.text = profile.alias;
          _skillsOffered = List<String>.from(profile.skillsOffered);
          _skillsWanted = List<String>.from(profile.skillsWanted);
          _initialized = true;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit profile'),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Close',
              onPressed: _loading ? null : () => context.go('/me'),
            ),
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
                        Center(
                          child: Column(
                            children: [
                              InitialsAvatar(
                                alias: _aliasController.text,
                                radius: 44,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _aliasController.text.trim().isEmpty
                                    ? '—'
                                    : _aliasController.text.trim(),
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
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
                          label: 'Save',
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
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
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
