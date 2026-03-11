import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const RandoRisquesApp());
}

class RandoRisquesApp extends StatelessWidget {
  const RandoRisquesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prototype rando PACA v2 – sans backend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Centre de la carte (ex : PACA)
  final LatLng _center = LatLng(44.5, 6.0);
  final double _initialZoom = 10.0;

  // Rayon d’alerte en km
  double _alertRadiusKm = 2.0;

  // Couches visibles ou non
  bool _showPatou = true;
  bool _showChasse = true;
  bool _showTravaux = true;
  bool _showOrage = true;

  // Position utilisateur actuelle (mise à jour en temps réel)
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return; // Le service de localisation n'est pas activé
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return; // permissions refusées
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return; // permissions définitivement refusées
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position pos) {
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
      });
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  // Exemples de positions (à remplacer plus tard par de vraies données)
  final List<LatLng> _patouPoints = [
    LatLng(44.51, 6.02),
    LatLng(44.48, 5.98),
  ];

  final List<LatLng> _chassePoints = [
    LatLng(44.52, 6.05),
  ];

  final List<LatLng> _travauxPoints = [
    LatLng(44.47, 6.01),
  ];

  final List<LatLng> _oragePoints = [
    LatLng(44.50, 5.95),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFEF),
      body: Stack(
        children: [
          _buildMap(),
          _buildPrototypeBanner(),
          _buildAlertRadiusSlider(),
          _buildBottomButtons(),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              color: const Color.fromRGBO(0, 0, 0, 0.6),
              child: const Text(
                'V2 SANS BACKEND',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _center,
        initialZoom: _initialZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.gap_map.prototype',
        ),
        // Cercle centré sur la position utilisateur, rayon contrôlé par le slider
        if (_currentPosition != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: _currentPosition!,
                radius: _alertRadiusKm * 1000, // mètres
                useRadiusInMeter: true,
                color: const Color.fromRGBO(255, 0, 0, 0.12),
                borderStrokeWidth: 2,
                borderColor: const Color.fromRGBO(255, 0, 0, 0.7),
              ),
            ],
          ),
        if (_showPatou)
          _buildMarkerLayer(
            _patouPoints,
            'assets/icons/patou.png',
          ),
        if (_showChasse)
          _buildMarkerLayer(
            _chassePoints,
            'assets/icons/chasse.png',
          ),
        if (_showTravaux)
          _buildMarkerLayer(
            _travauxPoints,
            'assets/icons/travaux.png',
          ),
        if (_showOrage)
          _buildMarkerLayer(
            _oragePoints,
            'assets/icons/orage.png',
          ),
      ],
    );
  }

  MarkerLayer _buildMarkerLayer(List<LatLng> points, String assetPath) {
    return MarkerLayer(
      markers: points
          .map(
            (point) => Marker(
              point: point,
              width: 50,
              height: 50,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
              ),
            ),
          )
          .toList(),
    );
  }

  // Bandeau de mise en garde prototype
  Widget _buildPrototypeBanner() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        color: Colors.orange.shade100,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Prototype en test – les informations affichées (troupeaux, '
                  'chiens de protection, chasse, travaux, météo, etc.) sont '
                  'fictives et ne doivent pas être utilisées pour préparer '
                  'une randonnée réelle.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Slider en bas, juste au-dessus des boutons
  Widget _buildAlertRadiusSlider() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 96, // au-dessus des boutons du bas
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rayon d’alerte (km)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _alertRadiusKm,
                      min: 0.5,
                      max: 10.0,
                      divisions: 19,
                      label: _alertRadiusKm.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _alertRadiusKm = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    '${_alertRadiusKm.toStringAsFixed(1)} km',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Boutons en bas de l’écran
  Widget _buildBottomButtons() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 16,
      child: Center(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleChip(
                  label: 'Patous',
                  icon: Icons.pets,
                  isActive: _showPatou,
                  onTap: () {
                    setState(() {
                      _showPatou = !_showPatou;
                    });
                  },
                ),
                _buildToggleChip(
                  label: 'Chasse',
                  icon: Icons.gps_fixed,
                  isActive: _showChasse,
                  onTap: () {
                    setState(() {
                      _showChasse = !_showChasse;
                    });
                  },
                ),
                _buildToggleChip(
                  label: 'Travaux',
                  icon: Icons.construction,
                  isActive: _showTravaux,
                  onTap: () {
                    setState(() {
                      _showTravaux = !_showTravaux;
                    });
                  },
                ),
                _buildToggleChip(
                  label: 'Orage',
                  icon: Icons.thunderstorm,
                  isActive: _showOrage,
                  onTap: () {
                    setState(() {
                      _showOrage = !_showOrage;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isActive,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
