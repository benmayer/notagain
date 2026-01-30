// App usage model
// 
// Tracks how long a user has spent in a specific app on a given day.

class AppUsage {
  final String id;
  final String userId;
  final String appName;
  final Duration duration;
  final DateTime date;
  final DateTime? updatedAt;

  AppUsage({
    required this.id,
    required this.userId,
    required this.appName,
    required this.duration,
    required this.date,
    this.updatedAt,
  });

  /// Create from JSON (Supabase response)
  factory AppUsage.fromJson(Map<String, dynamic> json) {
    return AppUsage(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      appName: json['app_name'] as String,
      duration: Duration(seconds: json['duration_seconds'] as int? ?? 0),
      date: DateTime.parse(json['date'] as String),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at'] as String)
        : null,
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'app_name': appName,
      'duration_seconds': duration.inSeconds,
      'date': date.toIso8601String().split('T').first,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AppUsage(appName: $appName, duration: ${duration.inMinutes}m)';
  }
}
