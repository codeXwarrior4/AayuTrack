import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import '../theme.dart';

class ReportAnalyticsScreen extends StatefulWidget {
  const ReportAnalyticsScreen({super.key});

  @override
  State<ReportAnalyticsScreen> createState() => _ReportAnalyticsScreenState();
}

class _ReportAnalyticsScreenState extends State<ReportAnalyticsScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    final box = Hive.box('aayutrack_box');
    final raw = box.get('checkup_history', defaultValue: []);
    _history = List<Map<String, dynamic>>.from(raw);
  }

  double _severityToValue(String level) {
    switch (level) {
      case "Low":
        return 1;
      case "Moderate":
        return 2;
      case "High":
        return 3;
      case "Critical":
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Health Analytics"),
        backgroundColor: kTeal,
        foregroundColor: Colors.white,
      ),
      body: _history.isEmpty
          ? const Center(
              child: Text(
                "No health checkup history yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle("📊 Severity Trend (Bar Chart)"),
                _buildSeverityBarChart(),
                const SizedBox(height: 25),

                _buildSectionTitle("📉 Weekly Symptom Severity (Line Chart)"),
                _buildLineChart(),
                const SizedBox(height: 25),

                _buildSectionTitle("🧬 Condition Frequency (Pie Chart)"),
                _buildPieChart(),
                const SizedBox(height: 25),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kTeal,
      ),
    );
  }

  // ---------------- BAR CHART ----------------
  Widget _buildSeverityBarChart() {
    final bars = <BarChartGroupData>[];

    for (int i = 0; i < _history.length; i++) {
      final severity = _history[i]['severity'] ?? "Low";
      final value = _severityToValue(severity);

      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: value,
              colors: [kTeal], // Replace 'color' with 'colors'
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barGroups: bars,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true),
            bottomTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }

  // ---------------- LINE CHART ----------------
  Widget _buildLineChart() {
    final List<FlSpot> points = [];

    for (int i = 0; i < _history.length; i++) {
      final severity = _history[i]['severity'] ?? "Low";
      points.add(FlSpot(i.toDouble(), _severityToValue(severity)));
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              spots: points,
              barWidth: 3,
              colors: [kTeal], // Replace 'color' with 'colors'
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- PIE CHART ----------------
  Widget _buildPieChart() {
    final Map<String, int> count = {};

    for (final item in _history) {
      final diag = item['diagnosis'] ?? 'Unknown';
      count[diag] = (count[diag] ?? 0) + 1;
    }

    final pieSections = <PieChartSectionData>[];
    int index = 0;

    count.forEach((name, value) {
      pieSections.add(
        PieChartSectionData(
          color: Colors.primaries[index % Colors.primaries.length],
          value: value.toDouble(),
          radius: 60,
          title: "$name\n$value",
          titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      );
      index++;
    });

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: pieSections,
        ),
      ),
    );
  }
}
