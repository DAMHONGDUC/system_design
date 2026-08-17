/// The crash-reporting sink behind [SdLogger.error].
///
/// **This package holds the contract, never a vendor.** The interface and the
/// no-op live here so any app can log without deciding what reports; the
/// implementation that talks to Crashlytics, Sentry or anything else lives in
/// the host app and is handed over with [attach]. That is what keeps this
/// package free of `firebase_crashlytics` — an app that reports nothing pays
/// nothing, and an app that swaps vendors changes one file.
///
/// **It is a no-op until [attach] is called**, which an app's bootstrap does
/// after its reporter exists. That is what lets [SdLogger] be called from a
/// pure-Dart unit test, a `domain/` service, or any code path that runs before
/// the vendor SDK is initialized, without either crashing or silently
/// starting it.
abstract class SdCrashReporter {
  /// The live reporter. Starts as a no-op; the app's bootstrap swaps in a
  /// real one.
  static SdCrashReporter instance = const _NoopSdCrashReporter();

  /// Point [instance] at a real reporter. Called once, from the app's
  /// bootstrap.
  static void attach(SdCrashReporter reporter) {
    instance = reporter;
  }

  /// Reset to the no-op reporter. For tests, and for a build that has opted
  /// out of reporting.
  static void detach() {
    instance = const _NoopSdCrashReporter();
  }

  /// Record a non-fatal failure.
  void recordError(String reason, {Object? error, StackTrace? stackTrace});

  /// Tag every subsequent report with the signed-in user, so an issue can be
  /// traced to the account that hit it.
  ///
  /// Pass an opaque account id and nothing else — never an email, a display
  /// name or a workspace name. Those are personal data that would then live
  /// in a third-party dashboard.
  void setUserId(String? uid);
}

class _NoopSdCrashReporter implements SdCrashReporter {
  const _NoopSdCrashReporter();

  @override
  void recordError(String reason, {Object? error, StackTrace? stackTrace}) {}

  @override
  void setUserId(String? uid) {}
}
