class SosEvent {
  final String id;
  final DateTime time;
  final String type; // 'manual' | 'checkin'
  final String status; // 'sent' | 'cancelled' | 'failed'
  final double? lat;
  final double? lon;
  final String? note;

  SosEvent({
    required this.id,
    required this.time,
    required this.type,
    required this.status,
    this.lat,
    this.lon,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time.toIso8601String(),
        'type': type,
        'status': status,
        'lat': lat,
        'lon': lon,
        'note': note,
      };

  factory SosEvent.fromJson(Map<String, dynamic> json) => SosEvent(
        id: json['id'],
        time: DateTime.parse(json['time']),
        type: json['type'],
        status: json['status'],
        lat: (json['lat'] as num?)?.toDouble(),
        lon: (json['lon'] as num?)?.toDouble(),
        note: json['note'],
      );
}

