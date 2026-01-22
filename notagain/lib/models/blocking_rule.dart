// Blocking rule model
// 
// Represents a rule that blocks specific apps or websites during configured times.

class BlockingRule {
  final String id;
  final String userId;
  final String appName;
  final String? appBundleId;
  final bool enabled;
  final String? schedule;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BlockingRule({
    required this.id,
    required this.userId,
    required this.appName,
    this.appBundleId,
    required this.enabled,
    this.schedule,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (Supabase response)
  factory BlockingRule.fromJson(Map<String, dynamic> json) {
    return BlockingRule(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      appName: json['app_name'] as String,
      appBundleId: json['app_bundle_id'] as String?,
      enabled: (json['enabled'] ?? true) as bool,
      schedule: json['schedule'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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
      'app_bundle_id': appBundleId,
      'enabled': enabled,
      'schedule': schedule,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy with optional fields replaced
  BlockingRule copyWith({
    String? id,
    String? userId,
    String? appName,
    String? appBundleId,
    bool? enabled,
    String? schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BlockingRule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      appName: appName ?? this.appName,
      appBundleId: appBundleId ?? this.appBundleId,
      enabled: enabled ?? this.enabled,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BlockingRule(id: $id, appName: $appName, enabled: $enabled)';
  }
}
