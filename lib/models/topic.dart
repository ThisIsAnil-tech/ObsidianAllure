import 'package:hive/hive.dart';

part 'topic.g.dart';

@HiveType(typeId: 3)
class Topic extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  int orderIndex;

  @HiveField(7, defaultValue: false)
  bool isPinned;

  Topic({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.notes,
    this.dueDate,
    required this.createdAt,
    this.orderIndex = 0,
    this.isPinned = false,
  });
}
