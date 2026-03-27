import 'package:flutter_vermicomposting/core/utils/format_to_local_time.dart';
import 'package:flutter_vermicomposting/features/compost_output/domain/entities/compost_output.dart';

class CompostOutputModel extends CompostOutput {
  CompostOutputModel({
    required super.id,
    required super.scheduleId,
    required super.beddingNpk,
    required super.compostNpk,
    required super.vermiteaTds,
    required super.compostProduced,
    required super.vermiteaProduced,
    required super.releasedAt,
  });

  factory CompostOutputModel.fromJson(Map<String, dynamic> json) {
    return CompostOutputModel(
      id: json['id'] as int,
      scheduleId: json['schedule_id'] as int,
      beddingNpk:
          NPKModel.fromJson(json['bedding_npk'] as Map<String, dynamic>),
      compostNpk:
          NPKModel.fromJson(json['compost_npk'] as Map<String, dynamic>),
      vermiteaTds: json['vermitea_tds'] as double,
      compostProduced: json['compost_produced'] as double,
      vermiteaProduced: json['vermitea_produced'] as double,
      releasedAt: formatToLocalTime(json['released_at']),
    );
  }
}
