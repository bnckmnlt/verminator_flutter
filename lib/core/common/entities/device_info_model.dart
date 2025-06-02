class DeviceInfoModel {
  final String deviceUptime;
  final String deviceBoard;
  final String operatingSystem;
  final String cpuUsage;
  final String cpuTemperature;
  final String memoryUsage;
  final String networkInterface;
  final String storageUsage;

  DeviceInfoModel({
    required this.deviceUptime,
    required this.deviceBoard,
    required this.operatingSystem,
    required this.cpuUsage,
    required this.cpuTemperature,
    required this.memoryUsage,
    required this.networkInterface,
    required this.storageUsage,
  });

  factory DeviceInfoModel.fromJson(Map<String, String> json) {
    return DeviceInfoModel(
      deviceUptime: json["Device Uptime"] ?? '',
      deviceBoard: json["Device Board"] ?? '',
      operatingSystem: json["Operating System"] ?? '',
      cpuTemperature: json["CPU Temperature"] ?? '',
      networkInterface: json["Network Interface"] ?? '',
      cpuUsage: json["CPU Usage"] ?? '',
      memoryUsage: json["Memory Usage"] ?? '',
      storageUsage: json["Storage Usage"] ?? '',
    );
  }

  Map<String, String> toJson() {
    return {
      "Device Uptime": deviceUptime,
      "Device Board": deviceBoard,
      "Operating System": operatingSystem,
      "CPU Temperature": cpuTemperature,
      "Network Interface": networkInterface,
      "CPU Usage": cpuUsage,
      "Memory Usage": memoryUsage,
      "Storage Usage": storageUsage,
    };
  }

  bool hasValues() {
    return deviceUptime.isNotEmpty ||
        deviceBoard.isNotEmpty ||
        operatingSystem.isNotEmpty ||
        cpuUsage.isNotEmpty ||
        cpuTemperature.isNotEmpty ||
        memoryUsage.isNotEmpty ||
        networkInterface.isNotEmpty ||
        storageUsage.isNotEmpty;
  }
}
