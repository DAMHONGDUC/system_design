# Flavour config — portable spec

Written to be applied to **another app**, not to describe this one. Every name
below is a thing you create; Reseller Studio is referenced only as a worked
example.

## 0. Premises

| Assumption | If your app differs |
|---|---|
| Flutter, Firebase, more than one project (dev / prod) | One project — nothing here matters |
| A build's config arrives in two halves: dart-defines and the native SDK files | You pass `FirebaseOptions` from Dart — one half only, skip to §6 |
| A script installs the native files per flavour | Flavour-specific Xcode configs or Gradle product flavours pick them — the trap is narrower, not gone; keep §2 |
| A bootstrap that runs steps before `runApp` and can open on an error screen instead of the router | Build that first; a guard with nowhere to send the user is a white screen |

**The invariant: the guard fires on a mismatch, never on an absence.** An app
whose backend is not configured yet must still run. If applying this breaks a
fresh clone, you have built the wrong check.

---

## 1. The trap

A build's configuration has two halves, and nothing ties them together:

| Half | Comes from | Read by | Decides |
|---|---|---|---|
| Dart | `env/<flavour>.json` via `--dart-define-from-file` | your `AppEnv` | what the app *thinks* it is |
| Native | `GoogleService-Info.plist`, `google-services.json` | the Firebase SDK | which database it *actually* writes to |

One script installs both. Run the app before that script, or after running it
for the other flavour, and the two halves name different projects.

**Nothing fails.** Each half is valid on its own, so there is no exception, no
log line and no failed build. The app compiles, installs, launches, signs in
and works — against the wrong project. The symptom people report is the
giveaway and reads as a non-problem:

> the dev build with prod's Firebase behaves normally, and prod with dev's
> Firebase behaves normally too

Nothing else catches it:

- **Tests do not.** They run with no flavour at all, so both halves are empty
  and agree.
- **The build does not.** The dart-defines and the plist are read by different
  toolchains at different times; neither has the other in hand.
- **The console does not.** A startup line that logs the flavour name is
  logging the Dart half back to itself.

---

## 2. The check

One comparison, at the one moment both halves exist in the same process:

```dart
await Firebase.initializeApp();

final String nativeProjectId = Firebase.app().options.projectId;

// The two halves of a build's config, compared where they finally meet.
if (nativeProjectId != AppEnv.firebaseProjectId) {
  throw FlavorConfigMismatch(
    expected: AppEnv.firebaseProjectId,
    actual: nativeProjectId,
  );
}
```

**Compare the project id, not the flavour name.** The flavour string lives in
the same file as everything else on the Dart side, so comparing it to itself
proves nothing. You need a value each half produces *independently* — and
`Firebase.app().options` is the native half reporting what it actually loaded.

**At runtime, not only from the files.** A file check answers "what is on
disk"; this answers "what did the SDK come up on", which is the question. A
stale incremental build, a plist cached in DerivedData, a hot restart after
switching flavours — each one passes a file check and fails this one.

---

## 3. Three states, and only one of them is the bug

| Both halves | How it looks | What to do |
|---|---|---|
| empty | no backend configured | **run** — log a warning, ship an offline app |
| Dart filled, native missing or unreachable | `initializeApp` throws | **run** — the user is standing somewhere with no signal |
| filled, and different | everything works | **refuse** |

**Refuse a mismatch, never an absence.** A guard that fires on a missing half
turns "the backend is not set up yet" into a broken app on day one of the
project, and whoever hits it will delete the guard rather than the cause.

---

## 4. Where it goes

- **Inside the Firebase step, immediately after `initializeApp`** — and
  **before the crash reporter attaches**, so a build pointed at the wrong
  project does not also send its crashes there.
- **Not a step of its own.** `Firebase.app()` throws `[core/no-app]` when the
  step above skipped initialization, so a separate step has to re-derive
  whether it applies — a second copy of the same condition.
- **Your bootstrap must survive a throwing step and still call `runApp`.**
  Otherwise a mismatch is a process that dies before the first frame: a white
  screen, which is worse than the bug it replaced.

---

## 5. What the user sees

- **Reuse the "the app could not start" screen you already have.** Do not
  build a screen for this. It is one more fatal startup state, and the seller's
  recovery is the same as every other one.
- **A raw failure never reaches a release screen.** Put the detail row behind
  a `const` debug flag so the release binary does not contain it.
- **The detail names both projects and the exact command to run.** This can
  only happen on a developer's machine, so that sentence is the whole value of
  the feature:

  ```text
  env/dev.json is acme-dev, but the native config is acme-prod.
  Run `melos run prepare-env-dev`.
  ```

- **Log it as fatal, with both ids as data** — not a bare "config mismatch".
  The line is what somebody reading a console is looking for.

---

## 6. The second gate, before a build exists

A release lane should ask the same question from the files, and fail the lane:

| Check | Source of truth | Catches |
|---|---|---|
| plist project id vs the flavour's project | `.firebaserc` — the same file the Firebase CLI reads | the tree set up for the other environment |
| plist bundle id vs the app identifier | the lane's own identifier | another app's file entirely |
| reversed client id present in `Info.plist` | the plist | Google sign-in that builds and never receives its callback |
| the Crashlytics app id secret vs the plist | the plist | symbols uploaded to another project's dashboard |

**Neither gate replaces the other.** The lane catches it before a build
exists; the runtime check catches the `flutter run` that never went through a
lane — which is where it actually bites.

**Use the mapping file your CLI already uses** (`.firebaserc`) rather than a
second list of projects. Two lists is how the check itself goes stale.

---

## 7. Test spec

Do not try to unit-test the throw site: it needs a real Firebase app. Test the
policy and the message, and let the lane cover the files.

| # | Assertion | Catches |
|---|---|---|
| 1 | a mismatch is fatal | the guard wired to nothing |
| 2 | an unreachable backend is **not** fatal | the absence case, which is the one that breaks a fresh clone |
| 3 | an unrelated error is **not** fatal | a policy that widened to "anything the Firebase step threw" |
| 4 | the message contains both project ids and the command | a detail row nobody can act on |
| 5 | the error screen shows the detail outside release, and not in it | the raw failure shipping |

2 is the important one. It is what lets you add this without breaking the day
the app has no backend yet.

---

## 8. Port checklist

1. Confirm the app has more than one Firebase project and that a script
   installs the native files. If the build picks them, check whether both
   flavours share a bundle id — if they do, the trap is live.
2. Make sure a failing bootstrap step still reaches `runApp` and can open an
   error screen. Build that first.
3. Add the failure type. Give it both ids and a `toString` that names the
   command to run.
4. Teach your fatal-failure policy about it, beside whatever else is on that
   list.
5. Add the comparison after `initializeApp`, before the crash reporter.
6. Write the five tests from §7.
7. Add the file-level check to the release lane, off the CLI's own mapping
   file.
8. Write the rule down where the env keys are documented, not in a commit
   message.

---

## 9. Still open, so decide them deliberately

| Question | Note |
|---|---|
| Android | `google-services.json` is compiled into resources, so the same comparison covers it — `options` reports whichever native file loaded. No second check. |
| Flavour-specific bundle ids | They make the trap rarer, because the other project's plist is registered to another identifier. A bundle-id comparison is the cheap extra, and the lane already has it. |
| Web and desktop | Options come from Dart, so there is one half and none of this applies. Do not let the guard fire there. |
| A staging flavour | Nothing changes; the check is a comparison, not a list of allowed pairs. |
| Other two-half config | The same shape covers any value that exists on both sides — a RevenueCat key against the entitlement it resolves, an API base URL against what the server reports. Add them one at a time, each with its own §3 table, or the guard grows into a startup gate nobody can debug. |
