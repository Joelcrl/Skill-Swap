import 'package:flutter_test/flutter_test.dart';

import 'package:skill_swap/models/match.dart';
import 'package:skill_swap/models/rating.dart';
import 'package:skill_swap/models/swipe.dart';

// These ids must stay in sync with the doc-id checks in firestore.rules.
void main() {
  group('Match.idFor', () {
    test('is the same regardless of argument order', () {
      expect(Match.idFor('bob', 'alice'), Match.idFor('alice', 'bob'));
      expect(Match.idFor('bob', 'alice'), 'alice_bob');
    });

    test('adds a round suffix from round 2 onwards', () {
      expect(Match.idFor('alice', 'bob', round: 1), 'alice_bob');
      expect(Match.idFor('alice', 'bob', round: 2), 'alice_bob_r2');
    });
  });

  group('Swipe.idFor', () {
    test('keeps swiper first, so each direction has its own doc', () {
      expect(Swipe.idFor('alice', 'bob'), 'alice_bob');
      expect(Swipe.idFor('bob', 'alice'), 'bob_alice');
    });

    test('adds a round suffix from round 2 onwards', () {
      expect(Swipe.idFor('alice', 'bob', round: 3), 'alice_bob_r3');
    });
  });

  group('Rating.idFor', () {
    test('is one doc per rater per match', () {
      expect(
        Rating.idFor(matchId: 'alice_bob', raterUid: 'alice'),
        'alice_bob_alice',
      );
    });
  });

  group('MatchState.parse', () {
    test('maps wire values and falls back to matched', () {
      expect(MatchState.parse('inProgress'), MatchState.inProgress);
      expect(MatchState.parse('completed'), MatchState.completed);
      expect(MatchState.parse(null), MatchState.matched);
      expect(MatchState.parse('garbage'), MatchState.matched);
    });
  });
}
