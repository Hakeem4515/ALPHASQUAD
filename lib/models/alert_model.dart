import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String userId;
  final String title;
  final String subtitle;
  final String type; // 'Critical' or 'Warning'
  final DateTime time;
  final bool isDismissed;

  AlertModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.time,
    this.isDismissed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'time': time,
      'isDismissed': isDismissed,
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      type: map['type'] ?? 'Warning',
      time: (map['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDismissed: map['isDismissed'] ?? false,
    );
  }
}
