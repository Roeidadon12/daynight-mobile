import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../../constants.dart';

class AddressMapWidget extends StatefulWidget {
  final String address;
  final double height;
  final bool showMarker;

  const AddressMapWidget({
    super.key,
    required this.address,
    this.height = 200.0,
    this.showMarker = true,
  });

  @override
  State<AddressMapWidget> createState() => _AddressMapWidgetState();
}

class _AddressMapWidgetState extends State<AddressMapWidget> {
  LatLng? _location;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _geocodeAddress();
  }

  Future<void> _geocodeAddress() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<Location> locations = await locationFromAddress(widget.address);
      
      if (locations.isNotEmpty) {
        setState(() {
          _location = LatLng(locations.first.latitude, locations.first.longitude);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Location not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[900],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildMapContent(),
      ),
    );
  }

  Widget _buildMapContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: kBrandPrimary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _geocodeAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_location == null) {
      return Center(
        child: Text(
          'Unable to display location',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: _location!,
        initialZoom: 15.0,
        minZoom: 10.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.day_night',
          maxNativeZoom: 19,
        ),
        if (widget.showMarker)
          MarkerLayer(
            markers: [
              Marker(
                point: _location!,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: kBrandPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}