import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_node.dart';
import '../providers/todo_provider.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurpleAccent),
            child: Text(
              'Offline Todo\nSettings',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Data'),
            subtitle: const Text('Save as JSON'),
            onTap: () => _exportData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Import Data'),
            subtitle: const Text('Deep Load JSON (Any Depth)'),
            onTap: () => _importData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Clear All Data'),
            subtitle: const Text('Wipes everything'),
            onTap: () => _clearData(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _clearData(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(todoListProvider.notifier);
    final nodes = ref.read(todoListProvider);
    for (var node in nodes) {
      notifier.deleteRootNode(node.id);
    }
    if (context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared.')));
    }
  }

  dynamic _nodeToJson(TodoNode node) {
    if (node.children.isEmpty) {
       if (node.notes != null && node.notes!.isNotEmpty) {
          return node.notes!.split('\n').where((e) => e.trim().isNotEmpty).toList();
       }
       return [];
    }
    
    final map = <String, dynamic>{};
    for (var child in node.children) {
      map[child.name] = _nodeToJson(child);
    }
    return map;
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final nodes = ref.read(todoListProvider);
      final exportMap = <String, dynamic>{};
      
      for (var node in nodes) {
        exportMap[node.name] = _nodeToJson(node);
      }

      final jsonStr = const JsonEncoder.withIndent('  ').convert(exportMap);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/todo_backup.json');
      await file.writeAsString(jsonStr);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported safely to: ${file.path}')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export Failed: $e')));
    }
  }

  List<TodoNode> _parseJsonLevel(dynamic data, Uuid uuid) {
    final List<TodoNode> children = [];
    
    if (data is Map<String, dynamic>) {
      data.forEach((key, value) {
        children.add(TodoNode(
          id: uuid.v4(),
          name: key,
          createdAt: DateTime.now(),
          children: _parseJsonLevel(value, uuid),
        ));
      });
    } else if (data is List) {
      for (var item in data) {
        if (item is Map<String, dynamic>) {
           children.addAll(_parseJsonLevel(item, uuid));
        } else {
           // Treat string array items as individual leaf nodes without children
           children.add(TodoNode(
             id: uuid.v4(),
             name: item.toString(),
             createdAt: DateTime.now(),
           ));
        }
      }
    }
    
    return children;
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        final dynamic decoded = jsonDecode(content);
        final notifier = ref.read(todoListProvider.notifier);
        const uuid = Uuid();

        if (decoded is Map<String, dynamic>) {
          decoded.forEach((key, value) {
            notifier.addRootNode(TodoNode(
              id: uuid.v4(),
              name: key,
              createdAt: DateTime.now(),
              children: _parseJsonLevel(value, uuid),
            ));
          });
        } else if (decoded is List) {
           final parsed = _parseJsonLevel(decoded, uuid);
           for (var n in parsed) {
              notifier.addRootNode(n);
           }
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Imported Safely!')));
        }
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import Failed. Invalid JSON structure: $e')));
    }
  }
}
