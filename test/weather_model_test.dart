

import 'package:flutter_test/flutter_test.dart';
import 'package:solarx/models/weather_model.dart';

void main() {
  group('WeatherModel JSON Parsing Tests', () {
    test('Should parse clear weather and estimate solar level correctly', () {
      final json = {
        'main': {'temp': 34.5, 'humidity': 25},
        'clouds': {'all': 5},
        'weather': [
          {'main': 'Clear', 'description': 'clear sky'},
        ],
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temp, 34.5);
      expect(model.condition, 'Sunny');
      expect(model.cloudCover, 5);
      expect(model.humidity, 25);
      expect(model.solarLevel, 'Extreme'); // cloudCover < 15% -> Extreme
    });

    test('Should parse cloudy weather and estimate solar level correctly', () {
      final json = {
        'main': {'temp': 28.0, 'humidity': 60},
        'clouds': {'all': 45},
        'weather': [
          {'main': 'Clouds', 'description': 'scattered clouds'},
        ],
      };

      final model = WeatherModel.fromJson(json);

      expect(model.temp, 28.0);
      expect(model.condition, 'Cloudy');
      expect(model.cloudCover, 45);
      expect(model.humidity, 60);
      expect(
        model.solarLevel,
        'Moderate',
      ); // 35% <= cloudCover < 65% -> Moderate
    });

    test(
      'Should fallback to defaults when JSON is empty or missing fields',
      () {
        final json = <String, dynamic>{};

        final model = WeatherModel.fromJson(json);

        expect(model.temp, 31.0);
        expect(model.condition, 'Sunny');
        expect(model.cloudCover, 15);
        expect(model.humidity, 42);
        expect(model.solarLevel, 'High'); // 15% <= cloudCover < 35% -> High
      },
    );
  });
}
