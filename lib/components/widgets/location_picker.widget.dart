import 'dart:async';

import 'package:awesome_poll_app/components/widgets/animations/dashed_circle.widget.dart';
import 'package:awesome_poll_app/utils/commons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_utils;
import 'package:google_maps_flutter/google_maps_flutter.dart';

//show a simple maps view with an circle overlay for selecting an area where the poll should be located
class LocationPickerWidget extends StatefulWidget {
  final double? minZoom;
  final double? maxZoom;
  final double lat;
  final double lng;
  final double zoom;
  const LocationPickerWidget({
    Key? key,
    this.minZoom,
    this.maxZoom,
    required this.lat,
    required this.lng,
    required this.zoom,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LocationPickerWidget();

}

class _LocationPickerWidget extends State<LocationPickerWidget> {
  CircleLocation? _circleLocation;
  final Completer<GoogleMapController> _mapsController = Completer();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.lang('poll-view.picker.select')),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Stack(
      children: [
        Builder(
          builder: (context) => GoogleMap(
            tiltGesturesEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (e) => _mapsController.complete(e),
            onCameraMove: (_) => _whenMapsReady((c) => _updateInternalCircleLocation(c)),
            onCameraIdle: () => _whenMapsReady((c) => _updateInternalCircleLocation(c)),
            minMaxZoomPreference: MinMaxZoomPreference(widget.minZoom, widget.maxZoom),
            gestureRecognizers: {
              Factory(() => PanGestureRecognizer()),
            },
            initialCameraPosition: CameraPosition(
              zoom: widget.zoom,
              target: LatLng(widget.lat, widget.lng),
            ),
          ),
        ),
        Builder(
          builder: (context) => Center(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size.square(_calculateCircleSize()),
                  painter: DashedCirclePainter(
                    color: context.theme.colorScheme.onBackground,
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.onBackground,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                color: Theme.of(context).colorScheme.background,
                icon: const Icon(Icons.location_on),
                iconSize: 44,
                onPressed: () => Navigator.pop(context, _circleLocation),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _whenMapsReady(Function(GoogleMapController controller) whenReady) async {
    if(_mapsController.isCompleted) {
      whenReady(await _mapsController.future);
    }
  }

  final double ratio = 0.75;

  double _calculateCircleSize() {
    var length = MediaQuery.of(context).size.shortestSide;
    return length * ratio;
  }

  Future<LatLng> _center(GoogleMapController controller) async {
    LatLngBounds visibleRegion = await controller.getVisibleRegion();
    LatLng center = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );
    return center;
  }

  Future<LatLng> _deg0(GoogleMapController controller) async {
    LatLngBounds visibleRegion = await controller.getVisibleRegion();
    var latD = visibleRegion.southwest.latitude - visibleRegion.northeast.latitude;
    var lngD = visibleRegion.southwest.longitude - visibleRegion.northeast.longitude;
    LatLng deg0 = LatLng(
      visibleRegion.northeast.latitude + (latD * ratio),
      visibleRegion.northeast.longitude + (lngD * ratio),
    );
    return deg0;
  }

  void _updateInternalCircleLocation(GoogleMapController controller) async {
    var _nCenter = await _center(controller);
    var _nDeg0 = await _deg0(controller);
    var rm3 = map_utils.SphericalUtil
        .computeDistanceBetween(
        map_utils.LatLng(_nCenter.latitude, _nCenter.longitude),
        map_utils.LatLng(_nDeg0.latitude, _nDeg0.longitude)) as double;
    _circleLocation = CircleLocation(
      longitude: _nCenter.longitude,
      latitude: _nCenter.latitude,
      radius: rm3
    );
    context.debug(_circleLocation);
  }

}