import 'package:flutter_test/flutter_test.dart';
import 'package:system_design/core/sd_breakpoint.dart';

void main() {
  group('SdBreakpointConstant.of', () {
    test('every phone is compact', () {
      expect(SdBreakpointConstant.of(320), SdBreakpoint.compact);
      expect(SdBreakpointConstant.of(390), SdBreakpoint.compact);
      expect(SdBreakpointConstant.of(440), SdBreakpoint.compact);
    });

    test('a tablet held upright is medium', () {
      expect(SdBreakpointConstant.of(744), SdBreakpoint.medium);
      expect(SdBreakpointConstant.of(834), SdBreakpoint.medium);
    });

    test('a tablet on its side is expanded', () {
      expect(SdBreakpointConstant.of(1024), SdBreakpoint.expanded);
      expect(SdBreakpointConstant.of(1366), SdBreakpoint.expanded);
    });

    test('isWide is false only for a phone', () {
      expect(SdBreakpoint.compact.isWide, isFalse);
      expect(SdBreakpoint.medium.isWide, isTrue);
      expect(SdBreakpoint.expanded.isWide, isTrue);
    });
  });
}
