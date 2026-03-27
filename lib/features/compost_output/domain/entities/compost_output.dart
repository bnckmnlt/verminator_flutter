class CompostOutput {
  final int id;
  final int scheduleId;
  final NPK beddingNpk;
  final NPK compostNpk;
  final double vermiteaTds;
  final double compostProduced;
  final double vermiteaProduced;
  final String releasedAt;

  CompostOutput({
    required this.id,
    required this.scheduleId,
    required this.beddingNpk,
    required this.compostNpk,
    required this.vermiteaTds,
    required this.compostProduced,
    required this.vermiteaProduced,
    required this.releasedAt,
  });
}

class NPK {
  final int nitrogen;
  final int phosphorus;
  final int potassium;

  NPK({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  });
}

class NPKModel extends NPK {
  NPKModel({
    required super.nitrogen,
    required super.phosphorus,
    required super.potassium,
  });

  factory NPKModel.fromJson(Map<String, dynamic> json) {
    return NPKModel(
      nitrogen: json['nitrogen'] as int,
      phosphorus: json['phosphorus'] as int,
      potassium: json['potassium'] as int,
    );
  }
}
