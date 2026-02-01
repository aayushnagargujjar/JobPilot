import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

Future<String> extractTextFromImage(String path) async {
  final inputImage = InputImage.fromFile(File(path));
  final textRecognizer = TextRecognizer();
  final RecognizedText recognizedText =
  await textRecognizer.processImage(inputImage);

  textRecognizer.close();
  return recognizedText.text;
}
