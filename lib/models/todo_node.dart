import 'package:hive/hive.dart';

part 'todo_node.g.dart';

@HiveType(typeId: 5)
class TodoNode extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<TodoNode> children;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  int orderIndex;

  TodoNode({
    required this.id,
    required this.name,
    this.children = const [],
    this.isCompleted = false,
    this.notes,
    required this.createdAt,
    this.orderIndex = 0,
  });

  List<TodoNode> get leafNodes {
    if (children.isEmpty) return [this];
    List<TodoNode> leaves = [];
    for (var child in children) {
      leaves.addAll(child.leafNodes);
    }
    return leaves;
  }

  double get completionPercentage {
    if (children.isEmpty) return isCompleted ? 1.0 : 0.0;
    
    final leaves = leafNodes;
    if (leaves.isEmpty) return 0.0;
    
    int completedCount = leaves.where((node) => node.isCompleted).length;
    return completedCount / leaves.length;
  }

  bool get isFullyCompleted {
    return completionPercentage == 1.0;
  }
}
