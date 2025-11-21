import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final Box _box;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('aayutrack_reports');
    _loadReports();
  }

  void _loadReports() {
    final entries = _box.toMap().entries;

    final filtered = entries
        .where((e) =>
            e.value is Map &&
            e.value.containsKey('symptoms') &&
            e.value.containsKey('diagnosis') &&
            e.value.containsKey('timestamp'))
        .map((e) => Map<String, dynamic>.from(e.value))
        .toList();

    filtered.sort((a, b) =>
        DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

    setState(() {
      _reports = filtered;
    });
  }

  Widget _buildReportTile(Map<String, dynamic> report) {
    final date = DateFormat.yMMMd().add_jm().format(
      DateTime.parse(report['timestamp']),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kMint.withOpacity(0.2),
          child: const Icon(Icons.analytics_outlined, color: kTeal),
        ),
        title: Text(
          report['symptoms'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text("🕒 $date"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: kTeal,
          onPressed: () async {
            await _box.delete(report['timestamp']);
            _loadReports();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report deleted')),
            );
          },
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("🩺 Diagnosis"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📝 Symptoms:\n${report['symptoms']}"),
                    const SizedBox(height: 12),
                    Text("📋 Diagnosis:\n${report['diagnosis']}"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports History"),
        centerTitle: true,
        backgroundColor: kTeal,
      ),
      body: _reports.isEmpty
          ? const Center(
              child: Text(
                "No reports found yet.\nGenerate one from AI Checkup or Dashboard.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadReports(),
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: _reports.map(_buildReportTile).toList(),
              ),
            ),
    );
  }
}