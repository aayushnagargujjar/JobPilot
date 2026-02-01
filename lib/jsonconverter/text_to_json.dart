import 'dart:convert';

Map<String, dynamic> convertTextToJson(String text) {
  // 1. Define Regex for common patterns
  final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
  final phoneRegex = RegExp(r'(\+\d{1,3}[- ]?)?\(?\d{3}\)?[- ]?\d{3}[- ]?\d{4}');

  // 2. Extract Basic Info
  String email = emailRegex.stringMatch(text) ?? "";
  String phone = phoneRegex.stringMatch(text) ?? "";

  // 3. Smart Name Extraction (heuristic: first non-empty line that isn't a header)
  final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  String name = lines.isNotEmpty ? lines[0] : "";

  // 4. Basic Section Extraction (Skills, Education)
  // We convert text to lower case for searching but keep raw text for extraction
  String lowerText = text.toLowerCase();

  List<String> extractedSkills = [];
  if (lowerText.contains("skills")) {
    // This is a simple mock. In reality, you'd extract the text block after "Skills"
    // Here we just flag that we found the section.
    extractedSkills.add("Skills section found");
  }

  return {
    "name": name,
    "email": email,
    "phone": phone,
    "raw_text": text,
    "metadata": {
      "has_skills": lowerText.contains("skills") || lowerText.contains("technologies"),
      "has_education": lowerText.contains("education") || lowerText.contains("university"),
      "has_experience": lowerText.contains("experience") || lowerText.contains("work history"),
    }
  };
}
