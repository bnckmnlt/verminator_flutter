part of 'log_bloc.dart';

@immutable
sealed class LogEvent {}

final class LogList extends LogEvent {}
