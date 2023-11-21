import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MainPage extends StatefulWidget {
  final BluetoothDevice server;

  const MainPage({required this.server});

  @override
  _MainPage createState() => new _MainPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _MainPage extends State<MainPage> {
///////////////////Envio de mensaje///////////////////////////77
  static final clientID = 0;

  BluetoothConnection? connection;
  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  //bool get isConnected => (connection?.isConnected ?? false);

  bool get isConnected => connection != null && connection!.isConnected;
  bool isDisconnecting = false;

  String _displayText = 'Apagado';
  double _sliderValue = 0.0;
  String _entradsText = '0';

  Timer? _discoverableTimeoutTimer;

  bool _habS = false;
  bool _habR = false;
  bool _habE = true;
  bool _habL = false;

  void _recibir(String dato) {
    //_mostrarMensajeEmergente(context);
    if(dato=="1"){

   mostrarMensajeEmergente("Se recibio");
   
  
    }
 
    setState(() {
      _entradsText="";
      _entradsText = dato;
    });
  }

  void mostrarMensajeEmergente(String msn) {
    Fluttertoast.showToast(
      msg: msn,
      toastLength: Toast.LENGTH_SHORT, // Duración del mensaje
      gravity: ToastGravity.BOTTOM, // Ubicación en la pantalla
      backgroundColor: Colors.black, // Color de fondo
      textColor: Colors.white, // Color del texto
      fontSize: 16.0, // Tamaño del texto
    );
  }

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {});
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
        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
      });
    });

/////////////////Envio de mensaje//////////////
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {});
/////////////////////Envio de mensaje///////////////////////
  }

  @override
  void dispose() {
    _sendMessage('f');
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    
    super.dispose();
  }

  void _enviarInicio() async {
    if (textEditingController.text.isEmpty) {
      mostrarMensajeEmergente("Agreue un tiempo valido mayor a 0");
    } else {
      _sendMessage('#' + textEditingController.text);

      setState(() {
        _habE = false;
        _habS = true;
      });
    }
  }

  void _enviarSlider(String value) async {
    _sendMessage(value);
  }

  void _enviarStart(String name) async {
    setState(() {
      _displayText = name;
      _habS = false;
      _habR = true;
      _habE = false;
      _habL = true;
      _sendMessage("*s");
    });
  }

  void _enviarReset(String name) async {
    setState(() {
      _displayText = name;
      _habE = true;
      _habR = false;
      _habL = false;
      _sliderValue = 0;
      _sendMessage("*r");
    });
  }

  @override
  Widget build(BuildContext context) {
    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      appBar: AppBar(
        title: (isConnecting
            ? Text('Connecting to $serverName...',
                style: const TextStyle(fontSize: 20.0))
            : isConnected
                ? Text('Live with $serverName',
                    style: const TextStyle(fontSize: 20.0))
                : Text('Chat log with $serverName',
                    style: const TextStyle(fontSize: 20.0))),
      ),
      body: Container(
        alignment: Alignment.center,
        child: ListView(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(15)),
            const Divider(
              height: 50,
              color: Color.fromRGBO(33, 148, 242, 50),
            ),
            Text(_entradsText),
            // ignore: prefer_adjacent_string_concatenation
            Text('Transcurrido(min):'+" "+ _entradsText,
                
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 20.0)),
            const Divider(
              height: 50,
              color: Color.fromRGBO(33, 148, 242, 50),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                const SizedBox(width: 0, height: 50),

                ElevatedButton(
                  onPressed: _habS ? () => _enviarStart("Iniciado") : null,
                  child: const Text("Start", style: TextStyle(fontSize: 24.0)),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  child: Text("Reset", style: TextStyle(fontSize: 24.0)),
                  onPressed: _habR ? () => _enviarReset("Apagado") : null,
                ),
                //Cambio(_definir ),
                SizedBox(width: 16.0),
                Text(
                  _displayText, // Mostrar el texto actual
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                //ElevatedButton(child: Text("",), onPressed: (){_cambiarTexto();},),
              ],
            ),
            const Divider(
              height: 50,
              color: Color.fromRGBO(33, 148, 242, 50),
            ),
          
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text('Intesidad de vibracion: ${_sliderValue.toInt()}',
                    style: TextStyle(fontSize: 24.0)),
                Slider(
                  value: _sliderValue,
                  onChanged: _habL
                      ? (newValue) {
                          setState(() {
                            _sliderValue = newValue;
                            String valN = (_sliderValue.toInt()).toString();

                            _sendMessage(valN);
                          });
                        }
                      : null,
                  min: 0.0,
                  max: 100.0,
                ),
              ],
            ),
            const Divider(
              height: 50,
              color: Color.fromRGBO(33, 148, 242, 50),
            ),
            TextField(
              controller: textEditingController,
              style: TextStyle(
                fontSize: 20,
              ),
              decoration: InputDecoration(
                hintText: 'Ingrese el tiempo de duracion (min)',
              ),
            ),
            const Divider(
              height: 50,
              color: Color.fromRGBO(33, 148, 242, 50),
            ),
            ElevatedButton(
              child: Text("Enviar", style: TextStyle(fontSize: 24.0)),
              onPressed: isConnected && _habE ? () => _enviarInicio() : null,
            ),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(data);

    int index = buffer.indexOf(13);

    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );

        _recibir(_messageBuffer);

        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
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

    void _mostrarMensajeEmergente(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tiempo Finalizado'),
          content: Text(_entradsText),
          actions: [
            TextButton(
              onPressed: () {
                // Cerrar el mensaje emergente al presionar el botón "Cerrar"
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
