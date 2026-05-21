import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/device_info_loader.dart';
import 'src/models.dart';

void main() {
  runApp(const FingerprintPocApp());
}

class FingerprintPocApp extends StatelessWidget {
  const FingerprintPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Device Fingerprint POC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const DeviceReportPage(),
    );
  }
}

class DeviceReportPage extends StatefulWidget {
  const DeviceReportPage({super.key});

  @override
  State<DeviceReportPage> createState() => _DeviceReportPageState();
}

class _DeviceReportPageState extends State<DeviceReportPage> {
  final _loader = DeviceInfoLoader();
  Future<DeviceSnapshot>? _snapshotFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _snapshotFuture ??= _loader.load(context);
  }

  void _refresh() {
    setState(() {
      _snapshotFuture = _loader.load(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device fingerprint POC'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<DeviceSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load device info: ${snapshot.error}'),
              ),
            );
          }

          return _Report(snapshot: snapshot.requireData);
        },
      ),
    );
  }
}

class _Report extends StatelessWidget {
  const _Report({required this.snapshot});

  final DeviceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy-safe local report',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'This demo displays normal platform/browser attributes only. It does not call third-party IP services or use canvas/audio/WebGL fingerprinting.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fingerprint',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SelectableText(snapshot.fingerprint),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _FingerprintRawCard(snapshot: snapshot),
        const SizedBox(height: 12),
        const _FingerprintInputsCard(),
        const SizedBox(height: 12),
        _MapCard(title: 'Device attributes', values: snapshot.device),
        const SizedBox(height: 12),
        _MapCard(title: 'Referral attributes', values: snapshot.referral),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('JSON output',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                SelectableText(snapshot.prettyJson()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FingerprintRawCard extends StatelessWidget {
  const _FingerprintRawCard({required this.snapshot});

  final DeviceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Raw fingerprint input JSON',
                    style: Theme.of(context).textTheme.titleMedium),
                OutlinedButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                          text: encoder.convert(snapshot.fingerprintInput)),
                    );
                  },
                  child: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This exact JSON value is stringified and hashed to create the fingerprint.',
            ),
            const SizedBox(height: 12),
            SelectableText(encoder.convert(snapshot.fingerprintInput)),
          ],
        ),
      ),
    );
  }
}

class _FingerprintInputsCard extends StatelessWidget {
  const _FingerprintInputsCard();

  static const _rows = <MapEntry<String, String>>[
    MapEntry('namespace', 'Fixed hash namespace: shipflutter-device-v1'),
    MapEntry('locale', 'Primary language code only'),
    MapEntry('timezoneOffsetMinutes', 'Local timezone offset in minutes'),
    MapEntry('devicePixelRatio', 'Device pixel ratio'),
    MapEntry('colorScheme', 'Current light or dark color scheme'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fingerprint input attributes',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'The fingerprint is a SHA-256 hash of privacy-safe device and browser attributes. Referral params are shown separately for attribution but are not included in the device fingerprint.',
            ),
            const SizedBox(height: 12),
            for (final row in _rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 160,
                      child: Text(row.key,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Text(row.value)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.title, required this.values});

  final String title;
  final Map<String, Object?> values;

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 160,
                      child: Text(entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                        child: SelectableText(entry.value?.toString() ?? '—')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
