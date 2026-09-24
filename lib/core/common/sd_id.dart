import 'package:uuid/uuid.dart';

/// Every id an app of ours writes — the one place ids are made.
///
/// Two calls, and the split is the point:
///
/// | Call | Gives | For |
/// |---|---|---|
/// | [unique] | `3f2b…-…` (UUID v4) | a new record's own id |
/// | [owned] | `<ownerId>_<id>` | the document a user's record is stored under |
///
/// **A document holding one user's data is always [owned].** A flat
/// collection shares one id space between every user, and a record id is only
/// unique if it was made by [unique]: an id derived from the data — a day, a
/// slug — is the same for everyone, so the first user to write it owns the
/// document and every other user's write is refused for good.
abstract final class SdId {
  static const Uuid _uuid = Uuid();

  /// A new random id (UUID v4).
  static String unique() => _uuid.v4();

  /// [id] scoped to [ownerId], so two owners never share a document.
  static String owned(String ownerId, String id) {
    assert(ownerId.isNotEmpty, 'an owned id needs its owner');
    return '${ownerId}_$id';
  }
}
