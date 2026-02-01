import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

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
        if (mounted) {
          provider.runResumeParser(extractedText);
        }
      } else {
        provider.addLog("SYSTEM", "File picker cancelled.", "WARNING");
      }
    } catch (e) {
      provider.addLog("SYSTEM", "Error picking file: $e", "ERROR");
    } finally {
      setState(() => _isReadingFile = false);
    }
  }
  Future<void> _handleAnalysis(AppProvider provider) async {
    if (_resumeCtrl.text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _analysisSuccess = false;
    });

    await provider.runResumeParser(_resumeCtrl.text);

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _analysisSuccess = true;
      });

      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _analysisSuccess = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        LayoutBuilder(builder: (ctx, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProfileView(provider)),
                SizedBox(width: 24),
                Expanded(child: _buildInputView(provider)),
              ],
            );
          } else {
            return Column(children: [_buildProfileView(provider), SizedBox(height: 24), _buildInputView(provider)]);
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
                  child: Center(child: Text("AC", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.profile.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(provider.profile.email, style: TextStyle(color: AppTheme.primary)),
                ],
              )
            ],
          ),
          SizedBox(height: 32),
          Text("EDUCATION", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          ...provider.profile.education.map((e) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(e.school, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${e.degree} • ${e.year}"),
          )),
          SizedBox(height: 24),
          Text("PROJECTS", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          ...provider.profile.projects.map((p) => Container(
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(p.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  if(p.link != null) Icon(LucideIcons.externalLink, size: 14, color: AppTheme.primary)
                ]),
                SizedBox(height: 4),
                Text(p.description, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                SizedBox(height: 8),
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
                SizedBox(width: 8),
                Text("Import Resume", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              ]),
              SizedBox(height: 16),
              Container(
                height: 150,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                ),
                child: TextField(
                  controller: _resumeCtrl,
                  maxLines: null,
                  style: TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Paste text directly or upload a PDF/Image to auto-extract...",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Row(
                children: [

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isReadingFile ? null : () => _pickAndParseResume(provider),
                      icon: _isReadingFile
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(LucideIcons.fileUp, size: 18),
                      label: Text(_isReadingFile ? "Reading..." : "Upload File"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : () => _handleAnalysis(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _analysisSuccess ? Colors.green : AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        // Smooth color transition
                        animationDuration: Duration(milliseconds: 300),
                      ),

                      icon: _isAnalyzing
                          ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                          : _analysisSuccess
                          ? Icon(LucideIcons.checkCircle, size: 18)
                          : Icon(LucideIcons.sparkles, size: 18),

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
        SizedBox(height: 24),
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bullet Bank", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ...provider.profile.bulletBank.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.checkCircle, size: 16, color: Colors.green),
                    SizedBox(width: 12),
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