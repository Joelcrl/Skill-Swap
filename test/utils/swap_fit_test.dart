import 'package:flutter_test/flutter_test.dart';

import 'package:skill_swap/utils/swap_fit.dart';

void main() {
  group('swapFitPercent', () {
    test('is 100 when both sides can teach everything the other wants', () {
      expect(
        swapFitPercent(
          mySkillsOffered: ['Python'],
          mySkillsWanted: ['Guitar'],
          theirSkillsOffered: ['Guitar'],
          theirSkillsWanted: ['Python'],
        ),
        100,
      );
    });

    test('is 0 when nothing overlaps', () {
      expect(
        swapFitPercent(
          mySkillsOffered: ['Python'],
          mySkillsWanted: ['Guitar'],
          theirSkillsOffered: ['Drawing'],
          theirSkillsWanted: ['Cooking'],
        ),
        0,
      );
    });

    test('averages the two directions', () {
      // I can learn 1 of my 2 wanted skills from them (50%),
      // they can learn 1 of their 1 wanted skill from me (100%).
      expect(
        swapFitPercent(
          mySkillsOffered: ['Python'],
          mySkillsWanted: ['Guitar', 'Piano'],
          theirSkillsOffered: ['Guitar'],
          theirSkillsWanted: ['Python'],
        ),
        75,
      );
    });

    test('ignores case and surrounding whitespace', () {
      expect(
        swapFitPercent(
          mySkillsOffered: ['  python '],
          mySkillsWanted: ['GUITAR'],
          theirSkillsOffered: ['guitar'],
          theirSkillsWanted: ['Python'],
        ),
        100,
      );
    });

    test('returns 0 instead of dividing by zero for empty lists', () {
      expect(
        swapFitPercent(
          mySkillsOffered: const [],
          mySkillsWanted: const [],
          theirSkillsOffered: const [],
          theirSkillsWanted: const [],
        ),
        0,
      );
    });
  });
}
