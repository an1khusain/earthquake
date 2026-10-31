const sampleGeoJson = '''
{
  "type": "FeatureCollection",
  "metadata": {"generated": 1761900000000, "title": "USGS Earthquakes", "status": 200, "count": 2},
  "features": [
    {
      "type": "Feature",
      "id": "us7000abcd",
      "properties": {
        "mag": 6.4, "place": "120 km SSW of Tokyo, Japan", "time": 1761800000000,
        "updated": 1761800500000, "url": "https://earthquake.usgs.gov/earthquakes/eventpage/us7000abcd",
        "felt": 120, "alert": "yellow", "status": "reviewed", "tsunami": 1, "sig": 650,
        "net": "us", "magType": "mww", "type": "earthquake", "title": "M 6.4 - 120 km SSW of Tokyo, Japan"
      },
      "geometry": {"type": "Point", "coordinates": [139.2, 34.7, 35.5]}
    },
    {
      "type": "Feature",
      "id": "ak0001",
      "properties": {
        "mag": 4.1, "place": "50 km N of Anchorage, Alaska", "time": 1761700000000,
        "felt": null, "alert": null, "tsunami": 0, "magType": "ml", "title": "M 4.1 - Alaska"
      },
      "geometry": {"type": "Point", "coordinates": [-149.9, 61.6, 10.0]}
    }
  ],
  "bbox": [-149.9, 34.7, 10.0, 139.2, 61.6, 35.5]
}
''';
