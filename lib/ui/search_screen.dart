import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_node.dart';
import '../providers/todo_provider.dart';
import 'node_list_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  bool _onlyIncomplete = false;

  List<TodoNode> _searchNodes(List<TodoNode> nodes, String query) {
    List<TodoNode> results = [];
    for (var node in nodes) {
      if (node.name.toLowerCase().contains(query.toLowerCase()) || 
          (node.notes != null && node.notes!.toLowerCase().contains(query.toLowerCase()))) {
        if (!_onlyIncomplete || !node.isFullyCompleted) {
          results.add(node);
        }
      }
      results.addAll(_searchNodes(node.children, query));
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(todoListProvider);
    
    List<TodoNode> searchResults = [];
    if (_query.isNotEmpty) {
       searchResults = _searchNodes(nodes, _query);
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search Any Level...',
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _query = val;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_onlyIncomplete ? Icons.filter_list : Icons.filter_list_off),
            tooltip: 'Toggle Incomplete Only',
            onPressed: () {
              setState(() {
                _onlyIncomplete = !_onlyIncomplete;
              });
            },
          )
        ],
      ),
      body: _query.isEmpty
          ? const Center(child: Text('Type to search across all layers'))
          : searchResults.isEmpty
              ? const Center(child: Text('No matches found'))
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final t = searchResults[index];
                    return ListTile(
                      title: Text(t.name),
                      subtitle: Text(t.notes ?? (t.children.isNotEmpty ? '${t.children.length} sub-items' : '')),
                      trailing: t.isFullyCompleted ? const Icon(Icons.done, color: Colors.green) : const Icon(Icons.circle_outlined),
                      onTap: () {
                        // Navigate to its parent's screen? Or its own screen if it has children.
                        if (t.children.isNotEmpty) {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (_) => NodeListScreen(
                                 parentNode: t,
                                 rootNode: t, // In search, we don't have root easily accessible. Ideally we should pass root.
                               ),
                             ),
                           );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
