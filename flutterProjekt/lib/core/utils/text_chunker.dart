import 'dart:math';
import '../constants/api_constants.dart';

class TextChunker {
  /// Split text into chunks of approximately [chunkSize] words with [overlap] word overlap
  List<String> chunkText(
    String text, {
    int chunkSize = ApiConstants.chunkSize,
    int overlap = ApiConstants.chunkOverlap,
  }) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= chunkSize) return [text.trim()];

    final chunks = <String>[];
    int start = 0;

    while (start < words.length) {
      final end = min(start + chunkSize, words.length);
      chunks.add(words.sublist(start, end).join(' '));
      if (end >= words.length) break;
      start += chunkSize - overlap;
    }

    return chunks;
  }

  /// Simple TF-IDF-like relevance search
  List<String> findRelevantChunks(
    String query,
    List<String> allChunks, {
    int topK = ApiConstants.topKChunks,
  }) {
    if (allChunks.isEmpty) return [];
    if (allChunks.length <= topK) return allChunks;

    final queryTerms = _tokenize(query);
    if (queryTerms.isEmpty) return allChunks.take(topK).toList();

    // Calculate document frequencies
    final df = <String, int>{};
    for (final chunk in allChunks) {
      final terms = _tokenize(chunk).toSet();
      for (final term in terms) {
        df[term] = (df[term] ?? 0) + 1;
      }
    }

    // Score each chunk
    final scored = <MapEntry<int, double>>[];
    for (int i = 0; i < allChunks.length; i++) {
      final chunkTerms = _tokenize(allChunks[i]);
      final tf = <String, int>{};
      for (final term in chunkTerms) {
        tf[term] = (tf[term] ?? 0) + 1;
      }

      double score = 0;
      for (final queryTerm in queryTerms) {
        final termFreq = tf[queryTerm] ?? 0;
        final docFreq = df[queryTerm] ?? 0;
        if (termFreq > 0 && docFreq > 0) {
          // TF-IDF: tf * log(N / df)
          final idf = log(allChunks.length / docFreq);
          score += termFreq * idf;
        }
      }
      scored.add(MapEntry(i, score));
    }

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored
        .take(topK)
        .map((e) => allChunks[e.key])
        .toList();
  }

  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sąćęłńóśźżĄĆĘŁŃÓŚŹŻ]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();
  }
}
