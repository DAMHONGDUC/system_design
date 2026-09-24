import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/common.dart';

void main() {
  test('unique ids do not repeat', () {
    final Set<String> ids = <String>{
      for (int i = 0; i < 1000; i++) SdId.unique(),
    };

    expect(ids, hasLength(1000));
  });

  test('unique is a UUID v4', () {
    expect(
      SdId.unique(),
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  // The bug this exists for: a day as an id was one document for every user.
  test('the same id under two owners is two documents', () {
    expect(SdId.owned('alice', '2026-09-24'), 'alice_2026-09-24');
    expect(
      SdId.owned('alice', '2026-09-24'),
      isNot(SdId.owned('bob', '2026-09-24')),
    );
  });
}
