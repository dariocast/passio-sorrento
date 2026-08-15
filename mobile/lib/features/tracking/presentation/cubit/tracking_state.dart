part of 'tracking_cubit.dart';

/// Status for tracking loading.
enum TrackingStatus { initial, loading, success, failure }

/// Map tile layer styles.
enum MapTileStyle {
  openStreetMap('OpenStreetMap', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
  cartoLight('Chiara', 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png'),
  cartoDark('Scura', 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png');

  const MapTileStyle(this.label, this.urlTemplate);
  final String label;
  final String urlTemplate;
}

/// State for the tracking screen.
class TrackingState extends Equatable {
  const TrackingState({
    this.status = TrackingStatus.initial,
    this.trackingData = const [],
    this.trailPoints = const [],
    this.selectedProcessionId,
    this.errorMessage,
    this.mapStyle = MapTileStyle.openStreetMap,
    this.userLocation,
    this.filterMunicipality,
    this.searchQuery = '',
  });

  /// Current loading status.
  final TrackingStatus status;

  /// List of live tracking data.
  final List<TrackingData> trackingData;

  /// Historical trail points for polyline path.
  final List<LatLng> trailPoints;

  /// Currently selected procession ID for map focus.
  final String? selectedProcessionId;

  /// Error message if any.
  final String? errorMessage;

  /// Current map style.
  final MapTileStyle mapStyle;

  /// User current GPS position.
  final LatLng? userLocation;

  /// Municipality filter.
  final String? filterMunicipality;

  /// Search query.
  final String searchQuery;

  /// Filtered tracking data based on municipality & search query.
  List<TrackingData> get filteredTrackingData {
    return trackingData.where((item) {
      if (filterMunicipality != null && filterMunicipality!.isNotEmpty) {
        // Match municipality if available in name/confraternity
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final nameMatches = item.name?.toLowerCase().contains(query) ?? false;
        if (!nameMatches) return false;
      }
      return true;
    }).toList();
  }

  /// Creates a copy with updated fields.
  TrackingState copyWith({
    TrackingStatus? status,
    List<TrackingData>? trackingData,
    List<LatLng>? trailPoints,
    String? selectedProcessionId,
    bool clearSelected = false,
    String? errorMessage,
    MapTileStyle? mapStyle,
    LatLng? userLocation,
    String? filterMunicipality,
    bool clearMunicipality = false,
    String? searchQuery,
  }) {
    return TrackingState(
      status: status ?? this.status,
      trackingData: trackingData ?? this.trackingData,
      trailPoints: trailPoints ?? this.trailPoints,
      selectedProcessionId: clearSelected ? null : (selectedProcessionId ?? this.selectedProcessionId),
      errorMessage: errorMessage ?? this.errorMessage,
      mapStyle: mapStyle ?? this.mapStyle,
      userLocation: userLocation ?? this.userLocation,
      filterMunicipality: clearMunicipality ? null : (filterMunicipality ?? this.filterMunicipality),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    trackingData,
    trailPoints,
    selectedProcessionId,
    errorMessage,
    mapStyle,
    userLocation,
    filterMunicipality,
    searchQuery,
  ];
}
