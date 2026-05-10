import 'dart:convert';
import 'dart:typed_data';
import '../constants/api_constants.dart';
import '../network/sse_client.dart';
import '../utils/text_chunker.dart';

class ImageOcrService {
  final SseClient _sseClient;
  final TextChunker _textChunker;

  ImageOcrService(this._sseClient, this._textChunker);

  Future<List<String>> extractTextFromImage(
    Uint8List imageBytes, {
    required AiProvider provider,
    required String apiKey,
  }) async {
    final base64Image = base64Encode(imageBytes);

    final List<Map<String, dynamic>> messages = [
      {
        'role': 'user',
        'content': provider == AiProvider.anthropic
            ? [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
                {
                  'type': 'text',
                  'text':
                      'Extract ALL text from this image of handwritten or printed notes. '
                      'Preserve the structure (headings, bullet points, numbered lists). '
                      'Return only the extracted text, nothing else.',
                },
              ]
            : [
                {
                  'type': 'text',
                  'text':
                      'Extract ALL text from this image of handwritten or printed notes. '
                      'Preserve the structure (headings, bullet points, numbered lists). '
                      'Return only the extracted text, nothing else.',
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
      },
    ];

    const systemPrompt =
        'You are an OCR assistant. Extract text from images accurately. '
        'Preserve formatting and structure.';

    final text = await _sseClient.getCompletion(
      systemPrompt: systemPrompt,
      messages: messages,
      provider: provider,
      apiKey: apiKey,
    );

    return _textChunker.chunkText(text);
  }
}
