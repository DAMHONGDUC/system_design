# Writing a System Design widget

The rules that decide whether a widget belongs here, and what it must look
like once it does. If a change breaks one of these, it belongs in the app, not
in this package.

---

## 1. The admission test

A widget may live here only if **both** are true. There is no third case.

1. **It takes every user-facing string as a parameter.** No `AppLocalizations`,
   no ARB, no `context.l10n`, no hardcoded English. Tooltips and semantics
   labels are user-facing strings too — `SdSheetHeaderV2` takes
   `closeTooltip` and `confirmTooltip` for exactly this reason.
2. **It imports nothing from a host app.** No repository, no provider, no
   router, no domain entity, no analytics, no logger. If a widget needs to
   know a domain concept to render, the app keeps that widget and passes this
   package a value type instead — that is why `SdDonutChartV2` takes
   `List<SdDonutSliceV2>` rather than the app's severity bands.

Failing either test is not a reason to weaken the rule. It is the answer:
the widget stays in the app and composes the pieces from here.

## 2. Naming

| Thing | Rule | Example |
| --- | --- | --- |
| Widget class | `Sd` + name + `V2` | `SdBannerV2` |
| Enum / value type | same | `SdButtonVariantV2`, `SdBarV2` |
| Static-only holder | same, `final class` | `SdChartStyleV2` |
| Presenter function | `showSd` + name + `V2` | `showSdBottomSheetV2` |
| File and folder | snake_case of the class | `sd_banner_v2/sd_banner_v2.dart` |
| Anything in `core/` or `core/common/` | `Sd` + name, **no suffix** | `SdSpacingConstant`, `SdLogger` |

The `V2` suffix is the generation of the design system, not a version of the
individual widget. Things in `core/` carry no look, so they belong to no
generation and take no suffix. A widget is never renamed to `V3` on its own —
a whole new generation gets a new folder next to `v2/`, and both ship at once while an
app migrates.

### There are two generations now, and they never import each other

`v2/` is what **BaroEase** renders. `v3/` is what **Reseller Studio** renders. Both
are exported from `lib/index.dart` and both are live — this is the situation
the paragraph above describes, not a migration in progress.

**`v3` is not a port of `v2`.** It repeats several widget names because both
products need a button and a card, and it repeats several *token* names
because both need a background colour. That is convergence, and it stops
there:

- **No file under `v3/` may import from `v2/`, or the reverse.** The two are
  built on incompatible premises — v2 is dark-only with frosted-glass chrome
  that the body scrolls behind; v3 ships light and dark with opaque chrome
  that takes real layout space. `SdContentPaddingV3` is a fifth the size of
  `SdContentPaddingV2` for exactly that reason, and sharing either would drag
  one product's chrome into the other's.
- **`core/` is still shared, and still the only shared thing.** Both
  generations measure in `SdSpacingConstant`. Adding a getter there is fine
  and additive; changing or removing one is a change to a shipped app.
- **`v2/` is frozen for `v3` work.** If a v3 widget wants a behaviour a v2
  widget already has, copy the idea and write it in v3 — never edit v2 to
  suit a product it does not ship in.

**Every generation-scoped name carries its suffix, including extension
members.** v3's `BuildContext` getters are `theme3` / `colorScheme3` /
`textTheme3` / `sdTheme3` and its `TextStyle` getters are `semiBold3` /
`muted3`, precisely so that a file importing the package index gets both
generations' extensions without either shadowing the other. An unsuffixed
member on a generation's extension is a bug, not a convenience.

v3 also carries token holders v2 never had — `SdRadiusV3` (semantic radii),
`SdMotionV3` (durations and curves), `SdElevationV3` (shadows) and the extra
slots on `SdThemeV3` (`profit`/`loss`, the status accents, `border`/`divider`,
`shadow`). They are listed here so nobody adds another by hand at a call site.

**Both generations render liquid glass, and neither shares the code.** v2 has
`SdGlassV2` and its frosted app bar; v3 has `SdGlassV3` and
`SdGlassNavBarV3`. Each declares its own `ImageFilter.isShaderFilterSupported`
gate and its own `LiquidGlassSettings`, because the two products need
different tuning — v2 is dark-only and tuned calm for photophobic users, v3
ships light and dark and sits over columns of money where chromatic
aberration would blur digits. The support check is four lines; copying it is
cheaper than the coupling.

### `core/common/` is app infrastructure, and it plays by different rules

Everything above is about rendering. `core/common/` is the one place in this
package that is not: it holds the plumbing every app of ours stands up
identically — `SdLogger` and the `SdCrashReporter` contract today.

- **Pure Dart, no Flutter, ever.** It is exported from `common.dart`, a second
  entrypoint next to `index.dart`, precisely so a feature's `domain/` can log
  without importing a widget library. A `package:flutter/*` import in here
  breaks that for every app at once.
- **No vendor SDK, ever.** `SdCrashReporter` is an interface and a no-op; the
  Crashlytics (or Sentry, or anything) implementation stays in the host app
  and arrives through `SdCrashReporter.attach`. That is the whole reason this
  can be shared: an app that reports nothing pays no dependency for it.
- **The `Sd` prefix still applies** — owner's rule, and it is why the naming
  table above covers `core/common/` in the same row as `core/`. One package,
  one prefix: a reader seeing `SdLogger` in an app file knows without looking
  that it is shared code, and that is worth more than a name that reads
  slightly more naturally in one app.
- **Additive only.** A second app is already calling these. Adding a method is
  fine; changing a signature is a change to a shipped app, same as `core/`.

Anything with a look, a token or a `BuildContext` is not common — it is a
generation's, and it goes in `v2/` or `v3/`.

## 3. Layout

**One folder per widget, and the folder is named after the file:**

```
lib/
  index.dart                  # widgets + tokens; re-exports common.dart
  common.dart                 # pure-Dart entry point, safe from domain/
  core/
    sd_spacing_constant.dart  # no look, no generation, no suffix
    common/
      sd_logger.dart          # app infrastructure, not rendering
      sd_crash_reporter.dart  # the contract only — never a vendor SDK
  v2/
    index.dart                # exports every folder below
    sd_banner_v2/
      sd_banner_v2.dart         # the widget
      sd_banner_v2_leading.dart # part files, if it needs them
```

Adding a widget is: one folder, one file, one `export` line in
`v2/index.dart`. Nothing else in the package changes. Never add a grouping
folder (`buttons/`, `charts/`) — the flat list with one folder each is what
keeps the index mechanical.

**`core/` is not a dumping ground.** A file belongs there only if it has no
look at all and every future generation would use it unchanged — raw
dimensions qualify, a colour or a text style would not. When in doubt it goes
in `v2/`; moving something down into `core/` later is cheap, and pulling it
back out after two generations depend on it is not.

Consumers import exactly one thing:

```dart
import 'package:system_design/index.dart';
```

## 4. Tokens — where every value comes from

Nothing in this package hardcodes a colour, a font size, or a dimension.

| Need | Source |
| --- | --- |
| primary, onPrimary, secondary, error, surface | `context.colorScheme` |
| background, surfaceElevated, textPrimary, textSecondary, chartGrid, barrier | `context.sdTheme` (the `SdThemeV2` extension) |
| any text style | `context.textTheme` |
| semi-bold, muted | `.semiBold`, `.muted(context)` on `TextStyle` |
| any dimension | `SdSpacingConstant` — `w*` horizontal, `h*` vertical, `r*` square/radius, `sp*` font |
| screen/content insets | `SdContentPaddingV2` |
| a chrome glyph | `Symbols.*_rounded` (`material_symbols_icons`) |

**Chrome glyphs are Material Symbols Rounded**, and that is why the package
depends on `material_symbols_icons`. A handful of widgets have to draw a glyph
nobody passes them — a sheet's close cross, a back arrow, a filter pill's
funnel, a radio dot — and the host app draws Symbols everywhere else, so a
sheet whose cross came from Material Icons put two icon families on one
screen. It is a font dependency like `flutter_svg`, not a look: the host still
owns every colour.

**`SdIconV2` takes a `fill`** (0 outline, 1 solid), because Symbols is a
variable font: a selected tab and an unselected one are the same glyph at two
fill values, not two glyph names.

The host app owns the palette: it builds an `SdThemeV2` from whatever its own
colours are and registers it on `ThemeData.extensions`. A widget that reads
`context.sdTheme` therefore renders in the app's colours without the package
knowing any of them.

`context.sdTheme` asserts when the app forgot to register the extension — a
widget test that pumps a bare `MaterialApp` will fail loudly. Pump the app's
theme; that is what the app renders.

**A static holder that needs a colour or a text style takes a
`BuildContext`.** `SdChartStyleV2.tooltipLabel(context)`, not a getter — a
static getter cannot reach the theme, and a constant baked in at
authoring-time is exactly the coupling this package exists to avoid. Only
pure dimensions stay parameterless (`SdChartStyleV2.plotHeight`).

## 5. Widget shape

- **Composition over config flags.** Two booleans that select three looks
  should be one enum prop. The look is a prop, never a named constructor:
  `SdButtonV2(variant: SdButtonVariantV2.primary, …)`.
- **Extract at ~80 lines.** A widget that outgrows it splits into `part`
  files inside its own folder.
- **No `_buildX()` methods.** A `Widget _buildHeader()` inside a `State` is a
  fake split — Flutter cannot scope the rebuild. Extract a real widget class.
- **Every `Text` carries an explicit `style:`.** Never lean on the ambient
  `textTheme` implicitly; read it and pass it.
- **Every icon is an `SdIconV2`** and always resolves to a concrete size —
  never let an icon inherit an ambient one.
- **Never `var`.** Explicit types everywhere, `final`/`const` where possible.
- **Declarations first, blank line, then logic.** No interleaving.
- **No standalone top-level functions**, except the sanctioned presenters
  (`showSdBottomSheetV2`, `showSdDialogV2`, `showSdFilterSheetV2`).

## 6. Behaviour

- **Animations stay calm**: fade / scale / slide, ≤400ms, gentle curves.
  Nothing flashes, strobes, or pulses — the system targets photophobic users,
  and this is not negotiable for a "delightful" micro-interaction.
  - **A skeleton is a rectangle at `SdSkeletonV2.radius` (8), always** —
    owner's rule, and the radius is not a prop. One shape means a screen's
    placeholders read as one loading state instead of a pile of unrelated
    blocks, and it deliberately does not match the thing underneath: pills
    for lines and card radii for cards had every skeleton impersonating a
    different component, which is how a placeholder starts being mistaken for
    content. No circles, avatar or not.
  - **This is why `SdSkeletonV2` is a still block.** Every other design
    system's skeleton shimmers, and the gentle breathing fade looks like the
    safe compromise — it is not. A placeholder animating on a loop is a light
    source moving in the user's periphery for as long as the network takes,
    which is the rule above with a longer duration. The shape was the useful
    half anyway: it reserves the right space so nothing reflows when the data
    lands, and the surface's spinner is what says the app is still working.
- **A control's tap target is the whole cell it looks like, never the ink
  inside it.** `SdSegmentedTabsV2` centred each segment's `GestureDetector`
  on its own line of text, so ~20 of the track's 42 was live and a tap near
  either edge — most of a thumb's spread — landed on nothing; the row of
  segments stretches to the track now. Applies to anything laid out in a
  track, a row or a grid: the hit box is the cell, and any inset that makes
  it look smaller is paint.

- **Colour is never the only signal.** A state told by colour is also told by
  an icon, a label, or a shape. `SdSnackBarKindV2` changes the glyph as well
  as the accent for exactly this reason.
- **Charts hide their marks from screen readers** and expose a summary
  instead — `SdChartFrameV2` takes `semanticsLabel` and wraps its child in
  `ExcludeSemantics`. A chart without that label is unreadable to VoiceOver.
- **A widget owns only its own intrinsic size.** Anything another widget pads
  by is a static on `SdContentPaddingV2`, never a number typed at a call site.

## 7. Before you commit

```bash
cd packages/system_design
flutter analyze     # must pass on its own, without the host app
```

The package compiles standalone. If it only analyzes from inside an app, an
app dependency leaked in — find it and take it back out.

Then check the diff for: a literal colour, a raw number in a widget, a
hardcoded string, and an import that starts with anything other than
`package:flutter`, `package:fl_chart`, a declared dependency, or `../sd_*`.
Those four greps catch almost every violation of the rules above.
