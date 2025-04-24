class MQTTConnStateEntity {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
  }

  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
}

enum MQTTAppConnectionState {
  connecting,
  connected,
  disconnected,
  connectedSubscribed,
  connectedUnsubscribed,
}
