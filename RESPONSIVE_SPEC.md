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
| A bottom tab bar on phone | §3 is about replacing it on a tablet; skip if you have no tab bar |
| Tablet is a target (`TARGETED_DEVICE_FAMILY = "1,2"`) | Nothing below matters |

**The one invariant: every rule here is a no-op at phone width.** If applying
this moves a single pixel on an iPhone, something is wrong. Assert it.

---

## 1. Cap the scale ratio — and cap it on every ladder

### The trap

screenutil multiplies every `.w` / `.h` / `.r` / `.sp` by `window / designSize`,
with **no upper bound**. A 393-wide design on an 820-wide iPad scales 2.09; in
landscape the width ratio hits 3.0. The result is a screenshot enlarged.

This is the single largest tablet bug in a screenutil app, and it is invisible
in tests — nothing overflows, every number is just wrong.

### The second trap, which survives the obvious fix

**The four tokens do not read the same ratio.**

| Token | Used for | screenutil ratio |
|---|---|---|
| `w*` | horizontal spacing | width |
| `sp*` | type | width, via `ScreenUtilInit`'s default `fontSizeResolver` (`FontSizeResolvers.width`) — check your version, because `minTextAdapt` is inert beside a resolver |
| `h*` | vertical spacing | height |
| `r*` | **icons, radii, square tap targets** | the **smaller** of the two |

So clamping only the width leaves the height ratio free, and a tablet in
landscape is *shorter* than a phone design (820 against 852). Its height ratio
comes out 0.96, `.r` takes the minimum, and the app draws **23-wide icons and
42-wide tap targets — under Apple's 44 minimum — beside 18 gutters and 16
type**. Turning the tablet shrinks every glyph in the app.

### The fix

Grow the design to match the window, and once that clamp engages let the height
follow the same ceiling rather than a phone's floor:

```dart
final class SdScreenScale {
  const SdScreenScale._();

  /// "The same app at arm's length." Every spacing constant moves by this and
  /// nothing else, so the rhythm the design was drawn at survives.
  static const double maxScale = 1.25;

  static Size designSize(Size window, Size design) {
    final double width = math.max(design.width, window.width / maxScale);

    // Past this point the window is a tablet, and a tablet renders ONE scale.
    return Size(
      width,
      width > design.width
          ? window.height / maxScale
          : math.max(design.height, window.height / maxScale),
    );
  }
}
```

Wire it at the root. **Read through `MediaQuery`, not `View`** — a rotation or a
Split View resize must rebuild this:

```dart
ScreenUtilInit(
  designSize: SdScreenScale.designSize(MediaQuery.sizeOf(context), _designSize),
  splitScreenMode: true,
  builder: ...,
)
```

### Result

| | Gutter | V gap | Body | Title | Icon | Tap target |
|---|---|---|---|---|---|---|
| phone 393×852 | 16 | 16 | 14 | 22 | 24 | 44 |
| iPad portrait, width clamp only | 18.4 | 18.4 | 16.1 | 25.3 | 27.6 | 50.6 |
| iPad landscape, width clamp only | 18.4 | **15.4** | 16.1 | 25.3 | **23.1** | **42.3** |
| iPad, either orientation, both clamps | 20 | 20 | 17.5 | 27.5 | 30 | 55 |

The clamp cannot engage below `design.width * maxScale` (491 here), and the
widest phone shipped to is 440 — so a phone resolves exactly what it resolved
before the clamp existed. That is what makes this safe to ship.

### One number the framework will not scale for you

`kToolbarHeight` is a raw 56. At 1.25 an app bar's leading button is 55 and its
title 27 inside it — full to the edges, and an overflow at the next raise. Put
the toolbar height on your own vertical ladder and have the content inset and any
chrome that aligns to the bar read **that** number, not the constant.

### Pick your own `maxScale`

1.25 was chosen so type and touch targets grow enough for a tablet held further
away without the app reading as blown up; 1.15 read as a phone layout with a lot
of empty page around it. Anything in 1.15–1.30 is defensible. `1.0` is wrong —
it leaves a phone-sized app marooned on a big screen — and past ~1.4 you have
rebuilt the bug at the top of this section.

---

## 2. One gutter, and the chrome joined to the content

### The rule

**The nav panel meets the content region with no gap at all**, and inside that
region the screen keeps the same gutter it has on a phone. One gap on a tablet,
and it is a gap the app already had.

```text
iPad 11" portrait, 820 x 1180 — rendered, at maxScale 1.25
┌───────────────┬────┬──────────────────────────────┬────┐
│ panel 164     │ 20 │ app bar — same edges below   │ 20 │
│ (window / 5)  │    ├──────────────────────────────┤    │
│ Home          │    │ card 616 — fills what is left│    │
│ History  …    │    │                              │    │
└───────────────┴────┴──────────────────────────────┴────┘
```

### Why not a max-width column

The obvious move is `maxWidth: 920` + centre. Do not: it produces three
*different* gaps — the page margin, the gap to the nav, and the leftover on the
far side — because two of them are left over from a ceiling and only one is a
decision. Let the content **fill** what the panel leaves.

### Why not a margin around the nav either

BaroEase shipped that first: one number (46) at the screen edge, between rail
and content, and at the far edge. It is defensible, and it is one more number
than a joined panel needs. A panel that runs to the window edge and meets the
content has exactly one gap left to get wrong — so there is **no page margin at
all**, and the scaffold is a plain `Scaffold`.

### Screens with no nav fill the window

A detail screen pushed **above** the shell has no panel beside it, and nothing
to leave room for. It runs the full width with its own gutter.

BaroEase tried the other way first — half a panel per side, so the detail's card
matched the tab screen's — and took it back out. Two reasons, and the second is
the one that settles it:

- Against a rail the match cost 55 per side and nobody saw it; against a panel
  it costs `window / 10`, which is a visible phantom margin the shape of a
  chrome that is not there.
- **A collapsible panel has no single width to match.** Collapsed, the tab
  screen is nearly the whole window while the detail it opens would still be a
  fifth narrower.

What it costs: pushing a detail from an expanded panel widens the content by a
fifth of the window. The panel disappearing is the larger change on screen, and
it is the one the transition is about.

**Check your router first.** In BaroEase the detail routes are *siblings* of
`StatefulShellRoute`, not children of its branches, which is why they lose the
panel at all. If your details render inside the branches they keep it, and none
of this comes up — that is the better answer if you can afford the router work.

### Pages take gutters; panels keep ceilings

| Kind | Rule | Examples |
|---|---|---|
| **Page** — fills the window | one gutter, no margin, no ceiling | every screen |
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

## 3. The nav becomes a collapsible panel on the leading edge

### Window classes

Material's boundaries, unchanged — they are where the hardware is (11" iPad is
820 portrait / 1180 landscape, 13" is 1024 / 1366), and inventing your own puts
a boundary in the middle of a device.

```dart
enum SdWindowClassV2 { compact, medium, expanded }

static const double medium = 600;   // the panel appears at or above this
static const double expanded = 840; // where a second column would appear

static SdWindowClassV2 of(BuildContext context) =>
    forWidth(MediaQuery.sizeOf(context).width);
```

**Raw logical pixels, never `.w`.** These are compared against the window,
which screenutil knows nothing about; a scaled threshold moves every time the
design scales and a device can land in two classes at once.

### Switch in the shell, and let the host own the state

```dart
return switch (SdBreakpointV2.of(context)) {
  SdWindowClassV2.compact => SdBottomNavigationV2(
    destinations: destinations, selectedIndex: i, onSelected: select, body: shell,
  ),
  SdWindowClassV2.medium || SdWindowClassV2.expanded => SdNavPanelV2(
    destinations: destinations, selectedIndex: i, onSelected: select, body: shell,
    isExpanded: _expanded, onExpansionChanged: _setExpanded,
    expandLabel: l10n.navPanelExpand, collapseLabel: l10n.navPanelCollapse,
  ),
};
```

The host owns `isExpanded`; the panel is told. Toggling must keep the selected
tab and all of its navigation state — free with
`StatefulShellRoute.indexedStack`, and worth verifying anyway, because it is the
single most annoying thing to get wrong. Log the change **with its value**
(`{expanded: false}`), not just that something happened. Whether it persists
across launches is your call; BaroEase does not persist it, because the panel is
what names the destinations for a user arriving on a tablet.

### Geometry

Design units, before the scale of §1 multiplies them:

| Thing | Value | Note |
|---|---|---|
| Panel width, expanded | `window / 5` | **raw window pixels**, not a design unit — it is a slice of the window |
| Panel width, collapsed | 0 | it draws nothing at all |
| Destination row height | 56 | one per destination |
| Row gutter | 16 horizontal | the screen's own gutter |
| Gap, glyph to label | 12 | |
| Capsule inset | 4 horizontal, 4 vertical | inside the row, paint only |
| Capsule radius | 24 | `56 / 2 - 8 / 2`, concentric with the row |
| Capsule fill | primary at 22% | the same tint as the pill's thumb |
| Toggle tap target | ≥ 48 square | platform minimum, at every text scale |

**Proportional, not a fixed width.** A fixed panel is either too wide on a
portrait tablet or too narrow on a landscape one. **The width is raw window
pixels; the row height is on the vertical ladder** — one is measured across the
panel, the other along it.

The content column must never read narrower than a phone. That is the trade the
panel is made against, and the direction it may never go. Assert it.

### Share the cell, not the chrome

One cell widget, one destination value type, used by both chromes. Everything
about *being a destination* — fill, timing, semantics, tap target — lives once,
so a tab cannot look like one control on a phone and a different one on a
tablet. What legitimately differs:

| What | Pill (phone) | Panel (tablet) |
|---|---|---|
| Layout | floats; body scrolls behind the glass | a **real column**, joined to the content |
| Cell | glyph only — five words do not fit at phone width | glyph, gap, label |
| Collapses | no | to nothing at all |
| Swipe between tabs | yes | **no** |
| Scope it publishes | `edge: bottom` | `edge: leading`, open or collapsed |

**Shape is an enum on the cell, not a `showLabel` bool.** Two chromes today and
a third is not unthinkable; a boolean per difference is how one cell becomes
four unrelated looks nobody can name.

**No swipe.** An adjacent-tab swipe is a thumb gesture on a one-handed device.
At tablet width a horizontal drag is a chart being panned or a row being
dismissed, and stealing it breaks both.

### Collapsed, it draws nothing — the part most implementations get wrong

Not a narrow rail, not a strip of chrome above the content. The reopen control
goes **into the screen's own leading slot**, the way every app with a drawer
does it.

The tempting alternative is a strip holding the menu icon above the content. Do
not. That strip:

- belongs to no screen, so every screen is pushed down by it;
- duplicates ownership of the top safe inset — the strip pays it, so the content
  underneath must be told not to pay it again, and that coordination is a bug
  waiting in every new screen;
- leaves an empty band under the icon that no amount of tuning makes look
  intentional.

Three pieces, each with one job:

1. **A scope** — an `InheritedWidget` the panel publishes over the content
   column, carrying `isExpanded`, an `onExpand` callback and the localized
   label. **State and a callback, never a widget**: a look that arrived through
   an inherited widget is one two chromes could draw differently without either
   file saying so.
2. **A toggle widget** — the button, plus one static that reads the scope and
   returns the control or null.
3. **Every chrome with a leading slot calls that static. No screen does.** A
   screen that could place the control is a screen that could forget to, and the
   one that forgets is the one a user gets stuck on.

```dart
final Widget? barLeading =
    leading ?? (canPop ? backButton : SdNavPanelToggleV2.collapsedOf(context));
```

- A screen that passed its own `leading` keeps it — it has a reason to own that
  slot, and gets the control back when it lets go.
- A back arrow outranks the menu: a route with something to pop is a route the
  panel is not beside. If your detail routes render on the root navigator they
  read no scope at all and this never comes up; if they render inside a branch,
  the `canPop` check is what stops a back arrow and a hamburger fighting over
  one slot.
- **Give the key to exactly one control.** While collapsing, the panel is still
  painting and the chrome has already claimed its control — the panel's own
  toggle carries the key only while `isExpanded` is true, `collapsedOf` only
  while it is false.

Expanded, the toggle sits in the panel's own header, aligned to the trailing
edge, in a box one toolbar tall so it lands where the app bar's own leading
button lands and does not jump as the panel closes. It is separate from the
destinations so it never reads as one more tab, and **the glyph is the same in
both states** — it is the menu. Distinguish the states by tooltip and by
`Semantics(expanded:)`, never by swapping the icon.

### Paint the panel AFTER the content

The trap that cost BaroEase a whole shipping cycle of an unreachable chrome:
**a full-screen route's modal barrier blocks the semantics of everything painted
before it.** The content column is a `Navigator` full of such routes, so a panel
laid out as the first child of a `Row` has its destinations silently dropped
from the semantics tree — the chrome renders, responds to taps, and does not
exist to a screen reader.

Lay the two regions out in a `Row` (a spacer of the panel's width, then
`Expanded`), and draw the panel over its own strip from a `Stack` above it. It
covers only its own width, so nothing below it loses a tap.

### Motion

- Animate the **joined** panel and content widths, so the transition shows where
  the working space moves. A cross-fade hides the one thing worth seeing.
- 250ms, `Curves.easeInOutCubic`. The sliding selection capsule runs on the same
  duration and curve.
- Honour reduced motion: `MediaQuery.disableAnimationsOf(context)` →
  `Duration.zero`, and the width changes on the next frame.
- **Reversing mid-animation must not overflow.** Lay the panel's children out at
  full width inside an `OverflowBox` and clip, so the contents never reflow as
  the width travels — reflowing them is what produces the overflow stripes.
- A panel still painting at 3px wide must not be tappable and must not be read
  out: `IgnorePointer` and `ExcludeSemantics` while it is on its way out.

### Accessibility

- Toggle target ≥ 48 square, at every text scale, in both themes. A fixed square
  around a glyph is what makes that true without a test per scale.
- `Semantics(expanded: …)` on the toggle; the tooltip is the localized "Expand
  navigation" / "Collapse navigation". A tooltip is a user-facing string.
- **Each destination is one semantics node carrying its label**, with
  `container: true` so it is a node of its own rather than an annotation merged
  into whatever is above it. The panel paints the label, so the cell must
  `excludeSemantics` its children or a reader says the word twice and a test
  looking a destination up by name finds a node that is no longer the cell.
- Selection is signalled by weight and colour, never colour alone.

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

`bottom` = phone pill · `leading` = tablet panel, **open or collapsed** ·
**`null` = no shell nav**.

**Keep the dependency one-way.** The scope must not import your padding class:
padding is what asks the question, so the answer cannot depend on it. Have the
scope answer *presence and edge only*, and let each caller compute its own
distance.

---

## 4. Do not reflexively widen the grids

Measure before adding columns. With the content filling the window:

| Window | Card | 2-up cell | 3-up cell |
|---|---|---|---|
| phone 393 | 361 | 175 | 112 |
| iPad portrait 820, panel open | 616 | 300 | 195 |
| iPad landscape 1180, panel open | 904 | 444 | 291 |

A third column is only right if its cell stays **wider than the phone's** in
*both* orientations. A card capped well below the window fails that test; a card
that fills what the panel leaves passes it. So the answer depends on your §2
choice — decide §2 first, then measure, then decide the grids. And note that a
collapsible panel gives every window **two** card widths, so a count chosen off
one of them changes under the toggle.

---

## 5. Measure the window, never the device

`MediaQuery.sizeOf(context).width`. **Never** `shortestSide`, never
`Platform.isIOS` + a model check, never `defaultTargetPlatform`.

An iPad in Split View hands the app a ~507-wide window. `shortestSide` still
says "tablet", and a chrome that asked it would put a fifth of a phone-shaped
window behind a nav panel. There is no `UIRequiresFullScreen` in a modern iPad
app, so this is the normal case, not an edge case.

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
| 1 | all four ladders render at `base * maxScale`, **the same in both orientations** | §1 regressed, on the ladder that is easiest to miss |
| 2 | **at 393 all four render at exactly their base** | §1 leaked onto phones |
| 3 | the panel is exactly `window / 5` open and exactly 0 collapsed, at the breakpoint and both orientations | §3 geometry |
| 4 | the content keeps one gutter either side in both states, and a pushed screen fills the window | §2 regressed |
| 5 | **at 393 the gutter and the chrome are unchanged** | §2 and §3 leaked onto phones |
| 6 | the content column is wider on both tablet orientations than on a phone | the trade going the wrong way |
| 7 | a pushed detail screen starts at the window edge | a phantom margin for an absent chrome |
| 8 | the app bar shares the content's left and right edges | header outside the margin |
| 9 | collapsed, the control is a descendant of the app bar, and the bar is `toolbarHeight + topInset` | the strip creeping back |
| 10 | expanded, the control is not in the app bar — **exactly one exists at all times, mid-animation included** | two controls under one key |
| 11 | collapse, reverse, expand, reverse: no exception, no overflow, widths strictly between 0 and full | the reflow overflow |
| 12 | reduced motion changes the width on the next frame; motion on does not | the reduced-motion branch |
| 13 | every destination still switches **through the semantics tree, by label** | a chrome a screen reader cannot reach |
| 14 | the toggle's target clears 48 | the tap target |
| 15 | bottom inset reclaimed on tablet, **kept on phone** | the flag's meaning |
| 16 | no tab screen and no multi-step flow overflows, both orientations, **open and collapsed** | the ordinary breakage |

Assertions 2, 5 and 15's second half are the important ones. They are what let
you ship this without re-verifying the phone build by hand. **13 is the one that
would have caught a bug nobody saw**: the chrome was painted before the content
and a route's modal barrier dropped it from the semantics tree entirely.

**Measure the card, not the column box** — the box carries the screen's own
gutter inside it, and the gap the eye sees is to the card edge.

---

## 7. Port checklist

1. Confirm the tablet is a build target and note whether multitasking is on.
2. Add the scale clamp (§1). Verify a phone renders identically — this is the
   whole safety net.
3. Add the window classes (§2/§3), off `MediaQuery`, in raw pixels.
4. Decide **page vs panel** for every surface you have. Cap the panels.
5. Give pages no horizontal margin at all — the gutter inside each screen's
   scrollable is the whole of it.
6. Check your router: are detail screens inside the shell branches or siblings
   of it? That decides whether you need the no-nav case.
7. Build the panel. Share the cell with the pill, behind a shape enum. Width in
   raw window pixels; row height on the vertical ladder. **Paint it after the
   content.**
8. Add the scope and the toggle, and call `collapsedOf` from every chrome with
   a leading slot — from the chrome, never from a screen.
9. Make the bottom-inset flag ask the scope.
10. Write the test file from §6 before you look at a simulator.
11. *Then* look at a simulator, and revisit the grids (§4).

## 8. Numbers, measured

Not calculated — what BaroEase renders at, for comparison against yours.

Rendered values, not design units — `maxScale` is 1.25 here, so a 16 gutter
paints at 20 and a 56 row at 70.

| | Panel | Content region | Card | Nav row | Gutter |
|---|---|---|---|---|---|
| phone 393×852 | — | 393 | 361 | 56 (pill) | 16 |
| iPad portrait 820×1180 | 164 | 656 | 616 | 70 | 20 |
| iPad landscape 1180×820 | 236 | 944 | 904 | 70 | 20 |
| iPad portrait, collapsed | 0 | 820 | 780 | 70 | 20 |
| iPad landscape, collapsed | 0 | 1180 | 1140 | 70 | 20 |
| iPad, pushed detail | — | window | window − 40 | — | 20 |

## 9. Still open here, so decide them deliberately there

| Question | Note |
|---|---|
| Phone landscape | Allowing it is a separate project: a 390-tall window breaks multi-step flows and tall panels. Consider portrait-only on phone. |
| Two-column pages at ≥840 | The cheap version is splitting an existing `List<Widget>` of sections into two columns. |
| Master–detail | Expensive: the detail has to render inline, which is a router change, not a layout one. |
| The panel at exactly 600 | A fifth of 600 is a 120 column and the labels have to shrink to fit it. Consider glyph-only below 840 if that window is a real one for your app. |
| Persisting the collapse | Not persisted here: the panel is what names the destinations for a user arriving on a tablet, and a remembered collapse hides that on the one launch it matters. |
