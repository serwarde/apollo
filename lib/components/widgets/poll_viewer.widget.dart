import 'package:awesome_poll_app/utils/commons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PollViewerWidget extends StatefulWidget {
  final List<PollOverviewLocation> polls;
  final double lat;
  final double lng;
  final double initialZoom;
  final double minZoom;
  final double maxZoom;
  const PollViewerWidget({
    Key? key,
    required this.polls,
    required this.lat,
    required this.lng,
    required this.initialZoom,
    required this.minZoom,
    required this.maxZoom,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PollViewerWidget();
}

class _PollViewerWidget extends State<PollViewerWidget> {

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Stack(
      children: [
        GoogleMap(
          minMaxZoomPreference: MinMaxZoomPreference(widget.minZoom, widget.maxZoom),
          tiltGesturesEnabled: false,
          zoomControlsEnabled: false,
          circles: {
            ...widget.polls.map((e) => Circle(
              circleId: CircleId(e.id),
              center: LatLng(e.latitude, e.longitude),
              radius: e.radius,
              strokeColor: Colors.grey,
              fillColor: Colors.white30,
              strokeWidth: 4,
            )),
          },
          markers: {
            ...widget.polls.map((e) => Marker(
              markerId: MarkerId(e.id),
              icon: BitmapDescriptor.defaultMarker,
              position: LatLng(e.latitude, e.longitude),
              infoWindow: InfoWindow(
                title: e.title,
                onTap: () {
                  //TODO call auto poll view
                },
              ),
            )),
          },
          initialCameraPosition: CameraPosition(
            zoom: widget.initialZoom,
            target: LatLng(widget.lat, widget.lng),
          ),
        ),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
  }
}