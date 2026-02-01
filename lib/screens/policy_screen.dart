import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/job_model.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  bool _isUploading = false;

  Future<void> _handleSeedData() async {
    setState(() => _isUploading = true);
    try {
      await uploadJobs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Firestore seeded successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        GlassContainer(
          child: Row(
            children: [
              Icon(LucideIcons.shieldAlert, size: 32, color: Colors.redAccent),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Apply Guardrails",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                        "Safety protocols active. Agent will refuse to apply if rules are violated.",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: provider.policy.stopAll,
                onChanged: (v) {
                  provider.policy.stopAll = v;
                  provider.notifyListeners();
                },
                activeColor: Colors.red,
              )
            ],
          ),
        ),
        SizedBox(height: 24),

        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Thresholds",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Min Match Score"),
                  Text("${provider.policy.minMatchThreshold}%",
                      style: TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.bold))
                ],
              ),
              Slider(
                value: provider.policy.minMatchThreshold.toDouble(),
                min: 0,
                max: 100,
                activeColor: AppTheme.primary,
                onChanged: (v) {
                  provider.policy.minMatchThreshold = v.toInt();
                  provider.notifyListeners();
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "Max Daily Applications",
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                    text: provider.policy.maxDailyApplications.toString()),
                onSubmitted: (v) =>
                provider.policy.maxDailyApplications = int.tryParse(v) ?? 50,
              )
            ],
          ),
        ),
        SizedBox(height: 24),

        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("API Configuration",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "Gemini API Key",
                  hintText: "sk-...",
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  prefixIcon: Icon(LucideIcons.cpu),
                ),
                obscureText: true,
                onChanged: (v) => provider.apiKey = v,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Without a key, the agent runs in Simulation Mode.",
                    style: TextStyle(fontSize: 10, color: Colors.orange)),
              )
            ],
          ),
        ),
        SizedBox(height: 24),

        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Data Management",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(
                "Upload local jobs.json data to your live Firestore collection.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _handleSeedData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isUploading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primary),
                  )
                      : Icon(LucideIcons.database),
                  label: Text(_isUploading ? "Uploading..." : "Seed Jobs to Firestore"),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }
}

Future<void> uploadJobs() async {
  final CollectionReference jobsRef = FirebaseFirestore.instance.collection('jobs');
  final WriteBatch batch = FirebaseFirestore.instance.batch();

  try {
    final String response = await rootBundle.loadString('assets/jobs.json');
    final List<dynamic> jsonData = json.decode(response);

    for (var item in jsonData) {
      JobModel job = JobModel.fromJson(item);
      DocumentReference docRef = jobsRef.doc(job.jobId);
      batch.set(docRef, job.toMap());
    }

    await batch.commit();
  } catch (e) {
    throw Exception("Failed to upload: $e");
  }
}