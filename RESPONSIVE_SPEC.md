# Tablet responsive — portable spec

Written to be applied to **another app**, not to describe this one. Every name
below is a thing you create; the BaroEase implementation is referenced only as
a worked example.

## 0. Premises

| Assumption | If your app differs |
|---|---|
| Flutter, iOS-first, one design size | — |
| `flutter_screenutil`, every dimension via a constants holder | Skip §1 entirely; it exists only to cap screenutil |
| Screens are a single scrolling column of cards | §2 still applies; §3 still applies |
| A bottom tab bar on phone | §3 is about moving it; skip if you have no tab bar |
| Tablet is a target (`TARGETED_DEVICE_FAMILY = "1,2"`) | Nothing below matters |

**The one invariant: every rule here is a no-op at phone width.** If applying
this moves a single pixel on an iPhone, something is wrong. Assert it.

---

## 1. Cap the scale ratio

### The trap

screenutil multiplies every `.w` / `.h` / `.r` / `.sp` by `window / designSize`,
with **no upper bound**. A 393-wide design on an 820-wide iPad scales 2.09; in
landscape the width ratio hits 3.00 while `minTextAdapt` (which takes the
*smaller* of the two ratios for text) makes the type *smaller* than a phone's.
The result is a screenshot enlarged in one axis and shrunk in the other.

This is the single largest tablet bug in a screenutil app, and it is invisible
in tests — nothing overflows, every number is just wrong.

### The fix

Grow the design to match the window instead of letting the ratio grow:

```dart
final class SdScreenScale {
  const SdScreenScale._();

  /// "The same app at arm's length." Every spacing constant moves by this and
  /// nothing else, so the rhythm the design was drawn at survives.
  static const double maxScale = 1.15;

  static Size designSize(Size window, Size design) => Size(
    math.max(design.width, window.width / maxScale),
    math.max(design.height, window.height / maxScale),
  );
}
```

Wire it at the root. **Read through `MediaQuery`, not `View`** — a rotation or a
Split View resize must rebuild this:

```dart
ScreenUtilInit(
  designSize: SdScreenScale.designSize(MediaQuery.sizeOf(context), _designSize),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: ...,
)
```

### Result

| Window | Design handed to screenutil | Scale | A 16 gutter paints at |
|---|---|---|---|
| 393×852 iPhone 15 | 393×852 | 1.00 | 16 |
| 440×956 iPhone 16 Pro Max | 393×852 | 1.12 | 18 |
| 820×1180 iPad 11" portrait | 713×1026 | 1.15 | 18 (was **33**) |
| 1180×820 iPad 11" landscape | 1026×852 | 1.15 / 0.96 | 18 (was **48**) |

The widest iPhone is 440 and `440 / 1.15 = 383 < 393`, so the clamp cannot
engage on any phone. That is what makes this safe to ship.

### Pick your own `maxScale`

1.15 was chosen so type and touch targets grow enough for a tablet held further
away, without the app reading as blown up. Anything in 1.10–1.25 is defensible.
`1.0` is wrong — it leaves a phone-sized app marooned on a big screen.

---

## 2. One margin number

### The rule

**Screen edge → nav, nav → content, content → far edge are the same number**,
and it does not change with the screen or the orientation.

```text
iPad 11" landscape, 1180 x 820
┌──────┬────┬──────────────────────────────────┬────┐
│      │    │ app bar — same margins as below  │    │
│ ▓▓▓▓ │ 46 ├──────────────────────────────────┤ 46 │
│ ▓▓▓▓ │    │ card 978 — fills what is left    │    │
│  64  │    │                                  │    │
└──────┴────┴──────────────────────────────────┴────┘
 |<46>|                        nav column = 46 + 64 = 110
```

### Why not a max-width column

The obvious move is `maxWidth: 920` + centre. Do not: it produces three
*different* gaps — 46 at the edge, 107 to the nav, 79 at the far side — because
two of them are leftover page margin from a ceiling and only one is a decision.
One number is a decision. Let the content **fill** what the margins leave.

### The implementation

```dart
/// The one gap. 40 design units = 46 rendered at maxScale.
static double get tabletMargin => SdSpacingConstant.w40;

/// What a screen adds per side, given it already pads itself by [horizontal].
static double pageMargin(BuildContext context) {
  if (SdBreakpointV2.of(context) == SdWindowClassV2.compact) return 0;

  final double margin = math.max(0, tabletMargin - horizontal);

  // No shell nav at all -> same content width, centred. See below.
  return SdFloatingBarScopeV2.edgeOf(context) == null
      ? margin + floatingRailWidth / 2
      : margin;
}
```

`tabletMargin - horizontal` is the crux: **your screens already pad themselves**
by a gutter. Adding the full margin on top stacks two gutters and the gap comes
out wrong. Subtract what the content already brings.

### Apply it around the whole Scaffold, app bar included

```dart
return ColoredBox(
  color: Theme.of(context).scaffoldBackgroundColor,
  child: Padding(
    padding: EdgeInsets.symmetric(
      horizontal: SdContentPaddingV2.pageMargin(context),
    ),
    child: Scaffold(appBar: ..., body: ...),
  ),
);
```

Two non-obvious parts:

- **The app bar must be inside the margin.** A header spanning the window over
  an inset body reads as two screens stacked. Pad the `Scaffold`, not its body.
- **The `ColoredBox` is required.** A pushed route has no surface of its own
  behind it, so the two strips either side show whatever the route below left —
  on a fresh push, **black**.

### Screens with no nav get the same width, centred

A detail screen pushed **above** the shell has no nav beside it. A plain
`tabletMargin` there makes it a nav column wider than the tab screen it was
opened from, and the content visibly jumps outward on the way in and back on
the way out. Half the nav column extra per side is the one inset that makes the
two widths identical:

```text
iPad 11" portrait, 820 wide — both land on a 618 card
tab screen     |46| nav 64 |46|      card 618      |46|
pushed detail  |     101    |46|      card 618      |46|     101     |
```

**Check your router first.** In BaroEase the detail routes are *siblings* of
`StatefulShellRoute`, not children of its branches — which is why the margin
lives in the scaffold and not in the shell. If your details are inside the
branches, they keep the nav and this case never fires.

### Pages take margins; panels keep ceilings

| Kind | Rule | Examples |
|---|---|---|
| **Page** — fills the window | `pageMargin`, content fills | every screen |
| **Panel** — floats over a page | `maxWidth` + centre | modal sheet, dialog, paywall, onboarding |

A sheet spanning a 1180-wide window is a dark slab with a column of controls
lost in the middle. Cap panels:

| Ceiling | Suggested | Note |
|---|---|---|
| sheet / full-screen panel | `w800` → 920 | Material centres a modal sheet for you once `constraints` is set |
| dialog | `w480` → 552 | `insetPadding` alone leaves a 746-wide dialog on an iPad |
| phone nav pill | `w480` → 552 | five glyphs across a wide bar stop reading as one control |

Keep them as **separate fields holding the same number** rather than one shared
constant. They are different things that measure alike today.

---

## 3. Move the nav to the leading edge

### Window classes

Material's boundaries, unchanged — they are where the hardware is (11" iPad is
820 portrait / 1180 landscape, 13" is 1024 / 1366), and inventing your own puts
a boundary in the middle of a device.

```dart
enum SdWindowClassV2 { compact, medium, expanded }

static const double medium = 600;   // nav moves to the side at or above this
static const double expanded = 840; // where a second column would appear

static SdWindowClassV2 of(BuildContext context) =>
    forWidth(MediaQuery.sizeOf(context).width);
```

**Raw logical pixels, never `.w`.** These are compared against the window,
which screenutil knows nothing about; a scaled threshold moves every time the
design scales and a device can land in two classes at once.

### Switch in the shell

```dart
return switch (SdBreakpointV2.of(context)) {
  SdWindowClassV2.compact => SdBottomNavigationV2(
    destinations: destinations, selectedIndex: i, onSelected: select, body: shell,
  ),
  SdWindowClassV2.medium || SdWindowClassV2.expanded => SdNavigationRailV2(
    destinations: destinations, selectedIndex: i, onSelected: select, body: shell,
  ),
};
```

### Share the cell, not the chrome

Extract the glyph cell and the destination value type into their own widgets,
used by both chromes. Everything about *being a destination* — fill, timing,
semantics, tap target — lives once, so a tab cannot look like one control on a
phone and a different one on a tablet.

What legitimately differs, and only because of the axis:

| What | Pill (phone) | Rail (tablet) |
|---|---|---|
| Layout | floats; body scrolls behind the glass | takes a **real column** |
| Thickness | vertical measure (`h56`) | **horizontal measure (`w56`)** |
| Cell per tab | 64 wide | 92–110 long |
| Inner margin | — | **none** — the gap is the content's own `pageMargin` |
| Swipe between tabs | yes | **no** |
| Scope it publishes | `edge: bottom` | `edge: leading` |

- **Real column, not floating.** A phone has no width to give away; a tablet
  does. A rail in its own column means no screen has to pad a side for it —
  which matters because screens build their horizontal insets by hand.
- **No swipe.** An adjacent-tab swipe is a thumb gesture on a one-handed
  device. At tablet width a horizontal drag is a chart being panned or a row
  being dismissed, and stealing it breaks both.
- **No inner margin on the rail.** The gap to the content is the content's to
  leave. An inner margin stacks on top of `pageMargin` and makes one of the
  three gaps bigger than the other two — exactly the bug §2 exists to close.

### The thickness-axis trap

A standing rail's thickness is a **horizontal** dimension. Take it off the
vertical ladder and screenutil punishes you: a landscape iPad's height ratio is
0.96 against a width ratio of 1.15, so the rail comes out **54 thick in
landscape against 64 in portrait** — one control, two thicknesses, depending on
how the tablet is held.

Cell *length* is the opposite and should stay vertical: 110 portrait against 92
landscape, so the short window gets the shorter rail. **Correct.**

### Reclaim the bottom inset

Tab screens pad their bottom to clear the floating pill. With the nav down the
side there is nothing on the bottom edge, and that padding becomes ~100pt of
dead space.

Make the flag mean what it says. `floatingNav: true` means *"I am a tab
screen"*, **not** *"there is a bar below me"*:

```dart
static double bottom(BuildContext context, {bool floatingNav = false}) =>
    floatingNav && SdFloatingBarScopeV2.isBelow(context)
    ? floatingBarInset(context) + bottomGap
    : detailBottom(context);
```

An `InheritedWidget` published by whichever chrome is up answers it, and the
same widget answers the three-way question §2 needs:

```dart
enum SdFloatingBarEdgeV2 { bottom, leading }

static SdFloatingBarEdgeV2? edgeOf(BuildContext context) =>
    context.getInheritedWidgetOfExactType<SdFloatingBarScopeV2>()?.edge;
```

`bottom` = phone pill · `leading` = tablet rail · **`null` = no shell nav**.

**Keep the dependency one-way.** The scope must not import your padding class:
padding is what asks the question, so the answer cannot depend on it. Have the
scope answer *presence and edge only*, and let each caller compute its own
distance.

---

## 4. Do not reflexively widen the grids

Measure before adding columns. With the content filling the window:

| Window | Card | 2-up cell | 3-up cell |
|---|---|---|---|
| phone 393 | 361 | 175 | 111 |
| iPad portrait 820 | 618 | 302 | 197 |
| iPad landscape 1180 | 978 | 482 | 320 |

A third column is only right if its cell stays **wider than the phone's** in
*both* orientations. Under a capped 690 column it would not have been; filling
the window it would. The answer depends on your §2 choice — so decide §2 first,
then measure, then decide the grids.

---

## 5. Measure the window, never the device

`MediaQuery.sizeOf(context).width`. **Never** `shortestSide`, never
`Platform.isIOS` + a model check, never `defaultTargetPlatform`.

An iPad in Split View hands the app a ~507-wide window. `shortestSide` still
says "tablet" and puts a navigation rail in a phone-shaped window. There is no
`UIRequiresFullScreen` in a modern iPad app, so this is the normal case, not an
edge case.

---

## 6. Test spec

Add a window-size parameter to your `pumpApp` helper, **defaulted to the phone
design size** so no existing test changes:

```dart
Future<PumpedApp> pumpApp(
  WidgetTester tester, {
  Size surfaceSize = const Size(393, 852),
  ...
}) async {
  tester.view.physicalSize = surfaceSize * 3;
  tester.view.devicePixelRatio = 3.0;
  ...
}
```

One test file, pumping 820×1180 and 1180×820, asserting:

| # | Assertion | Catches |
|---|---|---|
| 1 | a 16 gutter renders at ~`16 * maxScale`, not `16 * 2.09` | §1 regressed |
| 2 | **at 393 it renders at exactly 16** | §1 leaked onto phones |
| 3 | the three gaps are equal and equal to `tabletMargin` | §2 regressed |
| 4 | **at 393, `pageMargin == 0`** | §2 leaked onto phones |
| 5 | a pushed detail screen has the same card width, centred | the no-nav case |
| 6 | the app bar shares the content's left and right edges | header outside the margin |
| 7 | which chrome each width gets; content clears the nav | §3 switch |
| 8 | the rail is longer than thick, **one thickness in both orientations** | the axis trap |
| 9 | every tab still switches from the rail | dead cells down the rail |
| 10 | bottom inset reclaimed on tablet, **kept on phone** | the flag's meaning |
| 11 | no tab screen and no multi-step flow overflows, both orientations | the ordinary breakage |

Assertions 2, 4 and 10's second half are the important ones. They are what let
you ship this without re-verifying the phone build by hand.

**Measure the card, not the column box** — the box carries the screen's own
gutter inside it, and the gap the eye sees is to the card edge.

---

## 7. Port checklist

1. Confirm the tablet is a build target and note whether multitasking is on.
2. Add the scale clamp (§1). Verify a phone renders identically — this is the
   whole safety net.
3. Add the window classes (§2/§3), off `MediaQuery`, in raw pixels.
4. Decide **page vs panel** for every surface you have. Cap the panels.
5. Pick `tabletMargin`. Apply `pageMargin` around the whole Scaffold, with the
   `ColoredBox` behind it.
6. Check your router: are detail screens inside the shell branches or siblings
   of it? That decides whether you need the no-nav case.
7. Build the rail. Share the cell with the pill. Thickness on the **width**
   ladder.
8. Make the bottom-inset flag ask the scope.
9. Write the test file from §6 before you look at a simulator.
10. *Then* look at a simulator, and revisit the grids (§4).

## 8. Numbers, measured

Not calculated — what BaroEase renders at, for comparison against yours.

| | Card | Nav column | Nav thick | Cell | Nav length | All three gaps |
|---|---|---|---|---|---|---|
| phone 393×852 | window − 32 | — | — | — | — | — (16 gutter) |
| iPad portrait 820×1180 | 618 | 110 | 64 | 110 | 552 | 46 |
| iPad landscape 1180×820 | 978 | 110 | 64 | 92 | 462 | 46 |

## 9. Still open here, so decide them deliberately there

| Question | Note |
|---|---|
| Phone landscape | Allowing it is a separate project: a 390-tall window breaks multi-step flows and tall panels. Consider portrait-only on phone. |
| Two-column pages at ≥840 | The cheap version is splitting an existing `List<Widget>` of sections into two columns. |
| Master–detail | Expensive: the detail has to render inline, which is a router change, not a layout one. |
| Labels on the rail at ≥840 | Glyph-only keeps the pill and the rail one control. Adding labels to one splits them. |
