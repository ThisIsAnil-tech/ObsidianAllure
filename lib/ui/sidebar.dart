import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/domain.dart';
import '../models/subtopic.dart';
import '../models/topic.dart';
import '../providers/domain_provider.dart';

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
            subtitle: const Text('Save as JSON/TXT'),
            onTap: () => _exportData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Import / Merge Data'),
            subtitle: const Text('Deep Load JSON/TXT'),
            onTap: () => _importData(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final domains = ref.read(domainListProvider);
      final exportMap = <String, dynamic>{};
      
      for (var d in domains) {
        final subMap = <String, dynamic>{};
        for (var s in d.subtopics) {
          bool allEmptyNotes = s.topics.every((t) => (t.notes ?? '').trim().isEmpty);
          if (allEmptyNotes) {
             subMap[s.name] = s.topics.map((t) => t.name).toList();
          } else {
             final topicMap = <String, dynamic>{};
             for (var t in s.topics) {
                if ((t.notes ?? '').trim().isEmpty) {
                   topicMap[t.name] = [];
                } else {
                   topicMap[t.name] = t.notes!.split('\n')
                       .where((e) => e.trim().isNotEmpty)
                       .map((e) => e.replaceFirst(RegExp(r'^- '), '').trim())
                       .toList();
                }
             }
             subMap[s.name] = topicMap;
          }
        }
        exportMap[d.name] = subMap;
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
        final notifier = ref.read(domainListProvider.notifier);
        const uuid = Uuid();

        if (decoded is Map<String, dynamic>) {
          decoded.forEach((domainName, domainVal) {
            final mappedSubs = <Subtopic>[];
            if (domainVal is Map<String, dynamic>) {
              domainVal.forEach((subName, subVal) {
                final mappedTopics = <Topic>[];
                if (subVal is List) {
                  for (var item in subVal) {
                    mappedTopics.add(Topic(
                      id: uuid.v4(),
                      name: item.toString(),
                      createdAt: DateTime.now(),
                    ));
                  }
                } else if (subVal is Map<String, dynamic>) {
                  subVal.forEach((topicName, topicVal) {
                    String? notes;
                    if (topicVal is List && topicVal.isNotEmpty) {
                      notes = topicVal.map((e) => "- $e").join('\n');
                    }
                    mappedTopics.add(Topic(
                      id: uuid.v4(),
                      name: topicName,
                      notes: notes,
                      createdAt: DateTime.now(),
                    ));
                  });
                }
                
                mappedSubs.add(Subtopic(
                  id: uuid.v4(),
                  name: subName,
                  topics: mappedTopics,
                  createdAt: DateTime.now(),
                ));
              });
            }
            
            notifier.addDomain(DomainModel(
              id: uuid.v4(),
              name: domainName,
              subtopics: mappedSubs,
              createdAt: DateTime.now(),
            ));
          });
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
