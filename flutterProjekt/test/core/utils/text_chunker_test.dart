import 'package:flutter_test/flutter_test.dart';
import 'package:ai_study_app/core/utils/text_chunker.dart';

void main() {
  late TextChunker textChunker;

  setUp(() {
    textChunker = TextChunker();
  });

  group('TextChunker', () {
    group('chunkText', () {
      test('returns single chunk for short text', () {
        final text = List.generate(100, (i) => 'word$i').join(' ');
        final chunks = textChunker.chunkText(text, chunkSize: 500);
        expect(chunks.length, 1);
      });

      test('splits long text into multiple chunks', () {
        final text = List.generate(1500, (i) => 'word$i').join(' ');
        final chunks = textChunker.chunkText(text, chunkSize: 500, overlap: 50);
        expect(chunks.length, greaterThan(1));
      });

      test('chunks have overlap', () {
        final text = List.generate(1100, (i) => 'word$i').join(' ');
        final chunks = textChunker.chunkText(text, chunkSize: 500, overlap: 50);
        expect(chunks.length, greaterThanOrEqualTo(2));
        // Words at the boundary should overlap
        final words1 = chunks[0].split(' ');
        final words2 = chunks[1].split(' ');
        final overlapWords = words1.where((w) => words2.contains(w)).toList();
        expect(overlapWords.length, greaterThan(0));
      });

      test('handles empty text', () {
        final chunks = textChunker.chunkText('');
        expect(chunks.length, 1);
      });
    });

    group('findRelevantChunks', () {
      test('returns all chunks when fewer than topK', () {
        final chunks = ['Hello world', 'Dart language', 'Flutter framework'];
        final result = textChunker.findRelevantChunks('hello', chunks, topK: 5);
        expect(result.length, 3);
      });

      test('returns topK most relevant chunks', () {
        final chunks = List.generate(20, (i) => 'chunk $i content data');
        chunks[5] = 'flutter development mobile dart programming';
        chunks[10] = 'flutter widgets state management dart';
        final result = textChunker.findRelevantChunks('flutter dart', chunks, topK: 3);
        expect(result.length, 3);
        // The Flutter/Dart specific chunks should rank higher
        expect(result.any((c) => c.contains('flutter')), true);
      });

      test('handles empty chunks list', () {
        final result = textChunker.findRelevantChunks('query', []);
        expect(result.isEmpty, true);
      });

      test('handles empty query', () {
        final chunks = ['some text', 'other text'];
        final result = textChunker.findRelevantChunks('', chunks, topK: 1);
        expect(result.length, 1);
      });
    });
  });
}
