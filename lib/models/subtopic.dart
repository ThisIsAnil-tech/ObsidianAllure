import 'package:hive/hive.dart';
import 'topic.dart';

part 'subtopic.g.dart';

@HiveType(typeId: 2)
class Subtopic extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Topic> topics;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  int orderIndex;

  Subtopic({
    required this.id,
    required this.name,
    required this.topics,
    required this.createdAt,
    this.orderIndex = 0,
  });

  bool get isCompleted => topics.isNotEmpty && topics.every((t) => t.isCompleted);
  double get completionPercentage => topics.isEmpty ? 0.0 : (topics.where((t) => t.isCompleted).length / topics.length);
}
