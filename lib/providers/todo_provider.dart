import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_node.dart';
import '../repositories/hive_service.dart';

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<TodoNode>>((ref) {
  return TodoListNotifier();
});

class TodoListNotifier extends StateNotifier<List<TodoNode>> {
  TodoListNotifier() : super(HiveService.getRootNodes());

  void refresh() {
    state = HiveService.getRootNodes();
  }

  Future<void> addRootNode(TodoNode node) async {
    await HiveService.addRootNode(node);
    refresh();
  }

  Future<void> updateNode(TodoNode node) async {
    await HiveService.updateNode(node);
    // Note: To persist nested children correctly, we must save the root node that contains it.
    // However, Hive actually stores nested objects if they are just embedded, but to be safe, 
    // we should save the top-level HiveObject. 
    // Wait, in Hive, modifying a child of a HiveObject doesn't auto-save.
    // If 'node' is a root node, saving it saves the children.
    // If 'node' is a child, it's not a HiveObject itself (unless we store them flat). 
    // Wait, TodoNode IS a HiveObject. But we didn't put children in a Box, we just nested them.
    // When nested, we must save the root node. We will handle that by finding the root node and saving it.
    refresh();
  }

  Future<void> deleteRootNode(String id) async {
    await HiveService.deleteRootNode(id);
    refresh();
  }

  Future<void> saveRootNode(TodoNode rootNode) async {
    if (rootNode.isInBox) {
      await rootNode.save();
    } else {
      await HiveService.addRootNode(rootNode);
    }
    refresh();
  }

  Future<void> reorderNodes(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = state.removeAt(oldIndex);
    state.insert(newIndex, item);
    
    // Update order indexes
    for (int i = 0; i < state.length; i++) {
      state[i].orderIndex = i;
      if (state[i].isInBox) {
        await state[i].save();
      }
    }
    refresh();
  }
}
