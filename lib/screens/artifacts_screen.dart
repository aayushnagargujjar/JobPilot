import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

// ----------------------
// IMPORT YOUR MODELS
// ----------------------
import '../models/student_profile.dart';
import '../providers/app_provider.dart';
import '../services/resume_services.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

class ArtifactsScreen extends StatefulWidget {
  const ArtifactsScreen({super.key});

  @override
  State<ArtifactsScreen> createState() => _ArtifactsScreenState();
}

class _ArtifactsScreenState extends State<ArtifactsScreen> {
  final TextEditingController _resumeCtrl = TextEditingController();
  bool _isReadingFile = false;
  bool _isAnalyzing = false;
  bool _analysisSuccess = false;

  // ------------------------------------------------------------------------
  // 1. FILE PICKER & TEXT EXTRACTION
  // ------------------------------------------------------------------------
  Future<void> _pickAndParseResume(AppProvider provider) async {
    setState(() => _isReadingFile = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        provider.addLog("SYSTEM", "Reading file from disk...", "INFO");

        String extractedText = await ResumeService.extractTextFromFile(path);

        setState(() {
          _resumeCtrl.text = extractedText;
        });
      } else {
        provider.addLog("SYSTEM", "File picker cancelled.", "WARNING");
      }
    } catch (e) {
      provider.addLog("SYSTEM", "Error picking file: $e", "ERROR");
    } finally {
      setState(() => _isReadingFile = false);
    }
  }

  // ------------------------------------------------------------------------
  // 2. GEMINI ANALYSIS (LOGIC COMMENTED OUT FOR TESTING)
  // ------------------------------------------------------------------------
  Future<void> _analyzeAndSaveToFirebase(String text, AppProvider provider) async {
    // 🔴 API CODE IS DISABLED/COMMENTED OUT AS REQUESTED
    /*
    const apiKey = "YOUR_API_KEY";

    if (text.isEmpty) return;

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

      final prompt = """
      You are a Data Extraction Agent... (Prompt hidden for brevity)
      """;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null) throw "Empty response from AI";

      String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      Map<String, dynamic> data = jsonDecode(cleanJson);

      data['isComplete'] = true;
      data['constraints'] = { 'location': [], 'remoteOnly': false };

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(data, SetOptions(merge: true));

        provider.addLog("GEMINI", "Profile analyzed and saved to Cloud.", "SUCCESS");
      }
    } catch (e) {
      provider.addLog("GEMINI", "Analysis Failed: $e", "ERROR");
      rethrow;
    }
    */
  }

  // ------------------------------------------------------------------------
  // 3. HANDLE ANALYSIS (SIMULATION ONLY)
  // ------------------------------------------------------------------------
  Future<void> _handleAnalysis(AppProvider provider) async {
    if (_resumeCtrl.text.isEmpty) return;

    // 1. START LOADING
    setState(() {
      _isAnalyzing = true;
      _analysisSuccess = false;
    });

    try {
      // 🔴 REAL API CALL COMMENTED OUT
      // await _analyzeAndSaveToFirebase(_resumeCtrl.text, provider);

      // 🟢 SIMULATION: FAKE WAIT TIME (2 Seconds)
      await Future.delayed(const Duration(seconds: 2));

      // 2. SHOW SUCCESS
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisSuccess = true;
        });

        // 3. RESET BUTTON AFTER 2 SECONDS
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _analysisSuccess = false;
            });
          }
        });

        provider.addLog("SYSTEM", "Analysis Simulation Complete (No API Used)", "SUCCESS");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisSuccess = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Simulation Failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ------------------------------------------------------------------------
  // 4. UI BUILD METHODS
  // ------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        LayoutBuilder(builder: (ctx, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProfileView(provider)),
                const SizedBox(width: 24),
                Expanded(child: _buildInputView(provider)),
              ],
            );
          } else {
            return Column(children: [
              _buildProfileView(provider),
              const SizedBox(height: 24),
              _buildInputView(provider)
            ]);
          }
        })
      ],
    );
  }

  Widget _buildProfileView(AppProvider provider) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text("AC", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.profile.name.isEmpty ? "Your Name" : provider.profile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(provider.profile.email.isEmpty ? "email@example.com" : provider.profile.email, style: TextStyle(color: AppTheme.primary)),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          Text("EDUCATION", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          if (provider.profile.education.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 8), child: Text("No education added yet.", style: TextStyle(color: Colors.white30))),

          ...provider.profile.education.map((e) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(e.school, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${e.degree} • ${e.year}"),
          )),
          const SizedBox(height: 24),
          Text("PROJECTS", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          if (provider.profile.projects.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 8), child: Text("No projects added yet.", style: TextStyle(color: Colors.white30))),

          ...provider.profile.projects.map((p) => Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if(p.link != null) Icon(LucideIcons.externalLink, size: 14, color: AppTheme.primary)
                ]),
                const SizedBox(height: 4),
                Text(p.description, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                const SizedBox(height: 8),
                Wrap(spacing: 4, children: p.skills.map((s) => Text(s, style: TextStyle(fontSize: 10, color: AppTheme.secondary))).toList())
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInputView(AppProvider provider) {
    return Column(
      children: [
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(LucideIcons.upload, color: AppTheme.secondary),
                const SizedBox(width: 8),
                const Text("Import Resume", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              ]),
              const SizedBox(height: 16),
              Container(
                height: 150,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                ),
                child: TextField(
                  controller: _resumeCtrl,
                  maxLines: null,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Paste text directly or upload a PDF/Image to auto-extract...",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isReadingFile ? null : () => _pickAndParseResume(provider),
                      icon: _isReadingFile
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(LucideIcons.fileUp, size: 18),
                      label: Text(_isReadingFile ? "Reading..." : "Upload File"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : () => _handleAnalysis(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _analysisSuccess ? Colors.green : AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        animationDuration: const Duration(milliseconds: 300),
                      ),
                      icon: _isAnalyzing
                          ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                          : _analysisSuccess
                          ? const Icon(LucideIcons.checkCircle, size: 18)
                          : const Icon(LucideIcons.sparkles, size: 18),
                      label: Text(
                          _isAnalyzing
                              ? "Processing..."
                              : _analysisSuccess
                              ? "Success!"
                              : "Analyze Text"
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Bullet Bank", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (provider.profile.bulletBank.isEmpty)
                const Text("No bullets generated yet.", style: TextStyle(color: Colors.white30)),

              ...provider.profile.bulletBank.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.checkCircle, size: 16, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(child: Text(b, style: TextStyle(fontSize: 13, color: Colors.grey[300]))),
                  ],
                ),
              ))
            ],
          ),
        )
      ],
    );
  }
}