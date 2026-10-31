# Earthquake Tracker

A Flutter app that lists recent earthquakes from the
[USGS Earthquake Catalog API](https://earthquake.usgs.gov/fdsnws/event/1/).

## Features

- Latest 50 earthquakes worldwide (default: last 10 days, magnitude 4.0+)
- Sort by newest, oldest, strongest or weakest
- Filters: date range, minimum magnitude, and "near me" with an adjustable radius
- Details screen: magnitude, depth, coordinates, PAGER alert, tsunami flag, felt reports
- Open an event in Maps or on the USGS website
- Pull to refresh, loading/error/empty states with retry

## Project structure

```
lib/
  main.dart                        App entry, theme, registers AppController
  controllers/app_controller.dart  State (GetX), USGS requests, location, URL launching
  models/earthquake_model.dart     GeoJSON response model
  pages/homepage.dart              Earthquake list, sort dialog
  pages/details_page.dart          Single earthquake details
  pages/settings_page.dart         Filters (dates, magnitude, location, radius)
  widgets/earthquake_tile.dart     List row and magnitude badge
  utils/helper_function.dart       Date formatting and colour helpers
test/                              Model, controller and widget tests
```

## Getting started

Requires the Flutter SDK (Dart `^3.7.0`).

```bash
flutter pub get
flutter run            # pick a device: Android, iOS, web, macOS, ...
flutter test
flutter analyze
```

Location filtering asks for location permission on first use. Reverse geocoding
(showing your city name) is not available on web; coordinates are shown instead.
