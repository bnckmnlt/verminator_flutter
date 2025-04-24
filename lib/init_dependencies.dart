import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_vermicomposting/core/network/connection_checker.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/datasources/compost_schedule_remote_datasource.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/repositories/compost_schedule_repository_impl.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/repositories/compost_schedule_repository.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/create_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/list_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/patch_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/remove_compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/usecases/selectone_compost_schedule.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'init_dependencies.main.dart';
