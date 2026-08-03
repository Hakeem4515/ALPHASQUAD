class SystemSettingsModel {
  final double backupReserve;
  final bool fastCharging;
  final String chargingSource;
  final bool overchargeProtection;
  final bool tempProtection;
  final bool surgeProtection;
  final bool smartScheduling;
  final bool criticalAlerts;
  final bool dailyEnergySummary;
  final bool deviceOfflineAlerts;
  final String language;
  final String tempUnit;

  SystemSettingsModel({
    required this.backupReserve,
    required this.fastCharging,
    required this.chargingSource,
    required this.overchargeProtection,
    required this.tempProtection,
    required this.surgeProtection,
    required this.smartScheduling,
    required this.criticalAlerts,
    required this.dailyEnergySummary,
    required this.deviceOfflineAlerts,
    required this.language,
    required this.tempUnit,
  });

  Map<String, dynamic> toMap() {
    return {
      'backupReserve': backupReserve,
      'fastCharging': fastCharging,
      'chargingSource': chargingSource,
      'overchargeProtection': overchargeProtection,
      'tempProtection': tempProtection,
      'surgeProtection': surgeProtection,
      'smartScheduling': smartScheduling,
      'criticalAlerts': criticalAlerts,
      'dailyEnergySummary': dailyEnergySummary,
      'deviceOfflineAlerts': deviceOfflineAlerts,
      'language': language,
      'tempUnit': tempUnit,
    };
  }

  factory SystemSettingsModel.fromMap(Map<String, dynamic> map) {
    return SystemSettingsModel(
      backupReserve: (map['backupReserve'] as num?)?.toDouble() ?? 20.0,
      fastCharging: map['fastCharging'] ?? true,
      chargingSource: map['chargingSource'] ?? 'Solar Only',
      overchargeProtection: map['overchargeProtection'] ?? true,
      tempProtection: map['tempProtection'] ?? true,
      surgeProtection: map['surgeProtection'] ?? false,
      smartScheduling: map['smartScheduling'] ?? true,
      criticalAlerts: map['criticalAlerts'] ?? true,
      dailyEnergySummary: map['dailyEnergySummary'] ?? false,
      deviceOfflineAlerts: map['deviceOfflineAlerts'] ?? true,
      language: map['language'] ?? 'English',
      tempUnit: map['tempUnit'] ?? 'Celsius (°C)',
    );
  }
}
