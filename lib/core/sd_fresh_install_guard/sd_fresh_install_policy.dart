part of 'sd_fresh_install_guard.dart';

/// Everything [SdFreshInstallGuard] cannot do for itself.
///
/// The guard owns the decision — *has the environment moved?* — and nothing
/// else. Where the answer is stored and what "wipe" means are the host's, and
/// they arrive here as three callbacks so that this package never imports a
/// storage plugin, a Firebase SDK or an app provider.
class SdFreshInstallPolicy {
  const SdFreshInstallPolicy({
    required this.readLastEnv,
    required this.writeEnv,
    required this.wipe,
  });

  /// The env name the last launch recorded, or null on a real fresh install.
  ///
  /// Null means "nothing to compare against" and never triggers a wipe: a
  /// first launch has nothing on the device to be wrong.
  final Future<String?> Function() readLastEnv;

  /// Record the env name this launch is running as.
  final Future<void> Function(String envName) writeEnv;

  /// Take the device back to what a fresh install would have had — signed out,
  /// no preferences, no cached documents.
  ///
  /// Both names are passed for the log line; a host that wipes different
  /// things depending on the direction is free to read them.
  final Future<void> Function(String? previous, String current) wipe;
}
