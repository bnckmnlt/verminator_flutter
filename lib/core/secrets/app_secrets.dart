import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  static final clientIdentifier = dotenv.env['HIVEMQ_CLUSTER_IDENTIFIER'] ?? '';
  static final clusterUrl = dotenv.env['HIVEMQ_CLUSTER_URL'] ?? '';
  static final clusterPort = dotenv.env['HIVEMQ_CLUSTER_PORT'] ?? '';
  static final clusterUsername = dotenv.env['HIVEMQ_CLUSTER_USERNAME'] ?? '';
  static final clusterPassword = dotenv.env['HIVEMQ_CLUSTER_PASSWORD'] ?? '';
  static final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final supabaseAnonKey = dotenv.env['SUPABASE_ANONKEY'] ?? '';
}
