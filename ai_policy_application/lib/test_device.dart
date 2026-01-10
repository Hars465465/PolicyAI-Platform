import 'package:flutter/material.dart';
import '../data/services/device_service.dart';

class TestDevicePage extends StatefulWidget {
  const TestDevicePage({Key? key}) : super(key: key);

  @override
  State<TestDevicePage> createState() => _TestDevicePageState();
}

class _TestDevicePageState extends State<TestDevicePage> {
  String? deviceId;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final id = await DeviceService.getDeviceId();
    setState(() => deviceId = id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Device ID')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Device ID:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              deviceId ?? 'Loading...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDeviceId,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
