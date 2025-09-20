import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  static final clientIdentifier = dotenv.get('HIVEMQ_CLUSTER_IDENTIFIER');
  static final clusterUrl = dotenv.get('HIVEMQ_CLUSTER_URL');
  static final clusterPort = dotenv.getInt('HIVEMQ_CLUSTER_PORT');
  static final clusterUsername = dotenv.get('HIVEMQ_CLUSTER_USERNAME');
  static final clusterPassword = dotenv.get('HIVEMQ_CLUSTER_PASSWORD');
  static final supabaseUrl = dotenv.get('SUPABASE_URL');
  static final supabaseAnonKey = dotenv.get('SUPABASE_ANONKEY');
  static final domainURL = dotenv.get('DOMAIN_URL');
}
