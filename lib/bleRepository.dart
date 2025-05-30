// lib/repositories/bluetooth_repository.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'core/bleservice.dart';

class BluetoothRepository {
  final BluetoothServices _service;

  BluetoothRepository(this._service);

  Future<void> initializeBluetooth(targetDeviceId) async {
    final supported = await _service.isSupported();
    if (!supported) {
      print("Bluetooth not supported by this device");
      return;
    }

    _service.bluetoothStateStream.listen((state) async {
      print("Bluetooth state: $state");

      if (state == BluetoothAdapterState.off) {
        await _service.turnOnBluetoothIfPossible();
      }

      if (state == BluetoothAdapterState.on) {
        await _service.startScanAndConnect(targetDeviceId: targetDeviceId);
      }
    });
  }

  Future<void> disconnect() async {
    await _service.disconnect();
  }


  Stream<String> get receivedDataStream => _service.receivedDataStream;

  Future<void> sendData(String data) async {
    await _service.sendData(data);
  }
}
