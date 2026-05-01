import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/todo_node.dart';
import 'node_list_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  List<TodoNode> _getAllNodes(List<TodoNode> nodes) {
    List<TodoNode> all = [];
    for (var node in nodes) {
      all.add(node);
      all.addAll(_getAllNodes(node.children));
    }
    return all;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allNodes = _getAllNodes(ref.watch(todoListProvider));
    final likedIds = ref.watch(favoritesProvider);
    
    final favoriteNodes = allNodes.where((n) => likedIds.contains(n.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Items'),
        centerTitle: true,
      ),
      body: favoriteNodes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No liked items yet!', style: TextStyle(color: Theme.of(context).primaryColor)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteNodes.length,
              itemBuilder: (context, index) {
                final node = favoriteNodes[index];
                final isLeaf = node.children.isEmpty;
                final isCompleted = isLeaf ? node.isCompleted : node.isFullyCompleted;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Icon(
                      isLeaf 
                        ? (isCompleted ? Icons.check_circle : Icons.radio_button_unchecked)
                        : (isCompleted ? Icons.check_circle : Icons.folder),
                      color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      node.name,
                      style: TextStyle(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(isLeaf ? 'Task' : 'Folder', style: const TextStyle(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.redAccent),
                      onPressed: () {
                        ref.read(favoritesProvider.notifier).toggleFavorite(node.id);
                      },
                    ),
                    onTap: () {
                      if (!isLeaf) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => NodeListScreen(parentNode: node, rootNode: node, depth: 1)));
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
