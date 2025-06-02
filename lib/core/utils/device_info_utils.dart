double calculateStorageUsage(String usedStorage, String maxStorage) {
  final double used =
      double.tryParse(usedStorage.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  final double max =
      double.tryParse(maxStorage.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 120;
  return (used / max).clamp(0.0, 1.0);
}

double calculateCpuUsage(String cpuUsage) {
  final double usage =
      double.tryParse(cpuUsage.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  return (usage / 100).clamp(0.0, 1.0);
}

double calculateMemoryUsage(String memoryUsage) {
  final double usage =
      double.tryParse(memoryUsage.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  return (usage / 100).clamp(0.0, 1.0);
}
