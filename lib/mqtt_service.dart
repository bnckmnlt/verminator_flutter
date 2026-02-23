import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/entities/mqtt_client.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'main.dart';

class MqttService extends ChangeNotifier {
  bool isConnected = false;

  final MQTTConnStateEntity _connState = MQTTConnStateEntity();
  late MqttServerClient _client;

  final List<String> _topics = [
    'control/monitoring/camera',
    'control/monitoring/thermal',
    'layer/bedding',
    'layer/compost',
    'layer/fluid',
    'system/current_cycle',
    'system/status',
    'system/health',
    'system/info',
    'system/settings',
    'schedule/sifter',
    'schedule/aeration',
    'feedback/conveyor',
    'feedback/rake',
    'feedback/sifter',
    ...Constants.relayFeedbackTopics,
  ];
  final Map<String, dynamic> _lastKnownValues = {};

  StreamSubscription<List<MqttReceivedMessage>>? _messageSubscription;

  final StreamController<String> _systemStatusController =
      StreamController<String>.broadcast();
  final StreamController<String> _controlMonitoringCamera =
      StreamController<String>.broadcast();
  final StreamController<String> _controlMonitoringThermal =
      StreamController<String>.broadcast();
  final StreamController<String> _conveyorFeedbackController =
      StreamController<String>.broadcast();
  final StreamController<String> _rakeFeedbackController =
      StreamController<String>.broadcast();
  final StreamController<String> _sifterFeedbackController =
      StreamController<String>.broadcast();
  final StreamController<String> _mistingFeedbackController =
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
  final StreamController<Map<String, String>> _systemSettingsController =
      StreamController<Map<String, String>>.broadcast();

  Stream<String> get systemStatusStream => _systemStatusController.stream;
  Stream<String> get controlCameraStream => _controlMonitoringCamera.stream;
  Stream<String> get controlThermalStream => _controlMonitoringThermal.stream;
  Stream<String> get conveyorFeedbackStream =>
      _conveyorFeedbackController.stream;
  Stream<String> get sifterFeedbackStream => _sifterFeedbackController.stream;
  Stream<String> get mistingFeedbackStream => _mistingFeedbackController.stream;
  Stream<String> get rakeFeedbackStream => _rakeFeedbackController.stream;
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
  Stream<Map<String, String>> get systemSettingsStream =>
      _systemSettingsController.stream;

  String? get lastControlCamera =>
      _lastKnownValues['control/monitoring/camera'] as String?;
  String? get lastControlThermal =>
      _lastKnownValues['control/monitoring/thermal'] as String?;
  String? get lastSystemStatus => _lastKnownValues['system/status'] as String?;
  Map<String, dynamic>? get lastBeddingLayer =>
      _lastKnownValues['layer/bedding'] as Map<String, dynamic>?;
  Map<String, dynamic>? get lastCompostLayer =>
      _lastKnownValues['layer/compost'] as Map<String, dynamic>?;
  Map<String, dynamic>? get lastFluidLayer =>
      _lastKnownValues['layer/fluid'] as Map<String, dynamic>?;
  Map<String, dynamic>? get lastSystemHealth =>
      _lastKnownValues['system/health'] as Map<String, dynamic>?;
  Map<String, String>? get lastDeviceInfo =>
      _lastKnownValues['system/info'] as Map<String, String>?;
  Map<String, String>? get lastSystemSettings =>
      _lastKnownValues['system/settings'] as Map<String, String>?;

  void initializeMQTTClient() {
    _client = MqttServerClient.withPort(
      AppSecrets.clusterUrl,
      AppSecrets.clientIdentifier.toString(),
      AppSecrets.clusterPort,
    );

    _client.useWebSocket = true;
    _client.securityContext = SecurityContext.defaultContext;
    _client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    _client.logging(on: true);
    _client.setProtocolV311();
    _client.keepAlivePeriod = 20;
    _client.autoReconnect = true;

    _client.onDisconnected = onDisconnected;
    _client.onConnected = onConnected;
    _client.onSubscribed = onSubscribed;
    _client.onUnsubscribed = onUnsubscribed;
    _client.onAutoReconnect = onAutoReconnect;
    _client.onAutoReconnected = onAutoReconnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(AppSecrets.clientIdentifier)
        .authenticateAs(
          AppSecrets.clusterUsername.toString(),
          AppSecrets.clusterPassword.toString(),
        )
        .startClean();
    _client.connectionMessage = connMess;
  }

  Future<void> connect() async {
    initializeMQTTClient();
    try {
      log.info('Start client connecting....');
      _connState.setAppConnectionState(MQTTAppConnectionState.connecting);
      updateState();
      await _client.connect();
    } on Exception catch (e) {
      log.shout('Client exception - $e');
      disconnect();
    }
  }

  void onConnected() {
    log.info('Connected to MQTT broker');
    _connState.setAppConnectionState(MQTTAppConnectionState.connected);
    isConnected = true;
    updateState();
    subScribeToTopics();
    _setupMessageListener();
  }

  void onAutoReconnect() {
    log.info('Auto reconnecting to MQTT broker...');
    _connState.setAppConnectionState(MQTTAppConnectionState.connecting);
    isConnected = false;
    updateState();
  }

  void onAutoReconnected() {
    log.info('Auto reconnected to MQTT broker');
    _connState.setAppConnectionState(MQTTAppConnectionState.connected);
    isConnected = true;
    updateState();
    subScribeToTopics();

    _reEmitLastKnownValues();
  }

  void _setupMessageListener() {
    _messageSubscription?.cancel();

    _messageSubscription = _client.updates!.listen(
      (List<MqttReceivedMessage<MqttMessage?>>? c) {
        if (c == null || c.isEmpty) return;

        final MqttPublishMessage recMessage =
            c[0].payload as MqttPublishMessage;
        final String message = MqttPublishPayload.bytesToStringAsString(
            recMessage.payload.message);
        final String topic = c[0].topic;

        _processMessage(topic, message);
        notifyListeners();
      },
      onError: (error) {
        log.shout('Error in message stream: $error');
      },
      cancelOnError: false,
    );
  }

  void _processMessage(String topic, String message) {
    try {
      _lastKnownValues[topic] = message;

      switch (topic) {
        case 'system/status':
          _systemStatusController.add(message);
          break;

        case 'control/monitoring/thermal':
          _controlMonitoringThermal.add(message);
          break;

        case 'control/monitoring/camera':
          _controlMonitoringCamera.add(message);
          break;

        case 'feedback/conveyor':
          _conveyorFeedbackController.add(message);
          break;

        case 'feedback/rake':
          _rakeFeedbackController.add(message);
          break;

        case 'feedback/sifter':
          _sifterFeedbackController.add(message);
          break;

        case 'system/health':
          final Map<String, dynamic> healthData =
              jsonDecode(message) as Map<String, dynamic>;
          _lastKnownValues[topic] = healthData;
          _systemHealthController.add(healthData);
          break;

        case 'system/info':
          _handleJsonDecoding(message, _deviceInfoController, topic);
          break;

        case 'system/settings':
          _handleJsonDecoding(message, _systemSettingsController, topic);
          break;

        case 'layer/bedding':
          final Map<String, dynamic> beddingData =
              jsonDecode(message) as Map<String, dynamic>;
          _lastKnownValues[topic] = beddingData;
          _beddingLayerController.add(message);
          break;

        case 'layer/compost':
          final Map<String, dynamic> compostData =
              jsonDecode(message) as Map<String, dynamic>;
          _lastKnownValues[topic] = compostData;
          _compostLayerController.add(message);
          break;

        case 'layer/fluid':
          final Map<String, dynamic> fluidData =
              jsonDecode(message) as Map<String, dynamic>;
          _lastKnownValues[topic] = fluidData;
          _fluidLayerController.add(message);
          break;

        default:
          final relayRegExp = RegExp(r'^feedback/relay/([01])/([0-3])$');
          final match = relayRegExp.firstMatch(topic);
          if (match != null) {
            final int board = int.parse(match.group(1)!);
            final int pin = int.parse(match.group(2)!);

            final relayData = {
              'board': board,
              'pin': pin,
              'state': message,
            };

            _lastKnownValues[topic] = relayData;
            _relayFeedbackController.add(relayData);
          } else {
            log.warning('Unknown topic: $topic');
          }
      }
    } catch (e) {
      log.shout('Error processing message from topic $topic: $e');
    }
  }

  void _reEmitLastKnownValues() {
    log.info('Re-emitting last known values to streams');

    _lastKnownValues.forEach((topic, value) {
      try {
        if (value is String) {
          _processMessage(topic, value);
        } else if (value is Map<String, dynamic>) {
          _processMessage(topic, jsonEncode(value));
        }
      } catch (e) {
        log.warning('Error re-emitting value for topic $topic: $e');
      }
    });
  }

  void onSubscribed(String topic) {
    log.info('Subscription confirmed for topic $topic');
    _connState
        .setAppConnectionState(MQTTAppConnectionState.connectedSubscribed);
    updateState();
  }

  void onUnsubscribed(String? topic) {
    log.warning('Unsubscribed confirmed for topic $topic');
    _connState
        .setAppConnectionState(MQTTAppConnectionState.connectedUnsubscribed);
    updateState();
  }

  void onDisconnected() {
    log.shout('Disconnected from the broker.');
    isConnected = false;
    _connState.setAppConnectionState(MQTTAppConnectionState.disconnected);
    updateState();
  }

  void subScribeToTopics() {
    for (var topic in _topics) {
      _client.subscribe(topic, MqttQos.atLeastOnce);
      log.info('Subscribed to topic: $topic');
    }
  }

  void unsubScribeToTopics() {
    for (var topic in _topics) {
      _client.unsubscribe(topic);
      log.warning('Unsubscribed from topic: $topic');
    }
  }

  void disconnect() {
    log.shout('Disconnecting from broker');
    _messageSubscription?.cancel();
    _client.disconnect();
  }

  void updateState() {
    notifyListeners();
  }

  void publish(String topic, String message,
      {bool retain = false, MqttQos qos = MqttQos.exactlyOnce}) {
    if (!isConnected) {
      log.warning('Cannot publish - not connected to broker');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    _client.publishMessage(topic, qos, builder.payload!, retain: retain);
    log.info(
        'Message published to $topic: $message, Retained: $retain, QoS: $qos');
  }

  void _handleJsonDecoding(String message,
      StreamController<Map<String, String>> controller, String topic) {
    try {
      final Map<String, dynamic> parsedMessage = json.decode(message);
      final Map<String, String> jsonPayload = parsedMessage.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      _lastKnownValues[topic] = jsonPayload;
      controller.add(jsonPayload);
    } catch (e) {
      log.shout('Error parsing JSON message from $topic: $e');
    }
  }

  Stream<String> getRelayPinState(int board, int pin) {
    final topic = 'feedback/relay/$board/$pin';

    return Stream.multi((controller) {
      final lastValue = _lastKnownValues[topic];
      if (lastValue != null && lastValue is Map<String, dynamic>) {
        controller.add(lastValue['state'] as String);
      }

      final subscription = relayFeedbackStream
          .where((event) => event['board'] == board && event['pin'] == pin)
          .map((event) => event['state'] as String)
          .listen(
            controller.add,
            onError: controller.addError,
          );

      controller.onCancel = () => subscription.cancel();
    });
  }

  String? getLastRelayPinState(int board, int pin) {
    final topic = 'feedback/relay/$board/$pin';
    final lastValue = _lastKnownValues[topic];
    if (lastValue != null && lastValue is Map<String, dynamic>) {
      return lastValue['state'] as String?;
    }
    return null;
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();

    _systemStatusController.close();
    _controlMonitoringCamera.close();
    _controlMonitoringThermal.close();
    _conveyorFeedbackController.close();
    _rakeFeedbackController.close();
    _sifterFeedbackController.close();
    _mistingFeedbackController.close();
    _systemHealthController.close();
    _currentCycleController.close();
    _currentScheduleController.close();
    _deviceInfoController.close();
    _beddingLayerController.close();
    _compostLayerController.close();
    _fluidLayerController.close();
    _relayFeedbackController.close();
    _systemSettingsController.close();

    unsubScribeToTopics();
    disconnect();

    super.dispose();
  }
}
