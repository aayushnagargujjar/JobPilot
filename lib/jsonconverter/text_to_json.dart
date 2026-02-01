import 'dart:convert';

Map<String, dynamic> convertTextToJson(String text) {
  final lines = text.split('\n');

  return {
    "name": lines.isNotEmpty ? lines[0] : "",
    "raw_text": text,
  };
}
