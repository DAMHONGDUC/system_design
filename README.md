# system_design

The shared design system: presentation-only widgets, spacing primitives, and
the theme *contract* they read. Consumed by an app as a path dependency on a
git submodule.

**The palette is not in here.** The host app owns its colours and text styles
and hands them over through a `ThemeExtension`, so the same widget set renders
in a different brand without a line changing here.

## Use it

```yaml
dependencies:
  system_design:
    path: packages/system_design
```

```dart
import 'package:system_design/index.dart';
```

One import, and that is the only supported entry point.

Then register the theme contract once, in the app's own `ThemeData`:

```dart
ThemeData(
  colorScheme: scheme,
  textTheme: textTheme,
  extensions: <ThemeExtension<dynamic>>[
    SdThemeV2(
      background: AppColors.background,
      surfaceElevated: AppColors.surfaceElevated,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      chartGrid: AppColors.chartGrid,
      barrier: AppColors.barrier,
    ),
  ],
)
```

Widgets read `context.colorScheme` and `context.textTheme` for everything
Material already names, and `context.sdTheme` for the six slots it does not.
Forgetting to register it asserts at the first widget that needs a colour —
loudly, rather than rendering the wrong thing.

## Layout

```
lib/
  index.dart                  # THE entry point — the only import a consumer needs
  core/
    sd_spacing_constant.dart  # raw dimensions, shared by every generation
  v2/
    index.dart                # every widget below, re-exported by lib/index.dart
    sd_banner_v2/
      sd_banner_v2.dart
    sd_button_v2/
      sd_button_v2.dart
    …                         # one folder per widget, ~40 of them
```

`core/` is what does not belong to a widget generation: `SdSpacingConstant`,
the screenutil dimensions any version of the system measures in. It carries no
look, so it carries no version.

`v2`, `v3`, and `v4` are isolated generations. Finances Calculator consumes
`v4`; prior generations remain frozen for their existing products.

`v2` is the generation of the system, and owns everything that does have a
look. A future generation gets a `v3/` folder beside it with its own index,
exported from `lib/index.dart` too, so an app can migrate widget by widget
instead of all at once.

## What is in v2

**Tokens and contract** — `SdSpacingConstant` (in `core/`), `SdContentPaddingV2`, `SdThemeV2`,
`SdContextV2X` (`context.theme` / `.colorScheme` / `.textTheme` / `.sdTheme`),
`SdTextStyleV2X` (`.semiBold`, `.muted(context)`).

**Chrome** — `SdScaffoldV2`, `SdAppBarV2`, `SdAppBarButtonV2`,
`SdGlassCircleV2`, `SdGlassV2`, `SdPinnedFilterBarV2`,
`SdCollapsingFilterScaffoldV2`, `SdActionViewV2`.

**Controls** — `SdButtonV2`, `SdIconButtonV2`, `SdIconV2`, `SdSwitcherV2`,
`SdValueSliderV2`, `SdFilterPillV2`, `SdFilterChipV2`.

**Surfaces** — `showSdDialogV2` / `SdDialogV2`, `showSdBottomSheetV2`,
`SdSheetHeaderV2`, `SdSheetContentV2`, `showSdFilterSheetV2`,
`SdSnackBarUtilsV2`.

**Content** — `SdBannerV2`, `SdBenefitRowV2`, `SdSectionHeaderV2`,
`SdEmptyStateV2`, `SdIconBadgeV2`, `SdColorDotV2`, `SdFittedTextV2`,
`SdRefreshIndicatorV2`, spacing widgets.

**Charts** — `SdChartFrameV2` (title + VoiceOver summary + plot),
`SdChartCardV2`, `SdChartStyleV2` (axes, grid, tooltips), `SdBarChartV2`,
`SdDonutChartV2` + `SdDonutLegendV2`, `SdProgressRowV2`.

**Motion** — `SdPressableScaleV2`, `SdPopScaleV2`.

## What is deliberately NOT in here

Anything that needs a string of its own or reaches into an app. In the
migraine tracker that leaves, in `lib/core/widgets/`: `AppTimePickerSheet`,
`MedicationNameDialog`, `PermissionSettingsSheet` (localized copy),
`PremiumGate` (watches a provider), `SeverityBreakdownChart` (reads the app's
severity bands, then composes `SdDonutChartV2`), and `sections/` (settings
rows bound to app features).

That boundary is the whole point. See **[WIDGET_RULES.md](WIDGET_RULES.md)**
before adding anything.

## The release pipeline is in here too

`tool/` holds the scripts every app embedding this system runs — `set-up.sh`,
`prepare-env.sh`, `build-ipa.sh`, `deploy-firebase.sh`, `release.sh` — and
`tool/fastlane/Fastfile` holds the four iOS lanes: `beta`, `upload`,
`preflight`, `certificates`. None of them names an app.

An app wires itself in with `ios/fastlane/Fastfile`, and that file is only this:

```ruby
import "../../packages/system_design/tool/fastlane/Fastfile"

sd_ios_app(
  team_id: "WNG5UWNJ6H",
  targets: [
    { name: "Runner", bundle_id: "app.dd.migraine.tracker",
      entitlements: "Runner/Runner.entitlements" },
    { name: "BaroEaseWidgetExtension", bundle_id: "app.dd.migraine.tracker.BaroEaseWidgetExtension",
      entitlements: "BaroEaseWidget/BaroEaseWidget.entitlements" },
  ],
)
```

| Argument | What it is |
|---|---|
| `team_id` | The Apple Developer team. Goes into signing and the export plist. |
| `targets` | **Ordered.** The first is the app — its bundle id is what every upload, config check and TestFlight query uses. The rest are extensions: they get a profile and an export entry, never an upload of their own. |
| `entitlements` | A path under `ios/`, optional. Given, the lane checks the installed profile carries every key the file claims *before* the build; omitted, that target is skipped. |
| `flavors` | Defaults to `%w[dev prod]` — the values `flavor:` accepts, and the aliases it looks up in `.firebaserc`. |

The pipeline adapts to what the app has rather than demanding all of it: no
`.firebaserc` means no Firebase backend, so `release.sh` skips the deploy and
the lane skips the flavored-config check — announced by name, never silently.

A lane defined *below* the import wins over the shared one of the same name.
That is the escape hatch, and it exists so one app's special case never has to
be pushed up into everyone else's pipeline.

## Check

```bash
cd packages/system_design
flutter analyze     # must pass standalone, without the host app
```
