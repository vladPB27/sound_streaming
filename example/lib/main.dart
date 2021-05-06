import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:sound_stream/sound_stream.dart';
import 'package:web_socket_channel/io.dart';
import 'package:hexcolor/hexcolor.dart';
// Change this URL to your own
// const _SERVER_URL = 'ws://192.168.0.1.ngrok.io';
// const _SERVER_URL = 'ws://192.168.0.1';
const _PORT = 8888;
// const _SERVER_URL = 'ws://192.168.71.10:8888';
const _SERVER_URL = 'ws://192.168.1.22:8888';
// const _SERVER_URL = 'ws://192.168.71.115';

void main() {
  // runApp(MyApp());
  runApp(MaterialApp(
    home: InitialPage(),
  ));
}

// Route<dynamic> generateRoute(RouteSettings settings) {
//   switch (settings.name) {
//     case 'Home':
//       return MaterialPageRoute(builder: (_) => Home());
//     // case 'browser':
//     //   return MaterialPageRoute(
//     //       builder: (_) => DevicesListScreen(deviceType: DeviceType.browser));
//     // case 'advertiser':
//     //   return MaterialPageRoute(
//     //       builder: (_) => DevicesListScreen(deviceType: DeviceType.advertiser));
//     default:
//       return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(
//                 child: Text('No route defined for ${settings.name}')),
//           ));
//   }
// }


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _networkInterface;

  RecorderStream _recorder = RecorderStream();
  PlayerStream _player = PlayerStream();

  bool _isRecording = false;
  bool _isPlaying = false;

  StreamSubscription _recorderStatus;
  StreamSubscription _playerStatus;
  StreamSubscription _audioStream;

  final channel = IOWebSocketChannel.connect(_SERVER_URL);

  @override
  void initState() {
    super.initState();

    // _runServer();

    initPlugin();

    ///ip address
    NetworkInterface.list(includeLoopback: false, type: InternetAddressType.any)
        .then((List<NetworkInterface> interfaces) {
      setState( () {
        _networkInterface = "";
        interfaces.forEach((interface) {
          // _networkInterface += "### name: ${interface.name}\n";
          _networkInterface;
          int i = 0;
          interface.addresses.forEach((address) {
            _networkInterface += "${i++}) ${address.address}\n";
          });
        });
      });
    });

  }

  @override
  void dispose() {
    _recorderStatus?.cancel();
    _playerStatus?.cancel();
    _audioStream?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {

    channel.stream.listen((event) async {
      print(event);
      if (_isPlaying) _player.writeChunk(event);
    });

    _audioStream = _recorder.audioStream.listen((data) {
      channel.sink.add(data);
    });

    _recorderStatus = _recorder.status.listen((status) {
      if (mounted)
        setState(() {
          _isRecording = status == SoundStreamStatus.Playing;
        });
    });

    _playerStatus = _player.status.listen((status) {
      if (mounted)
        setState(() {
          _isPlaying = status == SoundStreamStatus.Playing;
        });
    });

    await Future.wait([
      _recorder.initialize(),
      _player.initialize(),
    ]);
  }

  void _startRecord() async {
    await _player.stop();
    await _recorder.start();
    setState(() {
      _isRecording = true;
    });
  }

  void _stopRecord() async {
    await _recorder.stop();
    await _player.start();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('nearvoice',
            style: TextStyle(color: Colors.lightGreenAccent),
          ),
          backgroundColor: HexColor('#006059'),
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/nearvoicefont.jpg'),
                  fit: BoxFit.cover
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTapDown: (tap) {
                  _startRecord();
                },
                onTapUp: (tap) {
                  _stopRecord();
                },
                onTapCancel: () {
                  _stopRecord();
                },
                child: Icon(
                  _isRecording ? Icons.mic_off : Icons.mic,
                  size: 128,
                ),
              ),
              Text("  $_networkInterface"),
              RaisedButton(
                color: Colors.lightGreen,
                textColor: Colors.white,
                onPressed: (){
                  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home2()));
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => InitialPage()),
                  );
                },
                // onPressed: () => Navigator.pushNamed(context, "Home2"),
                child: Text('Back'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// class Home2 extends StatefulWidget {
//   @override
//   _Home2State createState() => _Home2State();
// }
//
// class _Home2State extends State<Home2> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Text('Navigate to a new screen on Button click'),
//           backgroundColor: Colors.blueAccent),
//       body: Center(
//         child: FlatButton(
//           color: Colors.blueAccent,
//           textColor: Colors.white,
//           // onPressed: () {
//           //   Navigator.of(context).push(MaterialPageRoute(builder: (_)=>Home()));
//           // },
//           onPressed: () => Navigator.pushNamed(context, "Home2"),
//           child: Text('GO TO HOME'),
//         ),
//       ),
//     );
//   }
// }

class InitialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('nearvoice',
          style: TextStyle(color: Colors.lightGreenAccent),
        ),
        backgroundColor: HexColor('#006059'),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/app-04-home.jpg'),
                fit: BoxFit.cover
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RaisedButton(
              color: Colors.lightGreen,
              textColor: Colors.white,
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
                _runServer();
              },
              // onPressed: () => Navigator.pushNamed(context, "Home2"),
              child: Text('Create'),
            )
          ],
        ),
      ),
    );
  }
}

void showText(){
  print('test of a function');
}

void _runServer() async {
  final connections = Set<WebSocket>();
  HttpServer.bind('192.168.1.22', _PORT).then((HttpServer server) {
    print('[+]WebSocket listening at -- ws://192.168.71.115:$_PORT/');
    server.listen((HttpRequest request) {
      WebSocketTransformer.upgrade(request).then((WebSocket ws) {
        connections.add(ws);
        print('[+]Connected');
        ws.listen(
              (data) {
            // Broadcast data to all other clients
            for (var conn in connections) {
              if (conn != ws && conn.readyState == WebSocket.open) {
                conn.add(data);
              }
            }
          },
          onDone: () {
            connections.remove(ws);
            print('[-]Disconnected');
          },
          onError: (err) {
            connections.remove(ws);
            print('[!]Error -- ${err.toString()}');
          },
          cancelOnError: true,
        );
      }, onError: (err) => print('[!]Error -- ${err.toString()}'));
    }, onError: (err) => print('[!]Error -- ${err.toString()}'));
  }, onError: (err) => print('[!]Error -- ${err.toString()}'));
}


// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
//
// import 'package:sound_stream/sound_stream.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   RecorderStream _recorder = RecorderStream();
//   PlayerStream _player = PlayerStream();
//
//   List<Uint8List> _micChunks = [];
//   bool _isRecording = false;
//   bool _isPlaying = false;
//   bool _useSpeaker = false;
//
//   StreamSubscription _recorderStatus;
//   StreamSubscription _playerStatus;
//   StreamSubscription _audioStream;
//
//   @override
//   void initState() {
//     super.initState();
//     initPlugin();
//   }
//
//   @override
//   void dispose() {
//     _recorderStatus?.cancel();
//     _playerStatus?.cancel();
//     _audioStream?.cancel();
//     super.dispose();
//   }
//
//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlugin() async {
//     _recorderStatus = _recorder.status.listen((status) {
//       if (mounted)
//         setState(() {
//           _isRecording = status == SoundStreamStatus.Playing;
//         });
//     });
//
//     _audioStream = _recorder.audioStream.listen((data) {
//       if (_isPlaying) {
//         _player.writeChunk(data);
//       } else {
//         _micChunks.add(data);
//       }
//     });
//
//     _playerStatus = _player.status.listen((status) {
//       if (mounted)
//         setState(() {
//           _isPlaying = status == SoundStreamStatus.Playing;
//         });
//     });
//
//     await Future.wait([
//       _recorder.initialize(),
//       _player.initialize(),
//     ]);
//     // _player.usePhoneSpeaker(_useSpeaker);
//   }
//
//   void _play() async {
//     await _player.start();
//
//     if (_micChunks.isNotEmpty) {
//       for (var chunk in _micChunks) {
//         await _player.writeChunk(chunk);
//       }
//       _micChunks.clear();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 IconButton(
//                   iconSize: 96.0,
//                   icon: Icon(_isRecording ? Icons.mic_off : Icons.mic),
//                   onPressed: _isRecording ? _recorder.stop : _recorder.start,
//                 ),
//                 IconButton(
//                   iconSize: 96.0,
//                   icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//                   onPressed: _isPlaying ? _player.stop : _play,
//                 ),
//               ],
//             ),
//             IconButton(
//               iconSize: 96.0,
//               icon: Icon(_useSpeaker ? Icons.headset_off : Icons.headset),
//               onPressed: () {
//                 setState(() {
//                   _useSpeaker = !_useSpeaker;
//                   _player.usePhoneSpeaker(_useSpeaker);
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
