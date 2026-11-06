import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';

ExportHistory _history({
  required Map<String, String> exported,
  required Map<String, String> predicted,
  CaseStudyStatus status = CaseStudyStatus.none,
}) => ExportHistory(
  baseFileName: 'x',
  exportDirectory: '',
  status: ExportHistoryStatus.success,
  templateIds: const [],
  templateSnapshots: const [],
  fieldValues: {
    for (final e in exported.entries)
      e.key: FieldValueEntry(label: e.key, value: e.value),
  },
  singleLineValues: const {},
  outputFiles: const [],
  documentCount: 1,
  caseStudyStatus: status,
  sources: [
    SourceDocument(
      fileName: 'a.xlsx',
      sourceType: 'xlsx',
      text: 'text',
      method: 'offline_text',
      predictedValues: predicted,
    ),
  ],
);

void main() {
  final predicted = {for (var i = 0; i < 100; i++) 'k$i': '$i'};

  test('an export left as proposed looks unreviewed and is not learned from', () {
    final history = _history(exported: predicted, predicted: predicted);
    expect(history.looksUnreviewed, isTrue);
    expect(history.usedForLearning, isFalse);
  });

  test('an edited export is learned from', () {
    final edited = {...predicted, for (var i = 0; i < 10; i++) 'k$i': 'x'};
    final history = _history(exported: edited, predicted: predicted);
    expect(history.looksUnreviewed, isFalse);
    expect(history.usedForLearning, isTrue);
  });

  test("the user's choice wins and keeps everything else", () {
    final history = _history(exported: predicted, predicted: predicted);
    final kept = history.withCaseStudyStatus(CaseStudyStatus.good);
    expect(kept.usedForLearning, isTrue);
    expect(kept.fieldValues, history.fieldValues);
    expect(kept.sources, history.sources);
    expect(kept.createdAt, history.createdAt);
    final edited = {...predicted, for (var i = 0; i < 50; i++) 'k$i': 'x'};
    expect(
      _history(
        exported: edited,
        predicted: predicted,
        status: CaseStudyStatus.failed,
      ).usedForLearning,
      isFalse,
    );
  });

  test('too few proposals say nothing', () {
    final few = {'a': '1'};
    expect(_history(exported: few, predicted: few).looksUnreviewed, isFalse);
  });
}
