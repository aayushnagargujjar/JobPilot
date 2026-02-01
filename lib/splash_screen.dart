import 'dart:convert';
import 'package:flutter/material.dart';
import 'jsonconverter/file_picker.dart';
import 'jsonconverter/ocr.dart';
import 'jsonconverter/text_to_json.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SplashScreen> {
  String resultText = "No resume uploaded";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            ElevatedButton(
              child: const Text("Upload Resume"),
              onPressed: () async {
                final path = await pickFile();
                if (path == null) return;

                String extractedText = "";

                if (path.endsWith('.png') || path.endsWith('.jpg')) {
                  extractedText = await extractTextFromImage(path);
                } else {
                  extractedText = "PDF selected (OCR not added yet)";
                }

                final jsonData = convertTextToJson(extractedText);

                setState(() {
                  resultText = jsonEncode(jsonData);
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              resultText,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
