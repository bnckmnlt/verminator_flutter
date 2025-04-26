import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/entities/mqtt_client.dart';
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
    'control/sifter',
    'control/relay',
    'control/conveyor',
    'control/rake',
    'layer/bedding',
    'layer/compost',
    'layer/fluid',
    'system/status',
    'system/device/info',
    'system/health',
    'system/current_cycle',
    'system/current_cycle/schedule',
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
        .startClean();
    print('Connecting to broker...');
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

        print('Received message: $message from topic: $topic');

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
              // _handleDeviceInfo(message, _beddingLayerController);
              _beddingLayerController.add(message);
              break;

            case 'layer/compost':
              // _handleDeviceInfo(message, _compostLayerController);
              _compostLayerController.add(message);
              break;

            case 'layer/fluid':
              // _handleDeviceInfo(message, _fluidLayerController);
              _fluidLayerController.add(message);
              break;

            default:
              print('Unknown topic: $topic');
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
