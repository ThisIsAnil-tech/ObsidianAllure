import 'package:hive_flutter/hive_flutter.dart';
import '../models/domain.dart';
import '../models/subtopic.dart';
import '../models/topic.dart';
import '../models/gamification_profile.dart';

class HiveService {
  static const String domainBoxName = 'domains';
  static const String gamificationBoxName = 'gamification';

  static late Box<DomainModel> domainBox;
  static late Box<GamificationProfile> gamificationBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DomainModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SubtopicAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(TopicAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(GamificationProfileAdapter());

    // Open Boxes
    domainBox = await Hive.openBox<DomainModel>(domainBoxName);
    gamificationBox = await Hive.openBox<GamificationProfile>(gamificationBoxName);

    // Initialize Gamification profile if empty
    if (gamificationBox.isEmpty) {
      await gamificationBox.put('profile', GamificationProfile());
    }
  }

  // Domain CRUD
  static List<DomainModel> getDomains() {
    final domains = domainBox.values.toList();
    domains.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return domains;
  }
  
  static Future<void> addDomain(DomainModel domain) => domainBox.put(domain.id, domain);
  
  static Future<void> updateDomain(DomainModel domain) => domain.save();
  
  static Future<void> deleteDomain(String id) => domainBox.delete(id);

  // Gamification Profile
  static GamificationProfile getGamificationProfile() {
    return gamificationBox.get('profile')!;
  }
  
  static Future<void> updateGamificationProfile(GamificationProfile profile) {
    return profile.save();
  }
}
