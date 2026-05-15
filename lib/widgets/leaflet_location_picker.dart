import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';

class LocationResult {
  final LatLng latLng;
  final String address;
  LocationResult({required this.latLng, required this.address});
}

class LeafletLocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const LeafletLocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LeafletLocationPickerScreen> createState() =>
      _LeafletLocationPickerScreenState();
}

class _LeafletLocationPickerScreenState
    extends State<LeafletLocationPickerScreen> {
  // Default: Cairo, Egypt
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  late MapController _mapController;
  late LatLng _selectedLocation;
  final TextEditingController _searchController = TextEditingController();

  // Egyptian cities for quick select
  final List<Map<String, dynamic>> _egyptianCities = [
    {'name': 'Cairo', 'lat': 30.0444, 'lng': 31.2357},
    {'name': 'Alexandria', 'lat': 31.2001, 'lng': 29.9187},
    {'name': 'Giza', 'lat': 30.0131, 'lng': 31.2089},
    {'name': 'Luxor', 'lat': 25.6872, 'lng': 32.6396},
    {'name': 'Aswan', 'lat': 24.0889, 'lng': 32.8998},
    {'name': 'Mansoura', 'lat': 31.0364, 'lng': 31.3807},
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? _defaultLocation;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatLatLng(LatLng loc) =>
      '${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}';

  /// Reverse geocode coordinates to get address using Nominatim API
  Future<void> _reverseGeocode(LatLng location) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'format=json&'
        'lat=${location.latitude}&'
        'lon=${location.longitude}&'
        'zoom=18&'
        'addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'SalamtakApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] as String?;

        if (address != null && address.isNotEmpty) {
          setState(() {
            _searchController.text = address;
          });
          return;
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }

    // Fallback to coordinates if geocoding fails
    setState(() {
      _searchController.text = _formatLatLng(location);
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });

    // Fetch address for the selected location
    await _reverseGeocode(location);
  }

  void _selectCity(double lat, double lng, String cityName) async {
    final newLoc = LatLng(lat, lng);
    setState(() {
      _selectedLocation = newLoc;
    });
    _mapController.move(newLoc, 12.0);

    // Fetch detailed address for the city
    await _reverseGeocode(newLoc);
  }

  void _confirm() {
    final address =
        _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : _formatLatLng(_selectedLocation);
    Navigator.pop(
      context,
      LocationResult(latLng: _selectedLocation, address: address),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pick Location',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Address label input
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a label or address description...',
                  hintStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.label_outline_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          // Map
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 14.0,
                    onTap: _onMapTap,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.salamtak.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Instruction overlay
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Tap map to set location',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Manual coordinates and city selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Egyptian cities quick select
                const Text(
                  'Quick Select — Egyptian Cities',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _egyptianCities.map((city) {
                        return _CityChip(
                          name: city['name'],
                          onTap:
                              () => _selectCity(
                                city['lat'],
                                city['lng'],
                                city['name'],
                              ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),

          // Bottom bar with selected location
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.08),
              border: Border(
                top: BorderSide(color: AppTheme.success.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.success,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Location',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        _formatLatLng(_selectedLocation),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Use This',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _CityChip({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_city_rounded,
              size: 13,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 5),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
