import 'package:cloud_firestore/cloud_firestore.dart';

class SolarSystemModel {
  final String id;
  final String userId;
  final String name;
  final String status;
  final double chargeLevel;
  final double voltage;
  final double temperature;
  final double estLifeHours;
  final bool isLightOn;
  final DateTime updatedAt;

  SolarSystemModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.status,
    required this.chargeLevel,
    required this.voltage,
    required this.temperature,
    required this.estLifeHours,
    required this.isLightOn,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'status': status,
      'chargeLevel': chargeLevel,
      'voltage': voltage,
      'temperature': temperature,
      'estLifeHours': estLifeHours,
      'isLightOn': isLightOn,
      'updatedAt': updatedAt,
    };
  }

  factory SolarSystemModel.fromMap(Map<String, dynamic> map) {
    return SolarSystemModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      status: map['status'] ?? 'Safe',
      chargeLevel: (map['chargeLevel'] as num?)?.toDouble() ?? 0.0,
      voltage: (map['voltage'] as num?)?.toDouble() ?? 0.0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      estLifeHours: (map['estLifeHours'] as num?)?.toDouble() ?? 0.0,
      isLightOn: map['isLightOn'] ?? false,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
