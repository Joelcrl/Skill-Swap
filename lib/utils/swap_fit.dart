import 'dart:math';

int swapFitPercent({
  required List<String> mySkillsOffered,
  required List<String> mySkillsWanted,
  required List<String> theirSkillsOffered,
  required List<String> theirSkillsWanted,
}) {
  final myW = mySkillsWanted.map(_norm).where((s) => s.isNotEmpty).toSet();
  final myT = mySkillsOffered.map(_norm).where((s) => s.isNotEmpty).toSet();
  final thW = theirSkillsWanted.map(_norm).where((s) => s.isNotEmpty).toSet();
  final thT = theirSkillsOffered.map(_norm).where((s) => s.isNotEmpty).toSet();

  final iCanLearnFromThem = myW.intersection(thT).length / max(1, myW.length);
  final theyCanLearnFromMe = thW.intersection(myT).length / max(1, thW.length);

  return (((iCanLearnFromThem + theyCanLearnFromMe) / 2) * 100).round();
}

String _norm(String s) => s.trim().toLowerCase();
