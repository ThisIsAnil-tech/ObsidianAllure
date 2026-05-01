import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  final int depth;

  const NodeListScreen({
    super.key,
    this.parentNode,
    this.rootNode,
    this.depth = 0,
  });

  @override
  ConsumerState<NodeListScreen> createState() => _NodeListScreenState();
}

class _NodeListScreenState extends ConsumerState<NodeListScreen> {
  DateTime _selectedDate = DateTime.now();

  void _addNode() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        String name = '';
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Item',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                ),
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
                  child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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

  void _editNotes(TodoNode node) {
    showDialog(
      context: context,
      builder: (context) {
        String notes = node.notes ?? '';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Notes', style: TextStyle(color: Theme.of(context).primaryColor)),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: notes),
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Add some details...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (val) => notes = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              onPressed: () {
                setState(() {
                  node.notes = notes.trim().isEmpty ? null : notes.trim();
                });
                ref.read(todoListProvider.notifier).saveRootNode(widget.rootNode ?? node);
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
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

  Widget _buildHorizontalCalendar() {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 2));
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
          final colorScheme = Theme.of(context).colorScheme;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : colorScheme.primary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRootCard(TodoNode node) {
    final pct = node.completionPercentage;
    final isFullyCompleted = node.isFullyCompleted;

    return GestureDetector(
      onTap: () => _navigateToNode(node),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayColor,
                      decoration: isFullyCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () => _deleteNode(node),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${node.children.length} Items',
              style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                color: isFullyCompleted ? Colors.greenAccent : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeafChecklist(TodoNode node) {
    final isCompleted = node.isCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: () => _toggleCompletion(node, !isCompleted),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? Colors.transparent : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
              color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.transparent,
            ),
            child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
        ),
        title: Text(
          node.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCompleted ? FontWeight.normal : FontWeight.w600,
            color: isCompleted ? Colors.grey : Theme.of(context).textTheme.bodyColor,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: node.notes != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  node.notes!,
                  style: TextStyle(color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(Icons.note_alt_outlined, color: Theme.of(context).primaryColor.withOpacity(0.5)),
          onPressed: () => _editNotes(node),
        ),
        onLongPress: () => _deleteNode(node),
      ),
    );
  }

  Widget _buildIntermediateFolder(TodoNode node) {
    final isFullyCompleted = node.isFullyCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFullyCompleted ? Icons.check_circle : Icons.folder_open,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          node.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: isFullyCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToNode(node),
        onLongPress: () => _deleteNode(node),
      ),
    );
  }

  void _navigateToNode(TodoNode node) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NodeListScreen(
          parentNode: node,
          rootNode: widget.rootNode ?? node,
          depth: widget.depth + 1,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<TodoNode> nodes = widget.parentNode == null
        ? ref.watch(todoListProvider)
        : widget.parentNode!.children;

    final isRoot = widget.depth == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentNode?.name ?? 'Today'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
        ],
      ),
      drawer: isRoot ? const AppSidebar() : null,
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _addNode,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isRoot
          ? BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8.0,
              color: Theme.of(context).cardTheme.color,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(icon: Icon(Icons.home, color: Theme.of(context).colorScheme.primary), onPressed: () {}),
                    IconButton(
                      icon: Icon(Icons.local_fire_department, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen())),
                    ),
                    const SizedBox(width: 40), // Space for FAB
                    IconButton(icon: Icon(Icons.favorite_border, color: Theme.of(context).primaryColor.withOpacity(0.5)), onPressed: () {}),
                    IconButton(
                      icon: Icon(Icons.settings, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRoot) ...[
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Text(
                DateFormat('MMMM yyyy').format(_selectedDate).toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            _buildHorizontalCalendar(),
          ],
          Expanded(
            child: nodes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Theme.of(context).primaryColor.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('All clear for today!', style: TextStyle(color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
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
                      Widget child;
                      
                      if (isRoot) {
                        child = _buildRootCard(node);
                      } else if (node.children.isEmpty) {
                        child = _buildLeafChecklist(node);
                      } else {
                        child = _buildIntermediateFolder(node);
                      }

                      return KeyedSubtree(
                        key: ValueKey(node.id),
                        child: child,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
