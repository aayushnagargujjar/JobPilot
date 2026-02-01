import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {

  Future<void> _handleLogout() async {
    try {
      // 1. Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // 2. Clear stack and redirect to Auth Screen
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error logging out: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // --- Safety Guardrails Section ---
        GlassContainer(
          child: Row(
            children: [
              const Icon(LucideIcons.shieldAlert, size: 32, color: Colors.redAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Apply Guardrails",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text(
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
        const SizedBox(height: 24),

        // --- Thresholds Section ---
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Thresholds",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Min Match Score"),
                  Text("${provider.policy.minMatchThreshold}%",
                      style: const TextStyle(
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
              const SizedBox(height: 16),
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
        const SizedBox(height: 24),

        // --- API Configuration Section ---
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("API Configuration",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "Gemini API Key",
                  hintText: "sk-...",
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  prefixIcon: const Icon(LucideIcons.cpu),
                ),
                obscureText: true,
                onChanged: (v) => provider.apiKey = v,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("Without a key, the agent runs in Simulation Mode.",
                    style: TextStyle(fontSize: 10, color: Colors.orange)),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- Account Management (REPLACED SEED DATA) ---
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Account Management",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                "Sign out of the application. You will need to log in again to manage your agent.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(LucideIcons.logOut),
                  label: const Text("Logout"),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Sign Out", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to log out of your account?",
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}