// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  WeatherService._();

  static const String _apiKey = '8eb8ec93b9a8fbf9329b6cd362f0025d';
  static const String _city = 'Mosul,IQ';
  
  // Notifiers for shared state access across pages
  static final ValueNotifier<WeatherModel?> weatherNotifier = ValueNotifier<WeatherModel?>(null);
  static final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);

  // Cache flag to prevent duplicate API requests within short durations
  static DateTime? _lastFetchTime;

  /// Fetches weather data for Mosul from OpenWeatherMap.
  /// If force is false, it will use cached data if fetched in the last 15 minutes.
  static Future<WeatherModel?> fetchWeather({bool force = false}) async {
    // Return cached data if available and fresh (e.g. less than 15 mins old)
    if (!force && 
        weatherNotifier.value != null && 
        _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!).inMinutes < 15) {
      return weatherNotifier.value;
    }

    isLoadingNotifier.value = true;
    errorNotifier.value = null;

    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$_city&appid=$_apiKey&units=metric'
      );
      
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final model = WeatherModel.fromJson(data);
        
        weatherNotifier.value = model;
        _lastFetchTime = DateTime.now();
        return model;
      } else {
        final errorMsg = 'Failed to load weather: Code ${response.statusCode}';
        errorNotifier.value = errorMsg;
        print('WeatherService Error: $errorMsg (Body: ${response.body})');
        return null;
      }
    } catch (e) {
      final errorMsg = 'Failed to fetch weather: $e';
      errorNotifier.value = errorMsg;
      print('WeatherService Exception: $e');
      return null;
    } finally {
      isLoadingNotifier.value = false;
    }
  }
}
