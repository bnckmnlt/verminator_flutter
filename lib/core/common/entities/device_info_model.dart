class DeviceInfoModel {
  final String expeditionStatus;
  final String deviceUptime;
  final String deviceBoard;
  final String operatingSystem;
  final String cpuUsage;
  final String cpuTemperature;
  final String memoryUsage;
  final String networkInterface;
  final String storageUsage;
  final String pressure;

  DeviceInfoModel({
    required this.expeditionStatus,
    required this.deviceUptime,
    required this.deviceBoard,
    required this.operatingSystem,
    required this.cpuUsage,
    required this.cpuTemperature,
    required this.memoryUsage,
    required this.networkInterface,
    required this.storageUsage,
    required this.pressure,
  });

  factory DeviceInfoModel.fromJson(Map<String, String> json) {
    return DeviceInfoModel(
      expeditionStatus: json["Expedition Status"] ?? '',
      deviceUptime: json["Device Uptime"] ?? '',
      deviceBoard: json["Device Board"] ?? '',
      operatingSystem: json["Operating System"] ?? '',
      cpuTemperature: json["CPU Temperature"] ?? '',
      networkInterface: json["Network Interface"] ?? '',
      cpuUsage: json["CPU Usage"] ?? '',
      memoryUsage: json["Memory Usage"] ?? '',
      storageUsage: json["Storage Usage"] ?? '',
      pressure: json["Pressure"] ?? '',
    );
  }

  Map<String, String> toJson() {
    return {
      "Expedition Status": expeditionStatus,
      "Device Uptime": deviceUptime,
      "Device Board": deviceBoard,
      "Operating System": operatingSystem,
      "CPU Temperature": cpuTemperature,
      "Network Interface": networkInterface,
      "CPU Usage": cpuUsage,
      "Memory Usage": memoryUsage,
      "Storage Usage": storageUsage,
      "Pressure": pressure,
    };
  }

  bool hasValues() {
    return expeditionStatus.isNotEmpty && deviceUptime.isNotEmpty ||
        deviceBoard.isNotEmpty ||
        operatingSystem.isNotEmpty ||
        cpuUsage.isNotEmpty ||
        cpuTemperature.isNotEmpty ||
        memoryUsage.isNotEmpty ||
        networkInterface.isNotEmpty ||
        storageUsage.isNotEmpty ||
        pressure.isNotEmpty;
  }
}
