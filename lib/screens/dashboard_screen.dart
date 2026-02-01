import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/job.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final stats = {
      'Applied': provider.jobs.where((j) => j.status == JobStatus.APPLIED).length,
      'Queued': provider.jobs.where((j) => j.status == JobStatus.NEW && j.matchScore >= provider.policy.minMatchThreshold).length,
      'Failed': provider.jobs.where((j) => j.status == JobStatus.FAILED).length,
      'Blocked': provider.jobs.where((j) => j.status == JobStatus.SKIPPED).length,
    };

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ----------------------
        // 1. STATS GRID
        // ----------------------
        LayoutBuilder(builder: (ctx, constraints) {
          final width = constraints.maxWidth;
          final cols = width > 800 ? 4 : (width > 500 ? 2 : 1);
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard("Applications", stats['Applied'].toString(), Colors.greenAccent, LucideIcons.checkCircle, width / cols - (16 * (cols-1)/cols)),
              _StatCard("In Queue", stats['Queued'].toString(), Colors.blueAccent, LucideIcons.layers, width / cols - (16 * (cols-1)/cols)),
              _StatCard("Failures", stats['Failed'].toString(), Colors.redAccent, LucideIcons.alertTriangle, width / cols - (16 * (cols-1)/cols)),
              _StatCard("Blocked", stats['Blocked'].toString(), Colors.grey, LucideIcons.shieldAlert, width / cols - (16 * (cols-1)/cols)),
            ],
          );
        }),

        const SizedBox(height: 24),

        // ----------------------
        // 2. CHART + TERMINAL
        // ----------------------
        LayoutBuilder(builder: (ctx, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _ActivityChart(stats: stats)),
                const SizedBox(width: 24),
                // Expanded(flex: 1, child: _LiveTerminal()), // Old Stateless Widget
                const Expanded(flex: 1, child: LiveTerminal()), // New Stateful Widget
              ],
            );
          } else {
            return Column(
              children: [
                _ActivityChart(stats: stats),
                const SizedBox(height: 24),
                const LiveTerminal(), // New Stateful Widget
              ],
            );
          }
        }),

        const SizedBox(height: 24),

        // ----------------------
        // 3. RECENT TABLE
        // ----------------------
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recent Applications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => onNavigate(1),
                    child: const Row(children: [Text("View All"), Icon(LucideIcons.chevronRight, size: 16)]),
                  )
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 30,
                  columns: const [
                    DataColumn(label: Text("Company", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text("Role", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text("Match", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text("Evidence", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                  ],
                  rows: provider.jobs.where((j) => j.status != JobStatus.NEW).take(5).map((job) {
                    return DataRow(cells: [
                      DataCell(Text(job.company, style: TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(job.role)),
                      DataCell(StatusBadge(status: job.status)),
                      DataCell(Text("${job.matchScore}%", style: TextStyle(color: job.matchScore > 80 ? Colors.greenAccent : Colors.amber))),
                      DataCell(job.evidenceUsed != null ? Icon(LucideIcons.checkCircle, size: 16, color: AppTheme.primary) : const Text("-")),

                    ]);
                  }).toList(),
                ),
              ),
              if (provider.jobs.where((j) => j.status != JobStatus.NEW).isEmpty)
                const Padding(padding: EdgeInsets.all(24), child: Center(child: Text("No activity yet", style: TextStyle(color: Colors.grey)))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _StatCard(String label, String value, Color color, IconData icon, double width) {
    return Container(
      width: width,
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          Positioned(right: 0, top: 0, child: Icon(icon, size: 48, color: color.withOpacity(0.2))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  final Map<String, int> stats;
  const _ActivityChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Activity Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (stats.values.reduce(max) + 5).toDouble(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
                      switch (val.toInt()) {
                        case 0: return const Text('Applied', style: TextStyle(color: Colors.grey, fontSize: 10));
                        case 1: return const Text('Queued', style: TextStyle(color: Colors.grey, fontSize: 10));
                        case 2: return const Text('Failed', style: TextStyle(color: Colors.grey, fontSize: 10));
                        case 3: return const Text('Blocked', style: TextStyle(color: Colors.grey, fontSize: 10));
                        default: return const Text('');
                      }
                    }),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroup(0, stats['Applied']!, Colors.greenAccent),
                  _makeGroup(1, stats['Queued']!, Colors.blueAccent),
                  _makeGroup(2, stats['Failed']!, Colors.redAccent),
                  _makeGroup(3, stats['Blocked']!, Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroup(int x, int y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y.toDouble(), color: color, width: 40, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))
    ]);
  }
}

// -----------------------------------------------------------------------------
// 🔥 NEW STATEFUL WIDGET FOR 1-SECOND LOADER
// -----------------------------------------------------------------------------
class LiveTerminal extends StatefulWidget {
  const LiveTerminal({super.key});

  @override
  State<LiveTerminal> createState() => _LiveTerminalState();
}

class _LiveTerminalState extends State<LiveTerminal> {
  final ScrollController _scrollController = ScrollController();
  bool _isStarting = false; // Local state to force spinner for 1s

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper to force 1s delay
  Future<void> _handleStart(AppProvider provider) async {
    setState(() => _isStarting = true);

    // 1. Wait for 1 second visually
    await Future.delayed(const Duration(seconds: 1));

    // 2. Trigger the real logic
    provider.runSearchAndRank();
    provider.runAutoApplyLoop();

    // 3. Turn off local loader (Provider's isRunning will take over if needed)
    if (mounted) {
      setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    // Scroll to bottom whenever logs update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut
        );
      }
    });

    // Determine if we should show the spinner (Local state OR Provider state)
    final bool showLoader = _isStarting || provider.isRunning;

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(LucideIcons.terminal, size: 16, color: AppTheme.secondary), const SizedBox(width: 8), const Text("Live Agent", style: TextStyle(fontWeight: FontWeight.bold))]),
              Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.isRunning ? Colors.green : Colors.grey,
                      boxShadow: provider.isRunning ? [const BoxShadow(color: Colors.green, blurRadius: 10)] : null
                  )
              )
            ],
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.logs.length,
              itemBuilder: (context, index) {
                final log = provider.logs[index];
                Color color = Colors.grey;
                if (log.type == 'ERROR') color = Colors.redAccent;
                if (log.type == 'SUCCESS') color = Colors.greenAccent;
                if (log.type == 'WARNING') color = Colors.amber;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.jetBrainsMono(fontSize: 10),
                      children: [
                        TextSpan(text: "[${log.timestamp}] ", style: TextStyle(color: Colors.grey[700])),
                        TextSpan(text: "${log.agent}: ", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        TextSpan(text: log.message, style: TextStyle(color: color)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  // DISABLE BUTTON IF LOADING
                  onPressed: showLoader ? null : () => _handleStart(provider),

                  // SHOW SPINNER IF LOADING
                  icon: showLoader
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
                      : const Icon(LucideIcons.play, size: 16),

                  // CHANGE TEXT BASED ON STATE
                  label: Text(
                      _isStarting ? "STARTING..." :
                      provider.isRunning ? "RUNNING..." :
                      "START AGENT"
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => provider.stop(),
                icon: const Icon(LucideIcons.square),
                style: IconButton.styleFrom(backgroundColor: Colors.white10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              )
            ],
          )
        ],
      ),
    );
  }
}