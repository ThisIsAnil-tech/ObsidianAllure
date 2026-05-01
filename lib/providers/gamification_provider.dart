import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gamification_profile.dart';
import '../repositories/hive_service.dart';

final gamificationProvider = StateNotifierProvider<GamificationNotifier, GamificationProfile>((ref) {
  return GamificationNotifier();
});

class GamificationNotifier extends StateNotifier<GamificationProfile> {
  GamificationNotifier() : super(HiveService.getGamificationProfile());

  void refresh() {
    state = HiveService.getGamificationProfile();
  }

  Future<void> addXP(int points) async {
    final profile = state;
    profile.xp += points;
    
    // Level up logic: every 100 XP is a new level
    int newLevel = (profile.xp ~/ 100) + 1;
    if (newLevel > profile.level) {
      profile.level = newLevel;
    }

    await profile.save();
    refresh();
  }

  Future<void> updateStreak() async {
    final profile = state;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (profile.lastCompletedDate == null) {
      profile.currentStreak = 1;
      profile.highestStreak = 1;
      profile.lastCompletedDate = today;
    } else {
      final lastDate = DateTime(profile.lastCompletedDate!.year, profile.lastCompletedDate!.month, profile.lastCompletedDate!.day);
      final difference = today.difference(lastDate).inDays;
      
      if (difference == 1) {
        profile.currentStreak += 1;
        if (profile.currentStreak > profile.highestStreak) {
          profile.highestStreak = profile.currentStreak;
        }
        profile.lastCompletedDate = today;
      } else if (difference > 1) {
        // Streak broken
        profile.currentStreak = 1;
        profile.lastCompletedDate = today;
      }
    }
    await profile.save();
    refresh();
  }
}
