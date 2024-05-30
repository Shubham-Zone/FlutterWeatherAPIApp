import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_application/business/model.dart';
import '../constants/api_key.dart';
import 'package:http/http.dart' as http;

class ApiCall extends ChangeNotifier {

  String cityName = "";
  WeatherModel? _weatherModel;

  WeatherModel? get weatherModel => _weatherModel;

  Future<void> fetchWeatherDetails() async {
    try {
      Position? position = await getCurrentPositionWithTimeout();
      await fetchCityNameFromCoordinates(position!.latitude, position.longitude);
      await fetchWeatherFromApi();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchCityNameFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        log(place.locality.toString());
        cityName = place.locality ?? "Unknown";
        notifyListeners();
      } else {
        throw Exception('No placemarks found');
      }
    } catch (e) {
      print("Error fetching city name: $e");
      throw e;
    }
  }

  Future<void> fetchWeatherFromApi() async {

    if (cityName.isEmpty) return;

    try {
      var url = Uri.https('api.openweathermap.org', '/data/2.5/weather',
          {'q': cityName, 'units': 'metric', 'appid': apiKey});

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _weatherModel = WeatherModel.fromMap(data);
        notifyListeners();
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  Future<Position?> getCurrentPositionWithTimeout() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(const Duration(seconds: 4));
    } catch (e) {
      print('Timeout reached while trying to get current position, fetching last known position: $e');
      return await Geolocator.getLastKnownPosition();
    }
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission is denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied, we cannot request permissions.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }
}
