import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_node.dart';
import '../providers/todo_provider.dart';
import '../providers/gamification_provider.dart';
import 'sidebar.dart';
import 'search_screen.dart';
import 'activity_screen.dart';

class NodeListScreen extends ConsumerStatefulWidget {
  final TodoNode? parentNode;
  final TodoNode? rootNode;

  const NodeListScreen({super.key, this.parentNode, this.rootNode});

  @override
  ConsumerState<NodeListScreen> createState() => _NodeListScreenState();
}

class _NodeListScreenState extends ConsumerState<NodeListScreen> {
  void _addNode() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        return AlertDialog(
          title: const Text('Add Item'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter name'),
            onChanged: (val) => name = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.trim().isNotEmpty) {
                  final newNode = TodoNode(
                    id: const Uuid().v4(),
                    name: name.trim(),
                    createdAt: DateTime.now(),
                  );
                  if (widget.parentNode == null) {
                    ref.read(todoListProvider.notifier).addRootNode(newNode);
                  } else {
                    setState(() {
                      widget.parentNode!.children.add(newNode);
                    });
                    ref.read(todoListProvider.notifier).saveRootNode(widget.rootNode!);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNode(TodoNode node) {
    if (widget.parentNode == null) {
      ref.read(todoListProvider.notifier).deleteRootNode(node.id);
    } else {
      setState(() {
        widget.parentNode!.children.removeWhere((n) => n.id == node.id);
      });
      ref.read(todoListProvider.notifier).saveRootNode(widget.rootNode!);
    }
  }

  void _editNodeName(TodoNode node) {
    showDialog(
      context: context,
      builder: (context) {
        String name = node.name;
        return AlertDialog(
          title: const Text('Edit Item'),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: name),
            decoration: const InputDecoration(hintText: 'Enter new name'),
            onChanged: (val) => name = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.trim().isNotEmpty) {
                  setState(() {
                    node.name = name.trim();
                  });
                  ref.read(todoListProvider.notifier).saveRootNode(widget.rootNode ?? node);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editNotes(TodoNode node) {
    showDialog(
      context: context,
      builder: (context) {
        String notes = node.notes ?? '';
        return AlertDialog(
          title: const Text('Edit Notes'),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: notes),
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'Enter notes...'),
            onChanged: (val) => notes = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  node.notes = notes.trim().isEmpty ? null : notes.trim();
                });
                ref.read(todoListProvider.notifier).saveRootNode(widget.rootNode ?? node);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _toggleCompletion(TodoNode node, bool? val) {
    final isCompleted = val ?? false;
    setState(() {
      _setCompletionRecursive(node, isCompleted);
    });
    ref.read(todoListProvider.notifier).saveRootNode(widget.rootNode ?? node);
    if (isCompleted) {
      ref.read(gamificationProvider.notifier).addXP(10);
    }
  }

  void _setCompletionRecursive(TodoNode node, bool isCompleted) {
    node.isCompleted = isCompleted;
    for (var child in node.children) {
      _setCompletionRecursive(child, isCompleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TodoNode> nodes = widget.parentNode == null
        ? ref.watch(todoListProvider)
        : widget.parentNode!.children;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentNode?.name ?? 'Obsidian Allure'),
        actions: [
          if (widget.parentNode == null) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.local_fire_department),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActivityScreen()),
              ),
            ),
          ]
        ],
      ),
      drawer: widget.parentNode == null ? const AppSidebar() : null,
      floatingActionButton: FloatingActionButton(
        onPressed: _addNode,
        child: const Icon(Icons.add),
      ),
      body: nodes.isEmpty
          ? const Center(child: Text('No items yet. Add one!'))
          : ReorderableListView.builder(
              itemCount: nodes.length,
              onReorder: (oldIndex, newIndex) {
                if (widget.parentNode == null) {
                  ref.read(todoListProvider.notifier).reorderNodes(oldIndex, newIndex);
                } else {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = nodes.removeAt(oldIndex);
                    nodes.insert(newIndex, item);
                  });
                  ref.read(todoListProvider.notifier).saveRootNode(widget.rootNode!);
                }
              },
              itemBuilder: (context, index) {
                final node = nodes[index];
                final isLeaf = node.children.isEmpty;
                final pct = node.completionPercentage;
                final isFullyCompleted = node.isFullyCompleted;

                return Card(
                  key: ValueKey(node.id),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: isLeaf
                        ? Checkbox(
                            value: node.isCompleted,
                            onChanged: (val) => _toggleCompletion(node, val),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: pct,
                                backgroundColor: Colors.grey.shade800,
                                color: isFullyCompleted ? Colors.greenAccent : Colors.deepPurpleAccent,
                              ),
                              if (isFullyCompleted)
                                const Icon(Icons.check, color: Colors.greenAccent, size: 16)
                              else
                                Text('${(pct * 100).toInt()}%', style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                    title: Text(
                      node.name,
                      style: TextStyle(
                        decoration: (isLeaf && node.isCompleted) || (!isLeaf && isFullyCompleted)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: node.notes != null
                        ? Text(node.notes!, maxLines: 1, overflow: TextOverflow.ellipsis)
                        : (isLeaf ? null : Text('${node.children.length} sub-items')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLeaf)
                          IconButton(
                            icon: const Icon(Icons.note_alt_outlined),
                            onPressed: () => _editNotes(node),
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editNodeName(node),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteNode(node),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NodeListScreen(
                            parentNode: node,
                            rootNode: widget.rootNode ?? node,
                          ),
                        ),
                      ).then((_) {
                        // Refresh state when coming back so completion bubble updates
                        setState(() {});
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
