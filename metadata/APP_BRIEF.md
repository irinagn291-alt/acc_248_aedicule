<!-- gf-brief source=666771e06d052c5c2972b93c9df5409cfb498c134d60f3ee310c8fcf28c63977 written=2026-09-26T01:59:15+03:00 -->
# Aedicule

## What it is
Aedicule is a private niche for catching a day’s feeling as a glow, attaching a photo or voice while it is still Live, and later drawing a cooled Wick or Capsule as a Ray. It is for people who want a quiet, on-device ritual of mood, memory, and time—not a social feed or account.

## Launch and onboarding
1. Cold launch opens dark, portrait UI. A brief load may show a spinner labeled “Opening the niche”.
2. The system may ask for notification permission at launch (Apple’s standard dialog).
3. If onboarding is not finished, a full-screen cover appears (cannot be dismissed by swipe). Three pages, each with art, a title, a line, and buttons:
   - Page 1 — Title: “Today's glow sits in the niche”. Line: “Catch a feeling into today's glass. It stays on this device.” Buttons: “Next”, “Skip”.
   - Page 2 — Title: “Catch while it is Live”. Line: “Photo and voice attach today. Midnight freezes them.” Buttons: “Next”, “Skip”.
   - Page 3 — Title: “Draw a cooled wick”. Line: “Draw samples a Wick or Capsule. Live today stays out of the pool.” Buttons: “Continue”, “Skip”.
4. “Next” advances a page. “Continue” or “Skip” finishes onboarding and opens the main shell.
5. Main shell shows a segmented control labeled “Niche” with “Moments”, “Garden”, and “Settings”. Default segment is Moments.

## Screens

### Moments
- Header: “Catch a glow” / “Tap Catch. Draw a ray later.”
- **Empty** (nothing saved): “Nothing saved yet.” / “Catch a warm moment.” Primary control: “Catch” → opens Catch sheet.
- **Quiet day** (glows exist, none Live today): “No live glow today.” / “Catch one, or Draw a wick.” Shows counts labeled “Cooled” and “Rays”.
- **With Live glows**: horizontal cards in a “Glass niche”. Each card shows the feeling name (e.g. “Ember”) and a “Live” chip. Focus a card to reveal attach controls while it is Live:
  - “Photo” — opens the system photo picker; attaches an image to that glow; may show “Saved.”
  - “Voice” / “Stop” — starts or stops a short voice clip. First use may open the Voice sheets below. After a clip exists, “Play voice” plays it.
- After a successful Draw, a strip labeled “Ray” shows the sampled feeling name and its role chip (“Wick” or “Capsule”).
- Primary “Catch” → Catch sheet. Quiet secondary “Draw” with detail “Later” when cooling is available, or “Nothing cooled” when Draw is disabled.
- Fault empty: “The niche could not be read.” with “Retry”. Banner faults use “Retry” or “OK” (for restore/saved lines).
- **Catch sheet** — title “Catch”; “Pick a feeling.”; feelings: “Ember”, “Hush”, “Bloom”, “Tide”, “Hearth”, “Gleam”, “Still”, “Lift” (default Ember selected); “Catch” saves today’s glow and closes; sheet Close control.
- **Voice (first ask)** — title “Voice”; “A clip attaches only while this glow is Live.”; “Continue” proceeds to the system mic prompt.
- **Voice (denied)** — title “Voice”; “Mic is off. Open Settings to record.”; “Open Settings” opens iOS Settings.

### Garden
- **Empty**: “Nothing in bloom.” / “A glow becomes a Capsule after 30 days.” Button “Open Moments” → Moments.
- **Populated**: “The garden bloomed.” / “Tap a Capsule, or Open Moments to Catch.” Counts “Capsules” and “Rays”. Living garden chips use each Capsule’s feeling name; year collage tiles show a medium-style day date, feeling name, and optional “Ray” if that Capsule was drawn. Tapping a chip or tile opens a bloom sheet titled with the feeling name, the same next-step line, and “Open Moments”. Bottom “Open Moments” returns to Moments.
- Fault: “The niche could not be read.” with “Retry”.

### Settings
- **Empty** (no glows): “No glows on this device” / “Contact stays here. Catch from Moments.” “Contact” link with detail `https://aedicule-niche.pro/contact-us`. Buttons: “Catch” (jumps to Moments and opens Catch); “Re-run onboarding”; “Reset all data” with detail “Erase glows on this device”.
- **Populated**: summary with “Catch a glow”, count under “Live today”, plus “Capsules” and “Rays” rows. Rows:
  - “Wick then ray” / “Draw samples a Wick or Capsule. Live today stays out of the pool.” → opens Wick then ray sheet.
  - “Contact” / `https://aedicule-niche.pro/contact-us` → opens that URL.
  - “Re-run onboarding” → shows onboarding again.
  - “Reset all data” / “Erase glows on this device” → confirmation.
- Confirm reset: title “Erase the niche?”; body “This clears glows, clips, photos, and rays on this device.”; “Erase every glow and ray” (destructive); “Keep” (cancel).

### Wick then ray (sheet from Settings)
- Title “Wick then ray”.
- Empty: same title/line as above; “Open Moments”.
- Populated: ray count, “Rays on this device”, the Draw explanation line, optional staged feeling with role chip and day figure, “Capsules N.”, “Open Moments”.

## Features
- Catch a feeling into today’s glow (Ember, Hush, Bloom, Tide, Hearth, Gleam, Still, Lift).
- Live glows sit in the niche glass; Midnight folds Live to Wick and freezes photo/voice attach.
- Attach Photo or Voice only while a glow is Live; play a saved clip.
- After more than 30 days, a glow becomes a Capsule in the Garden.
- Draw samples a cooled Wick or Capsule as a Ray; Live today stays out of the pool.
- Garden living bloom and year collage of Capsules.
- Onboarding (first run and re-run from Settings).
- Contact support link.
- Reset all data on this device.
- Dark, portrait niche UI with Moments / Garden / Settings.

## Behaviours that can look like bugs
- “Draw” shows “Nothing cooled” and stays disabled until at least one glow is no longer Live today (after midnight / older days). Catch first, wait for a day fold, or use cooled sample content if present.
- Photo and Voice appear only on the focused Live card; after midnight they refuse with “Media freezes after midnight.”
- Garden stays “Nothing in bloom.” until a glow is older than 30 days; use “Open Moments” meanwhile.
- Settings empty state until the first Catch; Contact still works there.
- “Catch” / “Draw” / reset briefly disable while saving.
- Empty Moments before any Catch: “Nothing saved yet.” — tap “Catch”.
- Voice first time: sheet requires “Continue”; if denied, only “Open Settings” continues.
- Onboarding cannot be swiped away; “Skip” or last “Continue” is required.
- After Erase, Moments returns empty; lists grow again only with new Catches and Draws.
- Fault screens (“The niche could not be read.” / write/seed/photo/voice faults) need “Retry” or a fresh action; restore may show “Restored from a backup copy.” with “OK”.
- Successful Catch/Draw may flash “Saved.”

## Starter content and resume
Simulator-only demo seed when the niche is empty: several Live feelings (Ember, Hush, Bloom, Tide), older Wicks and Capsules, and sample Rays—onboarding already complete. On a real device install: None.

Unfinished work resumes: glows, photos, clips, and rays stay on this device across launches. A Live glow can still take Photo/Voice until midnight. Onboarding completion is remembered; Settings can re-run it. After “Reset all data”, the niche is empty again.

## Permissions
- **Microphone** — when the user taps “Voice” on a Live glow and the status is not yet decided; after the in-app “Voice” sheet, “Continue” triggers the system prompt. Usage: “Aedicule records a short voice clip onto today's Live glow. The clip stays on this device.”
- **Notifications** — system prompt may appear at cold launch. No custom usage-description string in the app’s Info settings.
- Camera usage string is present (“This app does not use the camera.”) but the native UI does not ask for camera access; Photo uses the system photo picker.

## Absent
login or accounts; in-app purchase; ads; analytics; account deletion flow; App Tracking Transparency prompt.

(User-generated content is present: feelings, photos, and voice clips saved on device.)

## Data and support
Data stays on this device (stated in onboarding and reset copy). Support: Settings “Contact” opens `https://aedicule-niche.pro/contact-us`.

## Scanning and health
None.

## Platform
English development region; day labels follow the device calendar and locale. Portrait only on iPhone and iPad. Dark appearance. Requires iOS 17.0 or later.

## Category
Lifestyle
