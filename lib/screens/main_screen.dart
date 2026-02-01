import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme.dart';
import 'dashboard_screen.dart';
import 'jobs_screen.dart';
import 'artifacts_screen.dart';
import 'policy_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          Row(
            children: [
              if (isDesktop) _buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    if (!isDesktop) _buildMobileHeader(),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: [
                         DashboardScreen(onNavigate: (i) => setState(() => _selectedIndex = i)),
                         JobsScreen(),
                          ArtifactsScreen(),
                         PolicyScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppTheme.surface.withOpacity(0.9),
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Dash'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.briefcase), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.fileText), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.settings), label: 'Policy'),
        ],
      )
          : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("JobPilot", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("AI AGENT v2.0", style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey)),
                ],
              )
            ],
          ),
          SizedBox(height: 40),
          _SidebarItem(
            icon: LucideIcons.layoutDashboard,
            label: "Dashboard",
            active: _selectedIndex == 0,
            onTap: () => setState(() => _selectedIndex = 0),
          ),
          _SidebarItem(
            icon: LucideIcons.briefcase,
            label: "Job Feed",
            active: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          _SidebarItem(
            icon: LucideIcons.fileText,
            label: "Artifact Pack",
            active: _selectedIndex == 2,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
          _SidebarItem(
            icon: LucideIcons.shieldAlert,
            label: "Guardrails",
            active: _selectedIndex == 3,
            onTap: () => setState(() => _selectedIndex = 3),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.grey[800], child: Text("AC", style: TextStyle(color: Colors.white))),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Alex Carter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("Premium Plan", style: TextStyle(color: AppTheme.primary, fontSize: 12)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.surface.withOpacity(0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("JobPilot", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Icon(LucideIcons.menu, color: Colors.grey),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: active ? Border.all(color: AppTheme.primary.withOpacity(0.2)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: active ? AppTheme.primary : Colors.grey),
              SizedBox(width: 12),
              Text(label, style: TextStyle(
                  color: active ? Colors.white : Colors.grey,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal
              )),
            ],
          ),
        ),
      ),
    );
  }
}