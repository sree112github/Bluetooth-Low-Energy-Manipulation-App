// lib/screens/ble_scan_page.dart
import 'package:firstapp/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ble provider.dart';


class BleScanPage extends StatefulWidget {
  const BleScanPage({super.key});

  @override
  State<BleScanPage> createState() => _BleScanPageState();
}

class _BleScanPageState extends State<BleScanPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
void dispose() {
    Provider.of<BluetoothProvider>(context, listen: false).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _textController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text("BLE ESP32 Demo")),
      body: Center(
        child: Consumer<BluetoothProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                ElevatedButton(onPressed: ()async{
                  await provider.initBluetooth("1C:69:20:93:E9:06");
                }, child: Text("Scan")),

                TextField(
                  controller: _textController,
                ),

                ElevatedButton(onPressed: ()async{
                  await provider.sendData(_textController.text);
                }, child: Text("sendData")),

                ElevatedButton(
                  onPressed: () async{
                   await Provider.of<BluetoothProvider>(context, listen: false).disconnect();

                  },
                  child: Text("Disconnect"),
                ),


                Text(
                  provider.receivedData!.isEmpty
                      ? "Waiting for ESP32..."

                      : "Received: ${provider.receivedData}",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
