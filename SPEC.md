# Aedicule — Build Specification

> Portfolio app 72, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Save today's glow into the niche and later draw a past one.

| Field | Value |
| --- | --- |
| Product name | Aedicule |
| Bundle identifier | `com.aedicule.niche` |
| Domain | https://aedicule-niche.pro |
| Contact URL | https://aedicule-niche.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `aed_` |
| User-Agent | `Aedicule/1.0 (iOS; +https://aedicule-niche.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Aedicule -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A keeper saves a felt moment into today's glass niche and later draws one cooled glow as a ray.

### 2.1 User flow

1. Tap Catch, pick a feeling, and save today's glow into the niche
2. Optionally attach a photo from the library or a voice clip while the glow is still Live
3. Swipe the coverflow across today's other Live glows
4. Tap Draw to stage a random Wick or Capsule as a ray
5. Switch to the Garden segment to see the plant and the year collage of Capsules

### 2.2 Essential behaviour

- Every Glow carries an emotion hue
- Optional on-device photo or voice, attachable only while Live
- Draw samples a Glow whose daykey is not today and writes a RayMark
- A Glow older than 30 days becomes a Capsule and blooms the garden
- Year collage of Capsules on Garden, keyed as Int YYYYMMDD
- Local-only store; no feed, no cloud, no catalog

---

## 3. Uniqueness assignment for Aedicule

| Axis | Assigned value |
| --- | --- |
| Architecture | **Glow ADT fold (Live | Wick | Capsule); the niche is a fold over Glows; Catch writes a Glow; next local midnight folds Live to Wick and freezes media; age over 30 days writes Capsule; Draw samples a Wick or Capsule and writes a RayMark** |
| UI approach | **SwiftUI pure · take warmmoments** |
| Naming convention | **Votive / niche lexicon** |
| File organization | **By niche role (Niche, Glow, Wick, Capsule, RayMark)** |
| Dependency strategy | **None** |
| Design direction | **Violet night mode** |
| Typography | **SF Pro** |
| Navigation pattern | **Niche-segment chrome (the niche never leaves; Moments, Garden and Settings are segments of the same glass; catch and draw fuse on the coverflow)** |
| AI art style | **3D glass render glassmorphism · take warmmoments** |
| Functional twist | **Wick-then-ray (a catch writes a Glow; midnight folds Live to Wick; Draw samples a Wick or Capsule and writes a RayMark; today is never drawn)** |
| Persistence | **UserDefaults+Codable** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — warm_moments

**Core** — A keeper saves a felt moment into today's glass niche and later draws one cooled glow as a ray.

**Audience** — People who want a private jar of good days, not a social diary or a year grid of moods.

**User flow**

1. Tap Catch, pick a feeling, and save today's glow into the niche
2. Optionally attach a photo from the library or a voice clip while the glow is still Live
3. Swipe the coverflow across today's other Live glows
4. Tap Draw to stage a random Wick or Capsule as a ray
5. Switch to the Garden segment to see the plant and the year collage of Capsules

**Essential features**

- Every Glow carries an emotion hue
- Optional on-device photo or voice, attachable only while Live
- Draw samples a Glow whose daykey is not today and writes a RayMark
- A Glow older than 30 days becomes a Capsule and blooms the garden
- Year collage of Capsules on Garden, keyed as Int YYYYMMDD
- Local-only store; no feed, no cloud, no catalog

**Twist** — Wick-then-ray. Home is the niche coverflow. Catch writes a Glow with an emotion hue and optional local photo or voice. A Glow stays Live while its daykey is today, so photo and voice can still attach. At the next local midnight it becomes Wick and media freezes. After 30 days a Wick becomes Capsule and the garden blooms. Draw samples one Wick or Capsule, writes a RayMark, and stages that card; you do not pick a past Glow from a list. Live (today) is not in the draw pool. Year collage is Capsules by daykey. Home verb: catch-the-glow, not write-a-journal. Garden counts Capsules and RayMarks.

**Why this is not a repeat** — This is the first warm_moments app: home is catch-the-glow on a glass niche, and the only way back to a past moment is Draw, which samples a Wick or Capsule and writes a RayMark. That is not Washfolio’s one-stroke year canvas, not Pugillar’s two-handed blind seal, not Palmette’s savings vine, not ForkFolio’s food photo log, and not a moment_thread of dated beads. Multiple Live glows may land on the same YYYYMMDD; midnight freezes media; Capsule at 30 days blooms the garden. AVCaptureMetadataOutput and cgi search pl stay unused so this never becomes a barcode catalog.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Coverflow of moments. Ray from the past.
- Invariant: Emotion color + optional local photo/voice. Ray = random moment not today. Year collage. Capsules = moments >30d.
- Never: No Drift lantern game. Garden tab is the living garden.
- Desk `weave_pace`: weeksRemaining=(target−done)/last7d_meters. Nil if no meters this week.
- Taste DNA is section 7.6. Do not invent a second look.

### 3.1 Architecture contract

The niche is a Glow ADT with cases Live, Wick, and Capsule, and NicheStore is a fold over Glows rather than a list of journal rows the view edits. Catch writes a Glow with an emotion hue and an Int YYYYMMDD daykey from Calendar.current.startOfDay; several Live glows may share one daykey. A Glow stays Live while its daykey equals today, so a PhotosPicker still and an AVAudioRecorder clip may still attach; at the next local midnight the store folds Live to Wick and freezes media. Age over 30 days from that daykey writes Capsule and blooms the garden; Draw samples one Wick or Capsule, never a Live glow, writes a RayMark, and stages that card. Views call catchGlow, attachMedia, foldMidnight, and drawRay; unit tests prove the midnight fold, Capsule at 30 days, emotion hue on every Glow, and that today is absent from the draw pool.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

100% SwiftUI with the warmmoments take-token: first of this family, so compose an original glass-niche coverflow. Steal emotion hue, optional on-device photo or voice, random ray not today, year collage, and Capsules older than 30 days only. Do not copy a year grid, a vine trellis, a wax diptych, a food photo log, or a thread of dated beads. No UIViewRepresentable, no WKWebView, no Safari sheet, no AVCaptureSession. Home is the mechanic: Moments is a horizontal coverflow of today's Live glows filling remaining height and the iPad width; Catch and Draw fuse on that coverflow. Confine custom drawing to that one niche hero (Shape, Path, tinted-glass Material); Garden collage and Settings are stock segmented body, List, Form. Primary chrome sits on tinted glass, min 44pt, contentShape on the fill. Empty and onboarding are full pages with frame(maxHeight: .infinity) and a bottom full-width Catch or Continue. Background fills the safe area. One glow on the live Catch or Draw control, nowhere else. Motion is press scale 0.97; Reduce Motion fades only. Voice is dry: Catch, Draw, Saved. PhotosPicker attaches a library still; AVAudioRecorder attaches a clip. Mic notDetermined uses Continue then the system alert; denied copy plus Open Settings. Colour is never the only emotion signal. One haptic on a successful Catch or Draw; none on segment changes.

### 3.3 Naming contract

Convention: Votive / niche lexicon.

Examples to follow: `Glow`, `catchGlow(_:)`, `RayMark`, `foldToWick()`

### 3.4 Dependency contract

None. Zero SPM packages; project.yml has no packages key. Foundation, SwiftUI, PhotosUI, and AVFAudio only. Do not add CocoaPods, a URLSession catalog, Alamofire, or an AVCaptureMetadataOutput session. The leftover scanner axis and cgi search pl endpoint stay dark so this never becomes a barcode catalog. PhotosPicker needs no library grant. Voice uses AVAudioRecorder; do not open a capture session. SF Pro is the system face; do not bundle a font.

### 3.5 Navigation contract

Niche-segment chrome: one root glass that never leaves. Moments, Garden, and Settings are segments of that glass, not a TabView of record stacks and not pushed details. Catch and Draw fuse on the Moments coverflow and are not destinations. Garden and Settings replace only the body of the same glass. Contact URL https://aedicule-niche.pro/contact-us lives on Settings. No Drift, Scan, Search, or Game segment. After onboarding, read ProcessInfo.processInfo.arguments once: -ReviewScreen today opens Moments, log opens Garden, goals opens Settings, three different screens. Skip onboarding on Simulator after the aed.demo.v1 seed so the hook can fire.

### 3.6 Screen composition contract

Single screen with segments. Physical screens: Moments, Garden, Settings. Moments is home: a coverflow of today's Live glows; Catch writes a Glow in place; Draw stages a sampled Wick or Capsule as a ray on the same glass; ReviewScreen today. Empty Moments with no Glows yet is a full page with generated cutout art, headline Nothing saved yet., one line Catch a warm moment., and a full-width bottom Catch. A day with no Live glows but a draw pool still shows the niche with Catch and Draw enabled, not the first-run empty. Garden is the living garden: a plant that blooms with each Capsule plus a year collage of Capsules keyed as Int YYYYMMDD, counting Capsules and RayMarks (ReviewScreen log), with its own full-page empty. Settings is a Form for contact URL at https://aedicule-niche.pro/contact-us, re-run onboarding, and resetAllData (ReviewScreen goals). Onboarding is a one-shot cover of three pages with Continue or Next at the bottom full width. No Today, Scan, Search, or Goals screens. No Drift lantern game. ReviewScreen today log and goals must open three different screens.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

---

## 4. Target file organization

Scheme: **By niche role (Niche, Glow, Wick, Capsule, RayMark)**

```
Aedicule/
  Niche/
Glow/
Wick/
Capsule/
RayMark/
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Moments
A first-class screen for **Moments**. Must render empty, populated and error states.

### 5.3 Garden
A first-class screen for **Garden**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Moment** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **Violet night mode**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#201E13` | Screen background |
| `surface` | `#2C291B` | Cards, rows, sheets |
| `ink` | `#F2F1ED` | Primary text and icons |
| `accent` | `#EED34F` | Primary action, key figure, progress fill |
| `muted` | `#AEA88F` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **SF Pro**

SF Pro via Font.system as a tight sans on void. Bright ink, no mid-size type: display is title for Catch, Draw, and the staged ray (short, 1 or 2 lines, never above 34pt), then body at 17pt for emotion names, then caption for Wick and Capsule roles. Skip title3, callout, and subheadline as a third display size. At most six named steps behind one accessor; weights carry hierarchy. No Font.custom and no fixedSize. Never below 12pt. Tabular figures for daykeys, Capsule counts, and RayMark counts through NumberFormatter. Dynamic Type; at the largest accessibility size display may drop to title2 so it never clips. Day edges use Calendar.current.startOfDay then fold to Int YYYYMMDD. Emotion names sit in body type, never colour alone.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **16pt** for cards, sheets and primary surfaces; **10pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **material** — SwiftUI `Material` (`.regularMaterial` / `.thinMaterial`), reused everywhere a surface sits above another.

Primary control: **tinted glass** — primary chrome sits on a tinted translucent surface (`Material` plus the accent colour at low opacity), never plain flat colour.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI pure · take warmmoments**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI pure · take warmmoments** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

### 7.6 Taste DNA

Aesthetic: **dark** (Dark-tech: void surfaces, one glow or jewel, sparse chrome.)

Reference system: **cursor** — steal rhythm and restraint, not their colours or logos.

Mood: **cinematic**.

Home rhythm (`dark-canvas`, airy): Dark hero canvas, one glow, sparse chrome. Media is the atmosphere.

Cinematic void. One glow on the live control, nowhere else. No stacked blur plus gradient plus spring.

Type move: Tight sans, bright ink on void, no mid-size type.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`dry`): Short verbs. No warmth padding. 'Saved.' not 'Your changes were saved successfully.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable**

One Codable NicheDocument (schemaVersion from 1, Glows with Live or Wick or Capsule role, emotion hue, optional photo and voice file names, RayMarks, daykeys as Int YYYYMMDD) encoded to JSON Data in UserDefaults under aed.niche.v1. Photo and voice bytes live as files in Application Support; the document stores names only. Live-to-Wick, Capsule bloom, and the draw pool are derived at display and never stored as a second list. In-memory NicheStore is the source of truth; UserDefaults is the projection. Debounce writes; flush when scenePhase becomes inactive or background; encode after every Catch, attach, Draw, and midnight fold. Decoding failure falls back to an empty niche, never a crash. resetAllData() is reachable from Settings and deletes media files. Simulator seed only once behind aed.demo.v1 writes several Live glows for today, several Wicks, at least one Capsule older than 30 days, at least one RayMark, leaves Catch and Draw enabled, marks onboarding complete, and never seeds an empty niche or a blocked Draw as the first frame. Never seed on a device. Views never touch UserDefaults.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Aedicule/1.0 (iOS; +https://aedicule-niche.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Wick-then-ray (a catch writes a Glow; midnight folds Live to Wick; Draw samples a Wick or Capsule and writes a RayMark; today is never drawn)

Home is catch-the-glow on a glass niche coverflow, not write-a-journal. Catch writes a Glow with an emotion hue and optional local photo or voice while it is Live. Midnight folds Live to Wick and freezes media; after 30 days a Wick becomes Capsule and the garden blooms. Draw is the only path back to a past moment: it samples one Wick or Capsule, writes a RayMark, and stages that card. Live today is never in the draw pool. Garden counts Capsules and RayMarks and shows the year collage by daykey.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **3D glass render glassmorphism · take warmmoments**


This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

Base prompt, reused and extended for every asset:

```
3D glass render with glassmorphism: studio-lit votive niche, frosted alcove, inner glow as atmosphere, refraction and soft bloom, quiet uncluttered ground, isolated subjects, cinematic void, no text, no letters, no logo, no photoreal stock, no specified colours
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `aed_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `aed_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `aed_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `aed_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `aed_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `aed_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `aed_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `aed_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `aed_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `aed_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `aed_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Wick-then-ray (a catch writes a Glow; midnight folds Live to Wick; Draw samples a Wick or Capsule and writes a RayMark; today is never drawn)' feature screen. |
| 11 | `aed_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `aed_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`aed_AppIcon`** — 1024x1024

```
A single glass votive niche filling the canvas edge to edge, inner glow as the emblem, 3D glass render, no text, no alpha, no rounded mask
```

**`aed_Splash`** — 1290x2796

```
Tall frosted-glass niche in void, quiet uncluttered middle third for a wordmark, 3D glassmorphism, no text
```

**`aed_Onboarding1`** — 1024x1536

```
Cutout of a glass niche waiting to hold a glow, isolated, transparent corners, 3D glass render, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aed_Onboarding2`** — 1024x1536

```
Cutout of a hand catching a small glow into a glass recess, mid-gesture, isolated, transparent corners, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aed_Onboarding3`** — 1024x1536

```
Cutout of a cooled wick casting a thin ray beside a small garden plant, isolated, transparent corners, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aed_EmptyHome`** — 1024x1024

```
Cutout of an empty glass niche, calm, inviting, isolated, transparent corners, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aed_EmptyList`** — 1024x1024

```
Cutout of a bare garden bed with no capsules, isolated, transparent corners, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aed_CardBackdrop`** — 1200x800

```
Abstract frosted-glass atmosphere filling the canvas, low contrast, 3D glassmorphism, no text
```

**`aed_ControlFace`** — 512x512

```
Cutout of a small glass catch cup, the primary control face, isolated, transparent corners, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aed_TwistHero`** — 1024x1024

```
Cutout emblem of a wick throwing a single ray, isolated, transparent corners, 3D glass render, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aed_SuccessMark`** — 512x512

```
Cutout of a caught glow settled in glass, isolated, transparent corners, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aed_HeaderDecor`** — 1200x600

```
Wide cutout lintel of a glass aedicule, isolated, transparent corners, no text

HARD CUTOUT: isolated subject on a fully transparent background. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated subject, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`aed.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.


---

## 17. Tests

Add a unit test target `AediculeTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
   `-ReviewScreen today|log|goals` switches the running app's live navigation.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Aedicule -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Glow ADT fold (Live | Wick | Capsule); the niche is a fold over Glows; Catch writes a Glow; next local midnight folds Live to Wick and freezes media; age over 30 days writes Capsule; Draw samples a Wick or Capsule and writes a RayMark** with no leakage across layers.
- [ ] UI approach matches **SwiftUI pure · take warmmoments**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Niche-segment chrome (the niche never leaves; Moments, Garden and Settings are segments of the same glass; catch and draw fuse on the coverflow)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **SF Pro** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Aedicule
xcodegen generate
xcodebuild -scheme Aedicule -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcrun simctl list devices available
xcodebuild -scheme Aedicule -destination 'platform=iOS Simulator,id=<UDID>' test
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY or DEVELOPMENT_TEAM in project.yml — CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
