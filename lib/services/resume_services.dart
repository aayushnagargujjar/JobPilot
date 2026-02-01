import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class ResumeService {



  static Future<String> extractTextFromFile(String path) async {
    if (path.toLowerCase().endsWith('.pdf')) {
      try {
        return await ReadPdfText.getPDFtext(path);
      } catch (e) {
        return "Error reading PDF: $e";
      }
    } else {
      final inputImage = InputImage.fromFile(File(path));
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();
      return recognizedText.text;
    }
  }


  static Map<String, dynamic> extractBasicInfo(String text) {

    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    final phoneRegex = RegExp(r'(\+\d{1,3}[- ]?)?\(?\d{3}\)?[- ]?\d{3}[- ]?\d{4}');

    String name = "";
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isNotEmpty) {
      if (!lines[0].toUpperCase().contains("RESUME")) {
        name = lines[0];
      } else if (lines.length > 1) {
        name = lines[1];
      }
    }

    return {
      "name": name,
      "email": emailRegex.stringMatch(text) ?? "",
      "phone": phoneRegex.stringMatch(text) ?? "",
      "raw_text": text,
    };
  }
}