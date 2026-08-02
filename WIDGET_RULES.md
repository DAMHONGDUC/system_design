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
| Anything in `core/` | `Sd` + name, **no suffix** | `SdSpacingConstant` |

The `V2` suffix is the generation of the design system, not a version of the
individual widget. Things in `core/` carry no look, so they belong to no
generation and take no suffix. A widget is never renamed to `V3` on its own —
a whole new generation gets a new folder next to `v2/`, and both ship at once while an
app migrates.

## 3. Layout

**One folder per widget, and the folder is named after the file:**

```
lib/
  index.dart                  # the package's only entry point
  core/
    sd_spacing_constant.dart  # no look, no generation, no suffix
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
