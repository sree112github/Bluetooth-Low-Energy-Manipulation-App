// lib/providers/bluetooth_provider.dart
import 'package:flutter/material.dart';
import 'bleRepository.dart';
import 'core/bleservice.dart';

class BluetoothProvider with ChangeNotifier {
  final BluetoothRepository _repository;
  final BluetoothServices _service;

  String? _receivedData = '';
  String? get receivedData => _receivedData;

  BluetoothProvider(this._repository, this._service) {
    _repository.receivedDataStream.listen((data) {
      _receivedData = data;
      notifyListeners();
    });
  }

  Future<void> initBluetooth(targetDeviceId) async {
    await _repository.initializeBluetooth(targetDeviceId);
  }

  Future<void> sendData(String data) async {
    await _repository.sendData(data);
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
    _receivedData = '' ;
    notifyListeners(); // optional if UI depends on it
  }


}
