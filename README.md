# Skill Swap

Skill Swap is a Flutter app for trading skills instead of money. You list what you can teach and what you want to learn, swipe through other people, and when two people like each other they become a *swap*: each teaches the other, marks their turn done, and then both rate the exchange.

Built with Flutter and Firebase (Auth + Cloud Firestore). Runs on Android and the web.

## Features

- **Email/password accounts** with a short profile: alias, skills you teach, skills you want to learn.
- **Discover deck**: swipe right to swap, left to pass. Each card shows a **Swap Fit %** that estimates how well your skills and theirs complement each other.
- **Mutual matching**: a swap is created only when both people swipe right in the same round.
- **Swap lifecycle**: `matched → inProgress → completed`. Each person marks their own teaching turn as done; the swap completes when both have.
- **Match journey**: a five-step timeline on every swap (Matched, You, Them, Done, Rated).
- **Chat** inside every swap, plus a Chats inbox with the latest message per swap.
- **Ratings**: after a swap completes, each person rates the other once (1 to 5 stars and an optional note). Average ratings appear on profile cards.
- **Repeat swaps**: the same pair can swap again after a 7-day cooldown. Each repeat is a new round with its own match, chat and ratings.
- **Light, dark and system themes**, remembered between sessions.

## Swap Fit %

Swap Fit is the average of two directions of overlap, using case-insensitive exact matches on skill names:

```
iCanLearn   = |myWanted ∩ theirOffered| / |myWanted|
theyCanLearn = |theirWanted ∩ myOffered| / |theirWanted|
swapFit     = round((iCanLearn + theyCanLearn) / 2 × 100)
```

A score of 100% means everything each of you wants to learn is something the other can teach. See `lib/utils/swap_fit.dart`.

## Tech stack

| Area | Choice |
|---|---|
| UI | Flutter (Material 3), Plus Jakarta Sans via `google_fonts` |
| State | Riverpod 3 (`flutter_riverpod`) |
| Navigation | `go_router` with a `StatefulShellRoute` bottom-nav shell |
| Backend | Firebase Authentication, Cloud Firestore |
| Local storage | `shared_preferences` (theme mode) |
| Security | Firestore security rules (`firestore.rules`) |

## Architecture

The code is layered so screens never talk to Firebase directly:

```
screens / widgets  →  providers (Riverpod)  →  services  →  Firebase SDKs
                                         ↘  models (fromFirestore / toMap)
```

- **Services** (`lib/services/`) wrap Firestore and Auth: `AuthService`, `ProfileService`, `DiscoveryService`, `SwipeService`, `MatchService`, `ChatService`, `RatingService`.
- **Providers** (`lib/providers/`) expose services and live streams to the UI.
- **Router** (`lib/router.dart`) redirects based on auth and profile state:

```
auth loading            → /splash
signed out              → /sign-in (or /sign-up)
signed in, no profile   → /profile-setup
signed in, has profile  → /discover (bottom nav: Me, Discover, Swaps, Chats)
```

## Data model (Firestore)

| Collection | Document ID | Key fields |
|---|---|---|
| `users` | `{uid}` | `alias`, `email`, `skillsOffered`, `skillsWanted`, `createdAt` |
| `swipes` | `{swiperUid}_{swipedUid}` (round 1), `…_r{N}` (round N) | `swiperUid`, `swipedUid`, `direction` (`like`/`pass`), `roundNumber` |
| `matches` | `{sortedUidA}_{sortedUidB}` (round 1), `…_r{N}` | `userIds`, `state`, `turnsCompleted`, `roundNumber`, `createdAt`, `updatedAt` |
| `matches/{id}/messages` | auto | `senderUid`, `text` (max 2000 chars), `createdAt` |
| `ratings` | `{matchId}_{raterUid}` | `matchId`, `raterUid`, `ratedUid`, `stars` (1 to 5), `note` (max 500 chars) |

Deterministic IDs (sorted UID pairs, `matchId_raterUid`) prevent duplicate matches and double ratings.

## Security rules highlights

`firestore.rules` enforces, among other things:

- Users can only create and edit their own profile, and can never change `rating`, `ratingCount`, `trustBadges`, `activeMatchId`, `email` or `createdAt`.
- Swipes are append-only and must be written as yourself.
- A swap can only be created when both people have liked each other in the same round.
- Match state can only move forward one turn at a time, and each user can mark only their own turn.
- Only the two members of a swap can read or send its messages; messages cannot be edited or deleted.
- Ratings require a completed swap you are part of, and you cannot rate yourself.


The Firebase config in `lib/firebase_options.dart` and `android/app/google-services.json` is not a secret. It only identifies the Firebase project; what anyone can read or write is decided by `firestore.rules`.

## Getting started

This repo is already connected to the Firebase project `skill-swap-ebe85`. If you have access to that project you can skip step 3.

### 1. Install the tools

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart 3.11 or newer). Check with `flutter doctor`.
- A browser (Chrome or Edge) for the web build, and/or Android Studio with an emulator for Android.
- Node.js, then the Firebase CLI: `npm install -g firebase-tools`

### 2. Get the code and dependencies

```bash
git clone <this-repo-url>
cd <repo-folder>
flutter pub get
```

### 3. (Only for your own Firebase project) Connect Firebase

1. In the [Firebase console](https://console.firebase.google.com), create a project and enable **Authentication → Email/Password** and **Cloud Firestore**.
2. Point the app at it:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --platforms=android,web
   firebase use --add
   ```

   This regenerates `lib/firebase_options.dart` and `android/app/google-services.json`, and updates `.firebaserc`.

### 4. Deploy the security rules and index

```bash
firebase login
firebase deploy --only firestore
```

Run this again whenever `firestore.rules` or `firestore.indexes.json` changes.

### 5. Run the app

```bash
flutter run -d chrome     # web (use -d edge for Microsoft Edge)
flutter run               # pick a connected Android emulator or device
```

While it runs, press `r` for hot reload, `R` for hot restart and `q` to quit.

### Try it out

1. Sign up with any email and a password of at least 6 characters, then set up your profile.
2. Open a second window in incognito/private mode and sign up as a second user.
3. Swipe right on each other: a swap appears under **Swaps**, and you can chat under **Chats**.
4. Mark your turn done on both accounts, then rate each other.

To test repeat swaps without waiting a week, temporarily lower `kReSwapCooldown` in `lib/services/swipe_service.dart`, for example to `Duration(minutes: 1)`.

## Tests

```bash
flutter analyze
flutter test
```

Unit tests cover the Swap Fit calculation, the document-id helpers that must match `firestore.rules`, and the friendly error messages.

## Deploy the web app (optional)

Firebase Hosting is already configured in `firebase.json`:

```bash
flutter build web
firebase deploy --only hosting
```

The app is then live at `https://skill-swap-ebe85.web.app`.

## Build an Android APK (optional)

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. It is signed with the debug key, which is fine for sharing with testers but not for the Play Store.

## Project structure

```
lib/
  main.dart              Firebase init, SharedPreferences, ProviderScope
  app.dart               MaterialApp.router with light/dark themes
  router.dart            go_router routes and auth/profile redirects
  theme.dart             Colors, spacing, radii, light and dark ThemeData
  models/                UserProfile, Swipe, Match, Message, Rating
  services/              Firebase access (auth, profile, discovery, swipe, match, chat, rating)
  providers/             Riverpod providers for services and live data
  screens/               Sign in/up, profile setup/edit, discover, swaps, match detail, chats, chat, me, settings
  widgets/               Profile card, match journey, swap fit badge, tag input, rating badge, shared states
  utils/                 Swap Fit calculation, friendly error messages
test/                    Unit tests
firestore.rules          Firestore security rules
firestore.indexes.json   Composite index for the swaps list
firebase.json            Firebase CLI config (Firestore + Hosting)
```

## Known limitations

- Rating averages are computed on the client from the `ratings` collection; there are no Cloud Functions yet.
- The 7-day re-swap cooldown is checked in the app, not enforced by security rules.
- Any signed-in user can read other users' profile documents, including their email.
- Bio, interests and profile pictures exist in the data model but are not yet shown or editable in the UI. Avatars use initials.
- The Discover deck loads the 50 most recent users per refresh.
- Swap Fit uses exact skill-name matching, so "Python" and "Python programming" do not count as a match.
#   S k i l l - S w a p  
 