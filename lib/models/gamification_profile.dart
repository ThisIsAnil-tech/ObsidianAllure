import 'package:hive/hive.dart';

part 'gamification_profile.g.dart';

@HiveType(typeId: 4)
class GamificationProfile extends HiveObject {
  @HiveField(0)
  int xp;

  @HiveField(1)
  int level;

  @HiveField(2)
  int currentStreak;

  @HiveField(3)
  int highestStreak;

  @HiveField(4)
  DateTime? lastCompletedDate;

  GamificationProfile({
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.highestStreak = 0,
    this.lastCompletedDate,
  });
}
