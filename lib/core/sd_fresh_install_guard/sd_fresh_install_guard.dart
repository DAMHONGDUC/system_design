import 'dart:async';

import 'package:flutter/widgets.dart';

import '../common/sd_fresh_install.dart';
import '../common/sd_logger.dart';

/// Holds the app back until it is known that the data on this device belongs
/// to the environment this binary talks to.
///
/// Two flavours installed over one another share a sandbox whenever they
/// share a bundle id, so a prod build can start up reading a dev signed-in
/// session, a dev Firestore cache and dev preferences — and write it back to
/// the real project. This guard compares the env name it is given against the
/// one recorded on the last launch and, when they differ, asks the host to
/// wipe the device down to what a fresh install would have had.
///
/// **It renders nothing of its own and knows nothing about storage.** Reading,
/// writing and wiping all arrive as [SdFreshInstallPolicy] callbacks, which is
/// what keeps a widget package free of `shared_preferences`, Firebase and the
/// host's providers.
///
/// **The child is not built until the check has finished.** The wipe signs the
/// seller out and clears a database cache; letting the app's first screen
/// build alongside it would race a sign-out against the screens reading that
/// session.
class SdFreshInstallGuard extends StatefulWidget {
  const SdFreshInstallGuard({
    required this.envName,
    required this.policy,
    required this.child,
    this.placeholder,
    super.key,
  });

  /// Which environment this binary is — `dev`, `staging`, `prod`. Compared
  /// verbatim against what the last launch recorded.
  final String envName;

  /// How this host reads, records and wipes. See [SdFreshInstallPolicy].
  final SdFreshInstallPolicy policy;

  /// The app, normally `MaterialApp` itself.
  final Widget child;

  /// What to draw while the check runs — one frame or two on a normal launch,
  /// as long as the wipe takes on the launch that needs one. Defaults to
  /// nothing, so a host that already shows a native splash keeps showing it.
  final Widget? placeholder;

  @override
  State<SdFreshInstallGuard> createState() => _SdFreshInstallGuardState();
}

class _SdFreshInstallGuardState extends State<SdFreshInstallGuard> {
  bool _resolved = false;

  @override
  void initState() {
    super.initState();

    unawaited(_resolve());
  }

  @override
  Widget build(BuildContext context) => _resolved
      ? widget.child
      : widget.placeholder ?? const SizedBox.shrink();

  /// Compare, wipe if the environment moved, then record where we are now.
  ///
  /// **The record is written last on purpose.** A wipe that clears the store
  /// takes the record with it, so writing first would leave the device
  /// claiming an environment whose data has just been deleted — and a wipe
  /// interrupted half way is repeated on the next launch rather than skipped.
  Future<void> _resolve() async {
    try {
      final String? previous = await widget.policy.readLastEnv();

      if (previous != null && previous != widget.envName) {
        SdLogger.warning(
          _SdFreshInstallGuardConstant.logTag,
          'Environment changed — wiping this device like a fresh install',
          <String, String>{'previous': previous, 'current': widget.envName},
        );

        await widget.policy.wipe(previous, widget.envName);
      }

      await widget.policy.writeEnv(widget.envName);
    } catch (error, stackTrace) {
      // The app still starts: a device that could not be checked is the one
      // the seller is holding, and a white screen tells them nothing.
      SdLogger.error(
        _SdFreshInstallGuardConstant.logTag,
        'Fresh install check failed — starting on whatever is on the device',
        error: error,
        stackTrace: stackTrace,
        data: <String, String>{'current': widget.envName},
      );
    } finally {
      if (mounted) {
        setState(() => _resolved = true);
      }
    }
  }
}

/// What the guard is made of.
///
/// The tag is a literal because this package has no `LogTagConstant` to reach
/// for — the host owns that list, and a flow that lives entirely in here names
/// itself once, here.
final class _SdFreshInstallGuardConstant {
  static const String logTag = 'Fresh Install';
}
