import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic.dart';
import '../providers/domain_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  bool _onlyIncomplete = false;

  @override
  Widget build(BuildContext context) {
    final domains = ref.watch(domainListProvider);
    
    // Evaluate search globally
    List<Topic> searchResults = [];
    for (var d in domains) {
      for (var s in d.subtopics) {
        for (var t in s.topics) {
          if (_query.isNotEmpty && t.name.toLowerCase().contains(_query.toLowerCase())) {
            if (!_onlyIncomplete || !t.isCompleted) {
              searchResults.add(t);
            }
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search Topics...',
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
                      subtitle: Text(t.notes ?? ''),
                      trailing: t.isCompleted ? const Icon(Icons.done, color: Colors.green) : const Icon(Icons.circle_outlined),
                    );
                  },
                ),
    );
  }
}
