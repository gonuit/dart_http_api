part of http_api;

/// To create own dev-only ApiLink, extend this class.
/// {@template http_api.debug_link}
///
/// DebugLinks will NOT be present in release builds.
/// They are ignored by [ApiLink.chain] method.
/// {@endtemplate}
abstract class DebugLink extends ApiLink {}
