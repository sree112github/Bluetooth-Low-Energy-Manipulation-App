import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothServices {
  final String targetServiceUUID = "12345678-1234-5678-1234-56789abcdef0";
  final String targetCharacteristicUUID = "abcdef12-3456-7890-abcd-ef1234567890";

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;

  final StreamController<String> _receivedDataController = StreamController<String>.broadcast();
  Stream<String> get receivedDataStream => _receivedDataController.stream;

  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothDevice? _connectedDevice;

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<bool> isSupported() async {
    return await FlutterBluePlus.isSupported;
  }

  Future<void> turnOnBluetoothIfPossible() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> startScanAndConnect({required String targetDeviceId}) async {
    await requestPermissions();

    if (!await FlutterBluePlus.isSupported) {
      print("Bluetooth not supported on this device.");
      return;
    }

    if (!await Permission.bluetoothScan.isGranted) {
      print("Bluetooth scan permission not granted.");
      return;
    }

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        print("Found device: ${r.device.platformName} [${r.device.remoteId.str}]");

        if (r.device.remoteId.str.toLowerCase() == targetDeviceId.toLowerCase()) {
          await stopScan();
          await connectToDeviceAndListen(r.device);
          break;
        }
      }
    });
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<void> connectToDeviceAndListen(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
    print("Connected to ${device.platformName}");
    _connectedDevice = device;

    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString().toLowerCase() == targetServiceUUID.toLowerCase()) {
        for (BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid.toString().toLowerCase() == targetCharacteristicUUID.toLowerCase()) {
            _writeCharacteristic = c;

            await c.setNotifyValue(true);

            // Cancel old subscription if any
            await _characteristicSubscription?.cancel();

            _characteristicSubscription = c.value.listen((value) {
              final decoded = utf8.decode(value);
              print("Received from ESP32: $decoded");
              _receivedDataController.add(decoded);
            });

            await sendData("Hello from Flutter");
            break;
          }
        }
      }
    }
  }

  Future<void> sendData(String data) async {
    if (_writeCharacteristic == null) {
      print("❌ No connected characteristic to write to.");
      return;
    }

    try {
      await _writeCharacteristic!.write(
        utf8.encode(data),
        withoutResponse: false,
      );
      print("✅ Sent data: $data");
    } catch (e) {
      print("❌ Error sending data: $e");
    }
  }

  Future<void> disconnect() async {
    try {
      await stopScan();
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        print("Disconnected from ${_connectedDevice!.platformName}");
      }
      _writeCharacteristic = null;
      _connectedDevice = null;

      await _characteristicSubscription?.cancel();
      _characteristicSubscription = null;

      // Note: DO NOT close the StreamController
    } catch (e) {
      print("Error during disconnect: $e");
    }
  }

  Stream<BluetoothAdapterState> get bluetoothStateStream => FlutterBluePlus.adapterState;
}
