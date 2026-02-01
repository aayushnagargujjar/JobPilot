import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

class PolicyScreen extends StatelessWidget {
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
                    Text("Apply Guardrails", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("Safety protocols active. Agent will refuse to apply if rules are violated.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: provider.policy.stopAll,
                onChanged: (v) {
                  provider.policy.stopAll = v;
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
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
              Text("Thresholds", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Min Match Score"), Text("${provider.policy.minMatchThreshold}%", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))],
              ),
              Slider(
                value: provider.policy.minMatchThreshold.toDouble(),
                min: 0, max: 100,
                activeColor: AppTheme.primary,
                onChanged: (v) {
                  provider.policy.minMatchThreshold = v.toInt();
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  provider.notifyListeners();
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "Max Daily Applications",
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: provider.policy.maxDailyApplications.toString()),
                onSubmitted: (v) => provider.policy.maxDailyApplications = int.tryParse(v) ?? 50,
              )
            ],
          ),
        ),
        SizedBox(height: 24),
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("API Configuration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "Gemini API Key",
                  hintText: "sk-...",
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: Icon(LucideIcons.cpu),
                ),
                obscureText: true,
                onChanged: (v) => provider.apiKey = v,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Without a key, the agent runs in Simulation Mode.", style: TextStyle(fontSize: 10, color: Colors.orange)),
              )
            ],
          ),
        )
      ],
    );
  }
}