import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SendrecvScreen extends StatefulWidget {
  @override
  _SendrecvScreenState createState() => _SendrecvScreenState();
}

class _SendrecvScreenState extends State<SendrecvScreen> {
  WebSocketChannel _channel;
  MediaStream _localStream;
  RTCPeerConnection _peerConnection;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;

  Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ]
  };

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sendrecv'),
        actions: _inCalling
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.switch_video),
                  onPressed: _toggleCamera,
                )
              ]
            : null,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: orientation == Orientation.portrait
                        ? const FractionalOffset(0.5, 0.1)
                        : const FractionalOffset(0.0, 0.5),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      width: 320.0,
                      height: 240.0,
                      child: RTCVideoView(_localRenderer),
                      decoration: BoxDecoration(color: Colors.black54),
                    ),
                  ),
                  Align(
                    alignment: orientation == Orientation.portrait
                        ? const FractionalOffset(0.5, 0.9)
                        : const FractionalOffset(1.0, 0.5),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      width: 320.0,
                      height: 240.0,
                      child: RTCVideoView(_remoteRenderer),
                      decoration: BoxDecoration(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _call,
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }

  @override
  deactivate() {
    super.deactivate();
    _hangUp();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _onSignalingState(RTCSignalingState state) {
    print(state);
  }

  _onIceGatheringState(RTCIceGatheringState state) {
    print(state);
  }

  _onIceConnectionState(RTCIceConnectionState state) {
    print(state);
  }

  _onAddStream(MediaStream stream) {
    print('addStream: ' + stream.id);
    _remoteRenderer.srcObject = stream;
  }

  _onRemoveStream(MediaStream stream) {
    print('removeStream: ' + stream.id);
    _remoteRenderer.srcObject = null;
  }

  _onCandidate(RTCIceCandidate candidate) {
    print('onCandidate: ' + candidate.candidate);

    _channel.sink.add(jsonEncode(<String, dynamic>{
      "type": "candidate",
      "ice": {
        "candidate": candidate.candidate,
        "sdpMid": candidate.sdpMid,
        "sdpMLineIndex": candidate.sdpMlineIndex
      },
    }));
  }

  _onRenegotiationNeeded() {
    print('RenegotiationNeeded');
  }

  Future<void> _prepare() async {
    final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": {
        "mandatory": {
          "minWidth":
              '640', // Provide your own width, height and frame rate here
          "minHeight": '480',
          "minFrameRate": '30',
        },
        "facingMode": "user",
        "optional": [],
      }
    };

    if (_peerConnection != null) return;

    try {
      _localStream = await navigator.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      await _createPeerConnection();
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  Future<void> _createPeerConnection() async {
    if (_peerConnection != null) {
      _peerConnection.close();
    }

    _peerConnection = await createPeerConnection(configuration, {});
    _peerConnection.onSignalingState = _onSignalingState;
    _peerConnection.onIceGatheringState = _onIceGatheringState;
    _peerConnection.onIceConnectionState = _onIceConnectionState;
    _peerConnection.onAddStream = _onAddStream;
    _peerConnection.onRemoveStream = _onRemoveStream;
    _peerConnection.onIceCandidate = _onCandidate;
    _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;

    _peerConnection.addStream(_localStream);
  }

  _call() async {
    await _prepare();

    final url = "wss://ayame-lite.shiguredo.jp/signaling";
    if (_channel != null) {
      await _channel.sink.close();
    }
    _channel = IOWebSocketChannel.connect(url);

    final registerMessage = jsonEncode(<String, String>{
      "type": "register",
      "clientId": "${Random().nextInt(pow(2, 32).toInt())}",
      "roomId": "wapa5pow@ayame-test-sdk",
      "key": "vkfKgOwAwiNkwn5rPfc7lwfEEvedwkSnDnMpEmk6pmHrJ0WD",
    });
    _channel.sink.add(registerMessage);

    _channel.stream.listen((message) async {
      print(message);
      final jsonMessage = jsonDecode(message);
      final String messageType = jsonMessage['type'] as String ?? "";
      switch (messageType) {
        case "ping":
          _channel.sink.add(jsonEncode(<String, String>{
            "type": "pong",
          }));
          break;
        case "reject":
          final String reason = jsonMessage['reason'] ?? "Unknown error";
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(reason),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  )
                ],
              );
            },
          );
          break;
        case "accept":
          final iceServers = jsonMessage['iceServers'];
          if (iceServers != null) {
            configuration['iceServers'] = iceServers;
          }

          final bool isExistingUser = jsonMessage['isExistUser'];
          if (isExistingUser == null || isExistingUser) {
            // send offer to existing user
            final localDescription = await _peerConnection.createOffer({});
            _peerConnection.setLocalDescription(localDescription);
            _channel.sink.add(jsonEncode(localDescription.toMap()));
          } else {
            // wait for offer
          }
          break;
        case "candidate":
          var candidateMap = jsonMessage['ice'];
          RTCIceCandidate candidate = RTCIceCandidate(candidateMap['candidate'],
              candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);
          await _peerConnection.addCandidate(candidate);
          break;
        case "offer":
          await _createPeerConnection();
          final remoteDescription =
              RTCSessionDescription(jsonMessage['sdp'], jsonMessage['type']);
          await _peerConnection.setRemoteDescription(remoteDescription);
          final localDescription = await _peerConnection.createAnswer({});
          _peerConnection.setLocalDescription(localDescription);
          _channel.sink.add(jsonEncode(localDescription.toMap()));
          break;
        case "answer":
          final remoteDescription =
              RTCSessionDescription(jsonMessage['sdp'], jsonMessage['type']);
          await _peerConnection.setRemoteDescription(remoteDescription);
          break;
      }
    }, onError: (err) {
      print(err);
    }, onDone: () {
      print('done');
    });
  }

  _hangUp() async {
    try {
      await _channel?.sink?.close();
      await _localStream?.dispose();
      await _peerConnection?.close();
      _peerConnection = null;
      _localRenderer?.srcObject = null;
      _remoteRenderer?.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });
  }

  Future<bool> _toggleCamera() async {
    final videoTrack = _localStream
        ?.getVideoTracks()
        ?.firstWhere((track) => track.kind == "video");
    await videoTrack?.switchCamera();
  }
}
