/// Start Feature (Blocking Rules Management)
/// 
/// Allows users to create, edit, and manage blocking rules:
/// - Create new app blocking rules
/// - Set schedules (time windows, specific days)
/// - Configure break intervals
/// - Enable/disable rules
/// - View active blocking rules
/// - Delete or modify existing rules
/// 
/// Files in this feature:
/// - screens/start/: Rule creation/editing screens, rules list screen
/// - widgets/start/: Rule form components, schedule picker, rule cards
/// - providers/rules_provider.dart: Rule CRUD operations, active rule tracking
/// - models/blocking_rule.dart: BlockingRule model with scheduling info
/// - services/native_blocking_service.dart: Communication with blocking service for enforcement
