import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_node.dart';
import '../models/gamification_profile.dart';

class HiveService {
  static const String todoBoxName = 'todo_nodes';
  static const String gamificationBoxName = 'gamification';

  static late Box<TodoNode> todoBox;
  static late Box<GamificationProfile> gamificationBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Clear old boxes if we are migrating (this will lose old data, but user approved)
    // await Hive.deleteBoxFromDisk('domains'); // Optional: cleanup old data

    // Register Adapters
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(GamificationProfileAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(TodoNodeAdapter());

    // Open Boxes
    todoBox = await Hive.openBox<TodoNode>(todoBoxName);
    gamificationBox = await Hive.openBox<GamificationProfile>(gamificationBoxName);

    // Initialize Gamification profile if empty
    if (gamificationBox.isEmpty) {
      await gamificationBox.put('profile', GamificationProfile());
    }
  }

  // Root Node CRUD
  static List<TodoNode> getRootNodes() {
    final nodes = todoBox.values.toList();
    nodes.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return nodes;
  }
  
  static Future<void> addRootNode(TodoNode node) => todoBox.put(node.id, node);
  
  static Future<void> updateNode(TodoNode node) {
    if (node.isInBox) {
      return node.save();
    }
    return Future.value();
  }
  
  static Future<void> deleteRootNode(String id) => todoBox.delete(id);

  static Future<void> clearAll() => todoBox.clear();

  // Gamification Profile
  static GamificationProfile getGamificationProfile() {
    return gamificationBox.get('profile')!;
  }
  
  static Future<void> updateGamificationProfile(GamificationProfile profile) {
    return profile.save();
  }
}
