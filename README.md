# Aedicule

A private glass niche for good days. Catch a felt moment into today's alcove, then later Draw one cooled glow as a ray. For people who want a jar of warm days, not a social diary and not a year grid of moods.

## Architecture

The niche is a **Glow** ADT whose cases are Live, Wick, and Capsule. `NicheStore` is a fold over sparks rather than a list of journal rows the view edits. Catch writes a Glow with an emotion hue and an Int YYYYMMDD daykey. Several Live glows may share one day. A Glow stays Live while that daykey is today, so a library still and a voice clip may still attach. At the next local midnight the fold writes Wick and freezes media. Age over 30 days writes Capsule and blooms the garden. Draw samples one Wick or Capsule, never a Live glow, writes a RayMark, and stages that card.

Views observe `NicheWatch` and call `catchGlow`, `attachMedia`, `foldMidnight`, and `drawRay`. They never touch UserDefaults. The fold matches the product: home is catch-the-glow on a glass coverflow, and the only path back to a past moment is Draw.

Persistence is UserDefaults+Codable under `aed.niche.v1`, with photo and voice bytes in Application Support. Memory is the source of truth. There is no package dependency.

## Wick then ray

This is why someone would pick Aedicule. Catch writes today's glow. Midnight cools it to a Wick. After 30 days it becomes a Capsule. Draw samples a Wick or Capsule and writes a RayMark. Today is never in the pool. The Draw control lives on Moments. A dedicated Wick then ray sheet on Garden explains the same fold.

## Design

Violet night mood on the 7.1 tokens. Dark cinematic void. One jewel glow on the live Catch control. Custom drawing is confined to the glass alcove on Moments. Garden collage and Settings are stock List and Form. SF Pro only. Moments, Garden, and Settings switch in place as segments of one root glass.

Art style: 3D glass render, glassmorphism. Base prompt reused for every asset:

```
3D glass render with glassmorphism: studio-lit votive niche, frosted alcove, inner glow as atmosphere, refraction and soft bloom, quiet uncluttered ground, isolated subjects, cinematic void, no text, no letters, no logo, no photoreal stock, no specified colours
```

Exact prompts:

**aed_AppIcon** — 1024x1024

```
A single glass votive niche filling the canvas edge to edge, inner glow as the emblem, 3D glass render, no text, no alpha, no rounded mask
```

**aed_Splash** — 1290x2796

```
Tall frosted-glass niche in void, quiet uncluttered middle third for a wordmark, 3D glassmorphism, no text
```

**aed_Onboarding1** — 1024x1536

```
Cutout of a glass niche waiting to hold a glow, isolated, transparent corners, 3D glass render, no text
```

**aed_Onboarding2** — 1024x1536

```
Cutout of a hand catching a small glow into a glass recess, mid-gesture, isolated, transparent corners, no text
```

**aed_Onboarding3** — 1024x1536

```
Cutout of a cooled wick casting a thin ray beside a small garden plant, isolated, transparent corners, no text
```

**aed_EmptyHome** — 1024x1024

```
Cutout of an empty glass niche, calm, inviting, isolated, transparent corners, no text
```

**aed_EmptyList** — 1024x1024

```
Cutout of a bare garden bed with no capsules, isolated, transparent corners, no text
```

**aed_CardBackdrop** — 1200x800

```
Abstract frosted-glass atmosphere filling the canvas, low contrast, 3D glassmorphism, no text
```

**aed_ControlFace** — 512x512

```
Cutout of a small glass catch cup, the primary control face, isolated, transparent corners, no text
```

**aed_TwistHero** — 1024x1024

```
Cutout emblem of a wick throwing a single ray, isolated, transparent corners, 3D glass render, no text
```

**aed_SuccessMark** — 512x512

```
Cutout of a caught glow settled in glass, isolated, transparent corners, no text
```

**aed_HeaderDecor** — 1200x600

```
Wide cutout lintel of a glass aedicule, isolated, transparent corners, no text
```

## How this differs

This is the first warm_moments app in the portfolio. Home is catch-the-glow on a glass niche. The only way back to a past moment is Draw, which samples a Wick or Capsule and writes a RayMark. That is not a one-stroke year canvas, not a two-handed seal, not a savings vine, not a food photo log, and not a thread of dated beads.

## Build

```bash
cd Aedicule
xcodegen generate
xcodebuild -scheme Aedicule -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build-for-testing
```

Simulator seed is once, behind `aed.demo.v1`. After onboarding, `-ReviewScreen today|log|goals` opens Moments, Garden, and Settings.
