import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/entities/mqtt_client.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService extends ChangeNotifier {
  final MQTTConnStateEntity _connState = MQTTConnStateEntity();
  final MqttServerClient _client = MqttServerClient(
    AppSecrets.clusterUrl,
    '${AppSecrets.clientIdentifier ?? "defaultCluster"}-${Random().nextInt(1000000).toString().padLeft(6, '0')}',
  );
  final List<String> _topics = [
    'control/aeration',
    'control/fan',
    'control/pump',
    'control/vermijuice',
    'control/sifter',
    'control/relay',
    'control/conveyor',
    'control/rake',
    'control/monitoring/camera',
    'control/monitoring/thermal',
    'layer/bedding',
    'layer/compost',
    'layer/fluid',
    'layer/worms',
    'system/current_cycle',
    'system/status',
    'system/health',
    'system/device/info',
    'schedule/sifter',
    'schedule/aeration',
    ...Constants.relayFeedbackTopics,
  ];

  final StreamController<String> _systemStatusController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _systemHealthController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<int> _currentCycleController =
      StreamController<int>.broadcast();
  final StreamController<String> _currentScheduleController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, String>> _deviceInfoController =
      StreamController<Map<String, String>>.broadcast();
  final StreamController<String> _beddingLayerController =
      StreamController<String>.broadcast();
  final StreamController<String> _compostLayerController =
      StreamController<String>.broadcast();
  final StreamController<String> _fluidLayerController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _relayFeedbackController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<String> get systemStatusStream => _systemStatusController.stream;

  Stream<Map<String, dynamic>> get systemHealthStream =>
      _systemHealthController.stream;

  Stream<int> get currentCycleStream => _currentCycleController.stream;

  Stream<String> get currentScheduleStream => _currentScheduleController.stream;

  Stream<Map<String, String>> get deviceInfoStream =>
      _deviceInfoController.stream;

  Stream<String> get beddingLayerStream => _beddingLayerController.stream;

  Stream<String> get compostLayerStream => _compostLayerController.stream;

  Stream<String> get fluidLayerStream => _fluidLayerController.stream;

  Stream<Map<String, dynamic>> get relayFeedbackStream =>
      _relayFeedbackController.stream;

  void initializeMQTTClient() {
    _client.useWebSocket = true;
    _client.port = int.parse(AppSecrets.clusterPort);
    _client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    _client.logging(on: true);
    _client.setProtocolV311();
    _client.keepAlivePeriod = 20;

    _client.onDisconnected = onDisconnected;
    _client.onConnected = onConnected;
    _client.onSubscribed = onSubscribed;
    _client.onUnsubscribed = onUnsubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(AppSecrets.clientIdentifier)
        .authenticateAs(AppSecrets.clusterUsername.toString(),
            AppSecrets.clusterPassword.toString())
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connMess;
  }

  Future<void> connect() async {
    initializeMQTTClient();
    try {
      print('Start client connecting....');
      _connState.setAppConnectionState(MQTTAppConnectionState.connecting);
      updateState();
      await _client.connect();
    } on Exception catch (e) {
      print('Client exception - $e');
      disconnect();
    }
  }

  void onConnected() {
    _connState.setAppConnectionState(MQTTAppConnectionState.connected);
    updateState();
    subScribeToTopics();

    _client.updates!.listen(
      (List<MqttReceivedMessage<MqttMessage?>>? c) {
        final MqttPublishMessage recMessage =
            c![0].payload as MqttPublishMessage;
        final String message = MqttPublishPayload.bytesToStringAsString(
            recMessage.payload.message);
        final String topic = c[0].topic;

        try {
          switch (topic) {
            case 'system/status':
              _systemStatusController.add(message);
              break;

            case 'system/health':
              final Map<String, dynamic> healthData =
                  jsonDecode(message) as Map<String, dynamic>;
              _systemHealthController.add(healthData);
              break;

            case 'system/device/info':
              _handleDeviceInfo(message, _deviceInfoController);
              break;

            case 'layer/bedding':
              _beddingLayerController.add(message);
              break;

            case 'layer/compost':
              _compostLayerController.add(message);
              break;

            case 'layer/fluid':
              _fluidLayerController.add(message);
              break;

            default:
              final relayRegExp = RegExp(r'^feedback/relay/([01])/([0-3])$');
              final match = relayRegExp.firstMatch(topic);
              if (match != null) {
                final int board = int.parse(match.group(1)!);
                final int pin = int.parse(match.group(2)!);

                _relayFeedbackController.add({
                  'board': board,
                  'pin': pin,
                  'state': message,
                });
              } else {
                print('Unknown topic: $topic');
              }
          }
        } catch (e) {
          print('Error processing message from topic $topic: $e');
        }

        notifyListeners();
      },
    );
  }

  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
    _connState
        .setAppConnectionState(MQTTAppConnectionState.connectedSubscribed);
    updateState();
  }

  void onUnsubscribed(String? topic) {
    print('Unsubscribed confirmed for topic $topic');
    _connState
        .setAppConnectionState(MQTTAppConnectionState.connectedUnsubscribed);
    updateState();
  }

  void onDisconnected() {
    print('Disconnected from the broker.');
    _connState.setAppConnectionState(MQTTAppConnectionState.disconnected);
    updateState();
  }

  void subScribeToTopics() {
    for (var topic in _topics) {
      _client.subscribe(topic, MqttQos.atLeastOnce);
      print('Subscribed to topic: $topic');
    }
  }

  void unsubScribeToTopics() {
    for (var topic in _topics) {
      _client.unsubscribe(topic);
      print('Unsubscribed from topic: $topic');
    }
  }

  void disconnect() {
    print('Disconnected');
    _client.disconnect();
  }

  void updateState() {
    notifyListeners();
  }

  void publish(String topic, String message,
      {bool retain = false, MqttQos qos = MqttQos.exactlyOnce}) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    _client.publishMessage(topic, qos, builder.payload!, retain: retain);
    print('Message published: $message, Retained: $retain, QoS: $qos');
  }

  void _handleDeviceInfo(
      String message, StreamController<Map<String, String>> controller) {
    try {
      final Map<String, dynamic> parsedMessage = json.decode(message);
      final Map<String, String> deviceInfo = parsedMessage.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      controller.add(deviceInfo);
    } catch (e) {
      print('Error parsing device info message: $e');
    }
  }

  Stream<String> getRelayPinState(int board, int pin) {
    return relayFeedbackStream
        .where((event) => event['board'] == board && event['pin'] == pin)
        .map((event) => event['state'] as String);
  }

  @override
  void dispose() {
    _systemStatusController.close();
    _systemHealthController.close();
    _currentCycleController.close();
    _currentScheduleController.close();
    _deviceInfoController.close();
    _beddingLayerController.close();
    _compostLayerController.close();
    _fluidLayerController.close();

    unsubScribeToTopics();

    super.dispose();
  }
}
