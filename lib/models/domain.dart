import 'package:hive/hive.dart';
import 'subtopic.dart';

part 'domain.g.dart';

@HiveType(typeId: 1)
class DomainModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Subtopic> subtopics;

  @HiveField(3)
  int colorIndex;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  int orderIndex;

  DomainModel({
    required this.id,
    required this.name,
    required this.subtopics,
    required this.createdAt,
    this.colorIndex = 0,
    this.orderIndex = 0,
  });

  bool get isCompleted => subtopics.isNotEmpty && subtopics.every((st) => st.isCompleted);
  double get completionPercentage => subtopics.isEmpty ? 0.0 : (subtopics.where((st) => st.isCompleted).length / subtopics.length);
}
