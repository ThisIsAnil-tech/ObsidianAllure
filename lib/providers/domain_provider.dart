import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/domain.dart';
import '../models/subtopic.dart';
import '../models/topic.dart';
import '../repositories/hive_service.dart';

final domainListProvider = StateNotifierProvider<DomainListNotifier, List<DomainModel>>((ref) {
  return DomainListNotifier();
});

class DomainListNotifier extends StateNotifier<List<DomainModel>> {
  DomainListNotifier() : super(HiveService.getDomains());

  void refresh() {
    state = HiveService.getDomains();
  }

  Future<void> addDomain(DomainModel domain) async {
    await HiveService.addDomain(domain);
    refresh();
  }

  Future<void> updateDomain(DomainModel domain) async {
    await HiveService.updateDomain(domain);
    refresh();
  }

  Future<void> deleteDomain(String id) async {
    await HiveService.deleteDomain(id);
    refresh();
  }

  Future<void> updateTopicStatus(DomainModel domain, Subtopic subtopic, Topic topic, bool isCompleted) async {
    topic.isCompleted = isCompleted;
    await domain.save();
    refresh();
  }
  
  Future<void> markAllTopicsDone(DomainModel domain, Subtopic subtopic) async {
    for (var topic in subtopic.topics) {
      topic.isCompleted = true;
    }
    await domain.save();
    refresh();
  }
  
  Future<void> reorderDomains(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = state.removeAt(oldIndex);
    state.insert(newIndex, item);
    
    // Update order indexes
    for (int i = 0; i < state.length; i++) {
      state[i].orderIndex = i;
      await state[i].save();
    }
    refresh();
  }
}
