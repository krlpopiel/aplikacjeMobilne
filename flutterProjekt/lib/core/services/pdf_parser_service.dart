import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/text_chunker.dart';

class PdfParserService {
  final TextChunker _textChunker;

  PdfParserService(this._textChunker);

  Future<List<String>> parsePdfToChunks(Uint8List pdfBytes) async {
    final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
    final PdfTextExtractor extractor = PdfTextExtractor(document);

    final StringBuffer fullText = StringBuffer();
    for (int i = 0; i < document.pages.count; i++) {
      final pageText = extractor.extractText(startPageIndex: i);
      fullText.writeln(pageText);
    }

    document.dispose();

    return _textChunker.chunkText(fullText.toString());
  }
}
