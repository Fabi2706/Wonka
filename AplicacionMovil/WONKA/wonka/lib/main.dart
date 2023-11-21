import 'package:flutter/material.dart';
import 'package:wonka/IrABluetooth.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false, // Esta línea elimina el banner de depuración.
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {

    //Retorno a la clase MyBlue que se encuentra en IrBluetooth para buscar dispositivos emparejados
    return const MaterialApp(home:MyBlue(server: BluetoothDevice(address: "123")));

  }
}