class WeatherModel {
  final double temp;
  final String condition;
  final int cloudCover;
  final int humidity;
  final String solarLevel;

  WeatherModel({
    required this.temp,
    required this.condition,
    required this.cloudCover,
    required this.humidity,
    required this.solarLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'temp': temp,
      'condition': condition,
      'cloudCover': cloudCover,
      'humidity': humidity,
      'solarLevel': solarLevel,
    };
  }

  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      temp: (map['temp'] as num?)?.toDouble() ?? 31.0,
      condition: map['condition'] ?? 'Sunny',
      cloudCover: (map['cloudCover'] as num?)?.toInt() ?? 15,
      humidity: (map['humidity'] as num?)?.toInt() ?? 42,
      solarLevel: map['solarLevel'] ?? 'High',
    );
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final clouds = json['clouds'] as Map<String, dynamic>? ?? {};
    final weatherList = json['weather'] as List? ?? [];
    
    String condition = 'Sunny';
    if (weatherList.isNotEmpty) {
      final weatherMain = weatherList[0]['main']?.toString() ?? '';
      if (weatherMain.toLowerCase().contains('clear')) {
        condition = 'Sunny';
      } else if (weatherMain.toLowerCase().contains('cloud')) {
        condition = 'Cloudy';
      } else if (weatherMain.toLowerCase().contains('rain') || weatherMain.toLowerCase().contains('drizzle')) {
        condition = 'Rainy';
      } else if (weatherMain.toLowerCase().contains('snow')) {
        condition = 'Snowy';
      } else {
        condition = weatherMain.isNotEmpty ? weatherMain : 'Sunny';
      }
    }

    final double temp = (main['temp'] as num? ?? 31.0).toDouble();
    final int cloudCover = (clouds['all'] as num? ?? 15).toInt();
    final int humidity = (main['humidity'] as num? ?? 42).toInt();

    // Estimate solar potential based on cloud cover
    String solarLevel = 'High';
    if (cloudCover < 15) {
      solarLevel = 'Extreme';
    } else if (cloudCover < 35) {
      solarLevel = 'High';
    } else if (cloudCover < 65) {
      solarLevel = 'Moderate';
    } else {
      solarLevel = 'Low';
    }

    return WeatherModel(
      temp: temp,
      condition: condition,
      cloudCover: cloudCover,
      humidity: humidity,
      solarLevel: solarLevel,
    );
  }
}
