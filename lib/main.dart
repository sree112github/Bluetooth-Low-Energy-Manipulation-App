// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ble provider.dart';
import 'bleRepository.dart';
import 'bleScanPage.dart';
import 'core/bleservice.dart';

void main() {
  final bluetoothService = BluetoothServices();
  final bluetoothRepository = BluetoothRepository(bluetoothService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BluetoothProvider(bluetoothRepository, bluetoothService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLE Demo',
      home: BleScanPage()
    );
  }
}

