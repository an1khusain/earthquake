import 'dart:async';
import 'dart:convert';

import 'package:earthquake/models/earthquake_model.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:geocoding/geocoding.dart' as gc;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../utils/helper_function.dart';

class AppController extends GetxController {
  AppController({http.Client? client}) : _client = client ?? http.Client();

  static final Uri baseUrl = Uri.parse(
    'https://earthquake.usgs.gov/fdsnws/event/1/query',
  );
  static const int resultLimit = 50;
  static const double minRadiusKm = 100;
  static const double maxRadiusKmThreshold = 20000;
  static const double minMagnitude = 0;
  static const double maxMagnitude = 10;
  static const Duration requestTimeout = Duration(seconds: 20);

  final http.Client _client;

  late DateTime _startDate;
  late DateTime _endDate;
  double _magnitude = 4;
  String _orderBy = 'time';
  bool _shouldUseLocation = false;
  double _maxRadiusKm = 500;
  double _latitude = 0;
  double _longitude = 0;
  String? _currentCity;

  EarthquakeModel? earthQuakeModel;
  bool _isLoading = false;
  String? _errorMessage;
  bool _filtersChanged = false;
  int _requestId = 0;

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String get startTime => formatDate(_startDate);
  String get endTime => formatDate(_endDate);
  double get magnitude => _magnitude;
  String get orderBy => _orderBy;
  bool get shouldUseLocation => _shouldUseLocation;
  double get maxRadiusKm => _maxRadiusKm;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String? get currentCity => _currentCity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasDataLoaded => earthQuakeModel != null;
  List<Features> get earthquakes => earthQuakeModel?.features ?? const [];

  Map<String, String> get queryParams {
    final now = DateTime.now();
    final endOfDay = DateTime(_endDate.year, _endDate.month, _endDate.day + 1);
    return {
      'format': 'geojson',
      'starttime': toUsgsTime(_startDate),
      'endtime': toUsgsTime(endOfDay.isAfter(now) ? now : endOfDay),
      'minmagnitude': '$_magnitude',
      'orderby': _orderBy,
      'limit': '$resultLimit',
      if (_shouldUseLocation) ...{
        'latitude': '$_latitude',
        'longitude': '$_longitude',
        'maxradiuskm': '$_maxRadiusKm',
      },
    };
  }

  @override
  void onInit() {
    super.onInit();
    final today = DateUtils.dateOnly(DateTime.now());
    _startDate = today.subtract(const Duration(days: 10));
    _endDate = today;
    getEarthquakeData();
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }

  Future<void> getEarthquakeData() async {
    final requestId = ++_requestId;
    _isLoading = true;
    _errorMessage = null;
    _filtersChanged = false;
    update();

    String? error;
    EarthquakeModel? result;
    try {
      final uri = Uri.https(baseUrl.authority, baseUrl.path, queryParams);
      final response = await _client.get(uri).timeout(requestTimeout);
      if (response.statusCode == 200) {
        result = EarthquakeModel.fromJson(jsonDecode(response.body));
      } else {
        error = _serverError(response);
      }
    } on TimeoutException {
      error = 'The request timed out. Please try again.';
    } catch (_) {
      error = 'Could not load earthquakes. Check your internet connection.';
    }

    if (requestId != _requestId) return;
    if (result != null) earthQuakeModel = result;
    _errorMessage = error;
    _isLoading = false;
    update();
  }

  String _serverError(http.Response response) {
    final body = response.body.trim();
    final firstLine = body.isEmpty ? '' : body.split('\n').first;
    return 'USGS returned ${response.statusCode}'
        '${firstLine.isEmpty ? '' : ': $firstLine'}';
  }

  /// Refetches only if a filter was changed since the last request.
  Future<void> refreshIfFiltersChanged() async {
    if (_filtersChanged) await getEarthquakeData();
  }

  void setOrder(String value) {
    if (value == _orderBy) return;
    _orderBy = value;
    getEarthquakeData();
  }

  void setStartDate(DateTime date) {
    _startDate = DateUtils.dateOnly(date);
    if (_startDate.isAfter(_endDate)) _endDate = _startDate;
    _markChanged();
  }

  void setEndDate(DateTime date) {
    _endDate = DateUtils.dateOnly(date);
    if (_endDate.isBefore(_startDate)) _startDate = _endDate;
    _markChanged();
  }

  void setMagnitude(double value) {
    _magnitude = value.clamp(minMagnitude, maxMagnitude).toDouble();
    _markChanged();
  }

  void setMaxRadius(double value) {
    _maxRadiusKm =
        value.clamp(minRadiusKm, maxRadiusKmThreshold).roundToDouble();
    _markChanged();
  }

  /// Returns an error message when the location could not be determined.
  Future<String?> setLocation(bool value) async {
    if (!value) {
      _shouldUseLocation = false;
      _latitude = 0;
      _longitude = 0;
      _currentCity = null;
      _markChanged();
      return null;
    }
    try {
      final position = await _determinePosition();
      _latitude = position.latitude;
      _longitude = position.longitude;
      _shouldUseLocation = true;
      await _resolveCity();
      _markChanged();
      return null;
    } catch (error) {
      _shouldUseLocation = false;
      update();
      return error.toString();
    }
  }

  void _markChanged() {
    _filtersChanged = true;
    update();
  }

  Future<void> _resolveCity() async {
    try {
      final placeMarks = await gc.placemarkFromCoordinates(
        _latitude,
        _longitude,
      );
      if (placeMarks.isNotEmpty) {
        final p = placeMarks.first;
        _currentCity = [
          p.locality,
          p.administrativeArea,
          p.country,
        ].firstWhereOrNull((e) => e != null && e.isNotEmpty);
      }
    } catch (_) {
      // Reverse geocoding is unavailable on some platforms (e.g. web).
      _currentCity = null;
    }
  }

  Future<void> openMap(Features feature) async {
    final coords = feature.geometry?.coordinates;
    final query =
        coords != null && coords.length >= 2
            ? '${coords[1]},${coords[0]}'
            : feature.properties?.place ?? '';
    await openUrl(
      Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': query,
      }).toString(),
    );
  }

  Future<void> openUrl(String? url) async {
    final uri = url == null ? null : Uri.tryParse(url);
    var launched = false;
    if (uri != null) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
    }
    if (!launched) {
      Get.snackbar('Not available', 'Could not open this link.');
    }
  }

  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Location services are disabled.';
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission was denied.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission is permanently denied. '
          'Enable it in the system settings.';
    }
    return Geolocator.getCurrentPosition();
  }
}
