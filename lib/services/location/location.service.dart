import 'package:location/location.dart';

// export the data types of the location package
export 'package:location/location.dart';

class LocationService {
  static Location location = Location();

  /// Return an LocationData object containing the current longitude and latitude of the device
  /// Includes requesting the permission for GPS and checking whether GPS is enabled
  /// Returns null if the locaiton could not be retrieved for example due to a lack of permissions
  static Future<LocationData?> getLocation() async {
    // Check GPS is enabled.
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {}
    }

    // Get GPS permission.
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.deniedForever) {
      return null;
    }
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return location.getLocation();
  }
}