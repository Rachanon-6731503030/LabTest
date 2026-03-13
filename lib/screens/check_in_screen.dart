import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../database_helper.dart';
import 'qr_scan_screen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _qrData;
  Position? _position;
  String? _previousTopic;
  String? _expectedTopic;
  int? _mood;

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

  Future<void> _saveCheckIn() async {
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

    final checkIn = CheckInData(
      type: 'checkin',
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      timestamp: DateTime.now().toIso8601String(),
      qrData: _qrData,
      previousTopic: _previousTopic,
      expectedTopic: _expectedTopic,
      mood: _mood,
    );

    await DatabaseHelper().insertCheckIn(checkIn);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Check-in saved!')));
    Navigator.pop(context);
  }

  Widget _buildMoodButton(int value, String label, IconData icon) {
    final selected = _mood == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mood = value),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected ? Colors.blueAccent : Colors.grey[200],
              child: Icon(
                icon,
                color: selected ? Colors.white : Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.black : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
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
                      'Your current location',
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
                    'Before class',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'What was covered previously?',
                    ),
                    onSaved: (value) => _previousTopic = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'What do you expect to learn?',
                    ),
                    onSaved: (value) => _expectedTopic = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('How are you feeling?'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMoodButton(
                        1,
                        'Angry',
                        Icons.sentiment_very_dissatisfied,
                      ),
                      _buildMoodButton(2, 'Sad', Icons.sentiment_dissatisfied),
                      _buildMoodButton(3, 'Neutral', Icons.sentiment_neutral),
                      _buildMoodButton(4, 'Happy', Icons.sentiment_satisfied),
                      _buildMoodButton(
                        5,
                        'Great',
                        Icons.sentiment_very_satisfied,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveCheckIn,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Submit Check-in'),
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
