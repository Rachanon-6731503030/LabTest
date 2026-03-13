import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../database_helper.dart';
import 'qr_scan_screen.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _qrData;
  Position? _position;
  String? _learnedToday;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _position = await Geolocator.getCurrentPosition();
    if (mounted) setState(() {});
  }

  Future<void> _scanQr() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (context) => const QrScanScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _qrData = result;
      });
    }
  }

  Future<void> _saveCheckOut() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_position == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Waiting for location...')));
      return;
    }
    if (_qrData == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please scan the QR code.')));
      return;
    }

    _formKey.currentState!.save();

    final checkOut = CheckInData(
      type: 'checkout',
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      timestamp: DateTime.now().toIso8601String(),
      qrData: _qrData,
      learnedToday: _learnedToday,
      feedback: _feedback,
    );

    await DatabaseHelper().insertCheckIn(checkOut);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Check-out saved!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _position != null
                          ? '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}'
                          : 'Retrieving location...',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _scanQr,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan class QR code'),
                    ),
                    if (_qrData != null) ...[
                      const SizedBox(height: 12),
                      Text('QR data: $_qrData'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Post-class reflection',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'What did you learn today?',
                    ),
                    maxLines: 3,
                    onSaved: (value) => _learnedToday = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Feedback (optional)',
                    ),
                    maxLines: 3,
                    onSaved: (value) => _feedback = value,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveCheckOut,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Submit Reflection'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
