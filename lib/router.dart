import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_providers.dart';
import 'providers/profile_providers.dart';
import 'screens/chats_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/match_detail_screen.dart';
import 'screens/me_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/swaps_screen.dart';
import 'screens/swipe_screen.dart';
import 'widgets/root_shell.dart';

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(currentProfileProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  ref.keepAlive();
  final refresh = _RouterRefresh(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final loc = state.matchedLocation;
      const authPaths = {'/sign-in', '/sign-up'};

      if (auth.isLoading) {
        return loc == '/splash' ? null : '/splash';
      }
      final user = auth.value;
      if (user == null) {
        return authPaths.contains(loc) ? null : '/sign-in';
      }

      final profile = ref.read(currentProfileProvider);
      if (profile.isLoading) {
        return loc == '/splash' ? null : '/splash';
      }
      final p = profile.value;
      if (p == null) {
        return loc == '/profile-setup' ? null : '/profile-setup';
      }

      if (authPaths.contains(loc) ||
          loc == '/splash' ||
          loc == '/profile-setup' ||
          loc == '/home') {
        return '/discover';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (_, __) => const SignUpScreen()),
      GoRoute(
          path: '/profile-setup',
          builder: (_, __) => const ProfileSetupScreen()),
      GoRoute(
          path: '/profile-edit',
          builder: (_, __) => const ProfileEditScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(
        path: '/match/:matchId',
        builder: (_, state) => MatchDetailScreen(
          matchId: state.pathParameters['matchId']!,
        ),
      ),
      GoRoute(
        path: '/match/:matchId/chat',
        builder: (_, state) => ChatScreen(
          matchId: state.pathParameters['matchId']!,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => RootShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/me', builder: (_, __) => const MeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/discover',
              builder: (_, __) => const SwipeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/swaps', builder: (_, __) => const SwapsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/chats', builder: (_, __) => const ChatsScreen()),
          ]),
        ],
      ),
    ],
  );
});
