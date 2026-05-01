import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_career/models/domain.dart';
import 'package:todo_app_career/models/subtopic.dart';
import 'package:todo_app_career/models/topic.dart';

void main() {
  test('Topic completion cascades to Subtopic and Domain', () {
    final t1 = Topic(id: '1', name: 'T1', createdAt: DateTime.now());
    final t2 = Topic(id: '2', name: 'T2', createdAt: DateTime.now());
    
    final sub = Subtopic(id: 's1', name: 'Sub 1', topics: [t1, t2], createdAt: DateTime.now());
    
    final dom = DomainModel(id: 'd1', name: 'Dom 1', subtopics: [sub], createdAt: DateTime.now());

    expect(sub.isCompleted, false);
    expect(sub.completionPercentage, 0.0);
    expect(dom.isCompleted, false);

    t1.isCompleted = true;
    expect(sub.isCompleted, false);
    expect(sub.completionPercentage, 0.5);
    expect(dom.completionPercentage, 0.0);

    t2.isCompleted = true;
    expect(sub.isCompleted, true);
    expect(sub.completionPercentage, 1.0);
    expect(dom.isCompleted, true);
    expect(dom.completionPercentage, 1.0);
  });
}
