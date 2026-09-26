import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme.dart';
import 'initials_avatar.dart';
import 'rating_badge.dart';
import 'swap_chips.dart';
import 'swap_fit_badge.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile, this.swapFit});

  final UserProfile profile;
  final int? swapFit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        // Block-shadow offset — hard, no blur. Reads as a designed object,
        // not a floating Material card.
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.10),
            blurRadius: 0,
            offset: const Offset(4, 6),
          ),
        ],
        border: Border.all(color: scheme.onSurface, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(AppRadii.xxl - 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxl,
                      AppSpacing.xxxl,
                      AppSpacing.xxl,
                      AppSpacing.xxl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primaryContainer,
                        scheme.secondaryContainer,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'MEMBER',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: scheme.onPrimaryContainer
                                  .withValues(alpha: 0.7),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      InitialsAvatar(alias: profile.alias, radius: 52),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        profile.alias,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      RatingBadge(uid: profile.uid),
                    ],
                  ),
                ),
                if (swapFit != null)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: SwapFitBadge(value: swapFit!),
                  ),
              ],
            ),
            // Hard divider — no shadow, just a line. Editorial separation.
            Container(
              height: 1.5,
              color: scheme.onSurface,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xxl),
              child: SwapChips(
                offered: profile.skillsOffered,
                wanted: profile.skillsWanted,
                offeredLabel: 'TEACHES',
                wantedLabel: 'WANTS TO LEARN',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
