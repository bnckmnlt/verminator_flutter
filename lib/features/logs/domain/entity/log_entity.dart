class LogEntity {
  final int id;
  final LogSeverity logSeverity;
  final String message;
  final String createdAt;

  LogEntity({
    required this.id,
    required this.logSeverity,
    required this.message,
    required this.createdAt,
  });
}

enum LogSeverity {
  info,
  warn,
  error,
  fatal,
}
