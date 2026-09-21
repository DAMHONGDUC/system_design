# Local-first data flow — portable spec

Written to be applied to **another app**, not to describe this one. Every name
below is a thing you create; the BaroEase implementation is referenced only as
a worked example.

## 0. Premises

| Assumption | If your app differs |
|---|---|
| The user's records must survive with no network and no account | Nothing below matters — use the server directly |
| A local SQL database (Drift/SQLite) holds those records | §2 needs a column story of its own; the rest stands |
| A document store per account (Firestore) holds the copy | §5 changes shape; §1–§4 stand unchanged |
| Auth is anonymous by default, sign-in optional | Skip §6.2; keep §6.3 |
| iOS, where the Keychain outlives a delete | §7 is iOS-specific; on Android the reinstall row cannot fire |

**The one invariant: no user-facing flow ever awaits the network.** If applying
this makes a save, a delete or a screen wait on a server, something is wrong.
Assert it with a test that saves a record against a repository whose remote
half throws.

---

## 1. One source of truth, and it is the device

| Rule | Why |
|---|---|
| The local DB is the record; the server holds a copy | A copy can be rebuilt; a record cannot |
| A write returns as soon as the local row is committed | The network is never in a user's way |
| The server is never read to answer a screen | A screen that can be wrong offline is a screen that is wrong |
| Signed out, nothing leaves the device | "Optional account" has to be true, not advertised |

```text
Tap "save"                     intensity 7, at 2026-09-21 14:03
   ▼
Local row committed            id a3f1-…, revision 4        ← UI is done here
   ▼ (table changed)
Write-through, debounced 2s
   ▼
Signed in?  no ──────────────► stop. 0 network calls.
            yes ─────────────► encrypt → PUT attacks/{a3f1-…}
```

**The consequence to state out loud, in the product and not only in the code:
a device that was never signed in holds the only copy.** Reinstall, loss or
theft is total loss. Either say so on the sign-in screen or ship a local export;
do not let the architecture make a promise the UI does not.

---

## 2. Change tracking: a counter, not a clock

| Field | Type | Answers |
|---|---|---|
| `revision` | int, bumped on every local write | "does this device owe the server anything?" |
| `syncedRevision` | int, written only after the server acks | the same question's other half |
| `updatedAt` | timestamp | "whose version wins when two devices disagree?" |

**Pending means `revision != syncedRevision`. Never "updatedAt is newer than the
last sync".**

- **A timestamp cannot answer the first question.** SQLite date columns are
  whole seconds here; an edit landing in the same second as the push before it
  reads as unchanged and silently never syncs. A counter also survives a clock
  stepping backwards — a phone crossing a timezone, a user fixing the date.
- **A row that arrives from the server is written with `revision ==
  syncedRevision`**, so it is in step the moment it lands and does not push
  straight back.
- **Ties on `updatedAt` go to the server**, so two devices converge on one
  answer instead of each preferring its own.

### Deleting

**Delete the row for real, and write a tombstone holding the id and which
collection it came from — nothing else.**

| | Why |
|---|---|
| No soft-delete flag | A read that forgets the filter shows deleted data; one will |
| Tombstone carries no field of the record | No note, name or intensity may outlive a delete |
| One shared tombstone table | It is sync bookkeeping, not a user record; three copies of two columns are three chances to disagree |
| Deleting a parent tombstones its children | The local FK cascades; the server's copies belong to no cascade |
| Re-using an id clears its tombstone first | Otherwise the record is deleted again by its own stale tombstone |

---

## 3. Write-through: watch the tables, not the call sites

**A change is pushed because the table changed, never because a controller
remembered to ask.**

```text
Drift tableUpdates(attacks, medications, …, tombstones)
   ▼ debounce 2s
pushPending()   ← saving a medication with 3 reminders writes 4 rows, owes 1 push
```

- **A rule that has to be repeated at every new write is already broken
  somewhere.** Before this, one flow called sync after its save and two never
  did; their edits sat on the device until the next launch. A new synced table
  now joins by being named in one list.
- **The chain must terminate, and that is the trap.** Marking a record synced is
  itself a write to that table, so every real push schedules one more. The
  second finds nothing pending — and therefore **must not fetch the account key
  or touch the network**, or every single write pays for an extra round trip
  forever.
- **One push at a time, and collapse what is queued.** Two overlapping pushes
  send the same record twice, and one marks it synced while the other is still
  writing it. Two writes a second apart owe one push; ten app opens owe one pass.

---

## 4. Two passes, and the floor between them

| | Full pass | Push-only |
|---|---|---|
| Does | pull, then push, per collection | push |
| Fired by | sign-in, launch, resume | every write to a synced table |
| Held back by | the cooldown — **pull half only** | nothing |
| Costs when idle | key fetch + a query per collection | N local queries, no network |

**A floor between pulls is worth having**: without one, ten app opens in ten
minutes are ten full passes, each a key fetch plus a query per collection,
usually to find nothing changed. Six hours is the number here; pick your own and
write down what it costs — *a change made on another device can be that late.*

### The trap: the floor must not hold back the push

A cooled-down pass that returns early skips the push too, and **nothing else
retries a failed push**:

| Time | Event | Without the fix | With it |
|---|---|---|---|
| 06:00 | pass succeeds, floor stamped | — | — |
| 10:00 | offline, record saved, push fails | sits locally | sits locally |
| 10:30 | network returns | nothing fires — no connectivity listener | nothing fires |
| 11:00 | resume | floor skips the whole pass | floor skips the **pull**; record goes up |
| 12:00 | floor expires | record finally goes up, 90 min late | — |

So: **when the floor skips a pass, still run the push half.** It costs the
push-only column above, which is a handful of local queries and no network when
nothing is pending.

- **Stamp the floor only after a pass that worked**, so a failure is retried by
  the next open rather than parked for a whole window.
- **Keep the stamp in storage, per account, not in memory.** The triggers are
  launch and resume; a floor the app forgets on close lets ten cold starts run
  ten passes. Clear it on sign-out, so signing into another account syncs at
  once.
- **A skipped pass changes no visible state.** It is neither a fresh sync nor a
  failure.

---

## 5. What a pass does, in order

1. **Pull before push.** A device that just signed in has no cursor; the other
   order re-downloads everything it just uploaded.
2. **Collections in dependency order** — parents before children (a reminder
   points at a medication, so the other order hits a foreign key that is not
   there yet).
3. **A cursor per collection, not one for the pass.** A pull that failed on
   children must not look finished because the parents got through.
4. **Mark synced only after the server confirms.** A kill mid-pass costs a
   re-push, never a lost record.
5. **A payload that will not decode is counted and skipped, never retried
   forever** — and the count is reported to crash reporting, because nothing on
   screen will ever show it.
6. **Decrypt a pulled batch in one call, index-for-index, and move it off the UI
   isolate above a threshold** (50 records here, ~0.27 ms each). One bad row
   yields a null at its position and never throws, or the whole batch wedges
   behind it.
7. **Side effects of a pull are re-derived, not synced.** OS notifications are
   registered with the device that made them, so rows pulled from another phone
   must be rescheduled locally — reading their strings without a `BuildContext`,
   because there is none in a background sync.

---

## 6. Identity

### 6.1 The account is a key, not a gate

Every synced document carries the owner's id, every query filters on it, and the
rules check it **both ways** — on the stored document and on the incoming one.
Without the second check a user can rewrite the field and plant a record in
someone else's account. Build exactly one helper that constructs collection
references, with **no method that can omit the filter**, and never reach past it.

### 6.2 Anonymous first, then link

| Step | Rule |
|---|---|
| App start | Sign in anonymously so callables have a caller — after the fresh-install check, never before |
| A cached user | Is not a session: force a token refresh, because an account deleted server-side still reads as signed in while every call fails |
| Sign-in | Link the credential to the anonymous user, so the id is upgraded and never replaced |
| `credential-already-in-use` | Fall back to a plain sign-in — this is the path that makes recovery after a reinstall work |
| After the fallback | Local rows are still pending, so they push into the account that just signed in. **Decide deliberately whether that merge is what you want**; on a shared device it is a surprise |

### 6.3 Sign-out hands the records back

**Decide which of the two the device's copy is, and be consistent — the two
halves of this cannot be mixed.**

| Model | Sign-out does | Costs |
|---|---|---|
| The device owns the data | Keeps every local record | The next account inherits a stranger's history, and those rows — already pushed, therefore clean — never reach it either |
| **The account owns the data** | Push what is owed, then wipe the device | A sign-out with no network cannot complete |

The second is the one to pick if accounts can be switched on one device. Its
order is fixed:

1. **Push everything still pending, and read the answer.** The only push in the
   app whose result is read, because it is the only one with no later retry.
2. **A failure cancels the sign-out.** Say so on screen — the records still on
   the device are the only copy there is — and touch nothing.
3. **Wipe the device's copy only.** Never the account-delete path: the user is
   getting these records back, not destroying them.
4. **Drop the cursors and the cached key.** They point past everything just
   removed; left in place, the next sign-in pulls only what changed since and
   the history never comes home.
5. **Sign out**, and rebind the purchase/entitlement SDK to no user, so an
   entitlement follows the person rather than the install.

**Show the wait.** Step 1 is a network round trip standing between a tap and an
empty database; a spinner with no words reads as a stall.

**Take the derived files too** — exports, share images, widget caches. They are
copies of the account's data in the app's own storage, and nothing in them names
who they belong to.

---

## 7. What a fresh install means

**One stamp, one comparison, and the two stores are the whole diagnosis.**

| Store | Survives a delete? | Holds |
|---|---|---|
| Install-scoped (`shared_preferences`) | No | The stamp, and nothing else |
| Device-scoped (Keychain) | **Yes** | Settings, session, secrets |

```text
stamp == this build ......................... normal launch, do nothing
stamp is a different value .................. environment changed  → wipe
stamp absent, other install keys present .... update from an older build
stamp absent, device-scoped store not empty . reinstall            → wipe
stamp absent, nothing anywhere .............. first install
```

The stamp is the build's environment name (`dev`, `prod`), so one comparison
answers both "is this a reinstall?" and "is this the other environment's data?".

- **Wipe order**: sign out (every provider, or the next sign-in skips the picker
  and lands back in the account just left) → clear the backend's cached
  documents → empty the device-scoped store → empty the install-scoped store →
  write the stamp.
- **It runs before the first frame, and something must hold the UI back.**
  Firestore's `clearPersistence` throws once any stream is open, and a normal app
  root opens several on its first frame. A gate above the app, showing the same
  splash, is the only place this fits.
- **It never throws.** Before the first frame an uncaught error is not an error
  screen, it is an app that does not start.
- **Never wipe the user's own database.** The stamp can be wrong — a build that
  forgot its config falls back to a default environment name — and a wrong
  session costs a sign-in while a wrong wipe costs the record. Wipe sessions,
  caches and settings; leave the data.

---

## 8. Crypto, and what you may claim

**A key the server can fetch is not end-to-end encryption, and the copy must
never imply it is.** Mint a per-account key behind a callable, store it in a
collection the rules deny to every client, and refuse anonymous callers. Then say
"encrypted" and never "only you can read this".

**A payload codec refuses only versions newer than it knows, never merely
different, and ignores fields it does not recognise.** The first version bump
would otherwise orphan every record already uploaded, and one added optional
field would stop two builds in the wild reading each other.

---

## 9. Deleting an account

| Rule | Why |
|---|---|
| Remote records before local ones | The other order leaves the cloud copy with nothing to say it should go, and the next sync pulls it all back |
| A remote failure aborts the whole wipe | Half a delete is the worst outcome of the three |
| Every remote step is bounded — page count **and** timeout | Both sit behind a spinner with nothing else on screen; a bare `while (true)` whose only exit is an empty page never ends if a write-through push refills it |
| Giving up is safe only before anything local is touched | Which is exactly where these two steps sit |

---

## 10. Things that must not exist

1. **A sync button, row, indicator or screen.** The app is either signed in, in
   which case it is saving, or it is not. A user who cannot make sync happen also
   cannot be asked to.
2. **A "last synced" time or a progress bar.** The only sync state a UI may read
   is "the first pull for this account is still running", and only so a list can
   say *getting your records* instead of *you have none*.
3. **A flow gated on sync completing.** Including the first one after sign-in.
4. **A rule that must be remembered at each new write.** See §3.
5. **Exports or device-local artefacts in the synced set.** A file path means
   nothing on another device, and uploading them multiplies the copies the
   account-delete has to chase.

---

## 11. Porting checklist

| # | Step | Done when |
|---|---|---|
| 1 | `revision` / `syncedRevision` / `updatedAt` on every synced table | A test saves offline and finds the row pending |
| 2 | One tombstone table | Deleting a parent leaves tombstones for its children |
| 3 | Write-through watcher over a list of tables, debounced | Saving a parent + 3 children fires one push |
| 4 | Empty push costs no network | A test asserts the key repository was never called |
| 5 | Serialized queue, one pass/push at a time, queued ones collapse | Two concurrent calls run one |
| 6 | Pull → push, in dependency order, cursor per collection | A pull that throws on collection 2 leaves collection 1's cursor stamped |
| 7 | Floor on the pull, **push still runs** when it skips | The §4 table's 11:00 row is a test |
| 8 | Owner-id rules checked both ways, one filtered-collection helper | The rules test denies a write that rewrites the owner id |
| 9 | Fresh-install stamp + gate above the app root | The five outcomes are five tests |
| 10 | Account delete: remote, bounded, before local | A remote timeout leaves the device's copy whole |
| 11 | Sign-out: flush, then wipe local only, cursors dropped | A failed flush leaves the session and the records untouched |
