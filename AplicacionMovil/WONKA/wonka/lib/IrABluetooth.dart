// ignore: file_names
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:wonka/MainPage.dart';
import 'package:wonka/SelectBondedDevicePage.dart';

class MyBlue extends StatefulWidget {
  final BluetoothDevice server;

  const MyBlue({super.key, required this.server});

  @override
  State<MyBlue> createState() => _MyBlue();
}

class _MyBlue extends State<MyBlue> {
  BluetoothConnection? connection;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  //bool get isConnected => (connection?.isConnected ?? false);

  bool get isConnected => connection != null && connection!.isConnected;
  bool isDisconnecting = false;

//////////////////////Envio de mensaje //////////////////////
  ///
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {});
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {});
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

      });
    });

/////////////////Envio de mensaje//////////////
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth'),
      ),
      body: Container(
        child: ListView(children: <Widget>[
          Divider(),

          //ListTile(title: const Text('General')),
          SwitchListTile(
            title: const Text('Enable Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              future() async {
                // async lambda seems to not working
                if (value)
                  await FlutterBluetoothSerial.instance.requestEnable();
                else
                  await FlutterBluetoothSerial.instance.requestDisable();
              }

              future().then((_) {
                setState(() {});
              });
            },
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text('Connect to paired device to chat'),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return SelectBondedDevicePage(checkAvailability: false);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  _startChat(context, selectedDevice);
                } else {
                  print('Connect -> no device selected');
                }
              },
            ),
          ),
        ]),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return MainPage(server: server); //ChatPage(server: server);
        },
      ),
    );
  }
}
