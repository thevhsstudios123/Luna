# Luna — iOS Prototype

A female-first emotional wellness app. Not a period tracker. Not a meditation app.
It connects a woman's cycle, mood, energy, sleep, and relationships into one honest picture of who she is this week.

> **Voice.** Sassy, emotionally intelligent best friend. Soft when she needs to be, savage when it helps. Never clinical.

---

## What this repo is

A complete, high-fidelity SwiftUI prototype built for iOS 17+.
Everything in the brief is implemented — animated avatars, onboarding with instant read, home forecast, check-in, cycle wheel, emotional forecast, pattern recognition, relationship lens, shareable outputs, paywall screens (stubbed), themes, privacy tools, and more.

- **No seed data.** The app starts empty; empty states are designed with personality.
- **No third-party SDKs.** No analytics, no crash reporting.
- **Local-first.** SwiftData stores everything on-device.
- **HealthKit-ready.** A protocol seam exists at `Utilities/HealthKitProvider.swift` — the UI is wired through a `HealthProvider` you can implement later without touching views.

---

## Requirements

| Tool | Version |
|---|---|
| Xcode | 15.0 or newer |
| iOS Deployment Target | 17.0 |
| Swift | 5.9+ |
| macOS (for dev) | Sonoma 14+ recommended |

If you've never set up Xcode before, follow the **[SETUP.md](./SETUP.md)** walkthrough. It assumes zero CS experience.

---

## Running

```bash
open Luna.xcodeproj
```

Pick an iPhone 15 simulator (or newer), hit ▶︎. No signing required for simulator.

For device: select your team in `Luna` target → Signing & Capabilities → Team.

---

## Architecture

```
Luna/
├── LunaApp.swift               # @main entry, sets up SwiftData container
├── AppState.swift              # global non-persisted state (theme, voice, flags)
├── RootView.swift              # routes between onboarding / lock / main
│
├── Models/                     # @Model SwiftData entities
│   ├── UserProfile.swift
│   ├── CheckIn.swift
│   ├── CycleEvent.swift
│   ├── Person.swift
│   └── Interaction.swift
│
├── Theme/                      # design system
│   ├── LunaColors.swift        # palette tokens
│   ├── LunaTheme.swift         # Soft / Earth / Midnight
│   ├── LunaType.swift          # Fraunces + Inter, graceful fallbacks
│   ├── Haptics.swift
│   └── GrainOverlay.swift      # subtle canvas noise, no image assets
│
├── Avatars/                    # the emotional core — all SwiftUI paths
│   ├── MoonAvatar.swift        # phases: menstrual/follicular/ovulation/luteal
│   ├── BrainAvatar.swift       # sharp / okay / foggy / melted
│   └── HeartAvatar.swift       # full / neutral / drained / armored
│
├── Components/                 # reusable UI
│   ├── SoftCard.swift
│   ├── SoftButton.swift        # + ChipButton
│   ├── MoodSlider.swift        # + morphing emoji face
│   ├── TagGrid.swift           # + FlowLayout
│   └── CycleWheel.swift
│
├── Utilities/
│   ├── VoicePack.swift         # ALL user-facing copy routes through here
│   ├── CycleEngine.swift       # pure phase math, testable
│   ├── PatternEngine.swift     # insight generation over time
│   ├── NotificationCenter.swift
│   ├── HealthKitProvider.swift # protocol stub
│   └── DateExtensions.swift
│
└── Views/
    ├── Onboarding/OnboardingFlow.swift       # 7-step convo + instant read
    ├── Main/MainTabView.swift                # custom tab bar, no SF Symbols
    ├── Home/HomeView.swift                   # 3 avatars + forecast + tiles
    ├── Home/ForecastView.swift               # weekly + monthly
    ├── Home/BrainDetailView.swift
    ├── CheckIn/CheckInView.swift             # 30-second daily check-in
    ├── Cycle/CycleView.swift                 # scrubbable wheel, flow, symptoms
    ├── Patterns/PatternsView.swift           # insight cards + healing receipts
    ├── Relationships/RelationshipsView.swift # + PersonDetail, AddPerson, LogInteraction
    ├── Share/ShareView.swift                 # weekly/monthly/year-in-review
    ├── Paywall/PaywallView.swift             # stubbed StoreKit
    └── Me/MeView.swift                       # settings, privacy, export, panic delete, etc.
```

---

## Key design decisions

### MVVM + SwiftData, not Observable objects everywhere
Views that need persistence use `@Query` directly, which is idiomatic SwiftData and avoids the view-model-wrapping-query boilerplate. Pure logic (cycle math, pattern detection) lives in `Utilities/` as `enum` namespaces of pure functions — trivially unit-testable.

### Voice pack as the single source of brand copy
Every user-facing string goes through `VoicePack`, which branches on `.soft / .balanced / .savage`. Want to retune the voice? Edit one file.

### Avatars are SwiftUI shapes — no assets
Paths, gradients, and animations. No PNGs, no Lottie, no image sets. They breathe idly, react on log, and morph over phase transitions.

### Theme system
Three themes (Soft, Earth, Midnight). Swap via `AppState.theme`; `appState.theme.bgPrimary` / `.accent` / `.textPrimary` cascade through every view.

### Privacy posture
- All data lives in SwiftData on-device.
- Face ID gate via `LAContext` (optional, prompted in onboarding).
- Stealth mode + panic delete are wired in `Me/MeView.swift`.
- The app never touches the network. No SDKs, no telemetry.

---

## Where to plug in later

| Feature | File | What to do |
|---|---|---|
| **HealthKit** | `Utilities/HealthKitProvider.swift` | Add HealthKit entitlement, create a `HKHealthProvider: HealthProvider`, inject via `LunaApp.environment`. The UI already reads `BrainState.from(hours:)` and `FlowIntensity` — wire those to HealthKit samples. |
| **Backend / sync** | `LunaApp.swift` | Swap the `modelContainer` for one backed by CloudKit, or layer an E2E-encrypted sync service. Models are small plain structs, no custom types. |
| **StoreKit** | `Views/Paywall/PaywallView.swift` | Replace the `unlock()` stub with a StoreKit 2 `Product.purchase()` flow. Flip `appState.isPremium` on success. |
| **ML insights** | `Utilities/PatternEngine.swift` | Current logic is deterministic aggregation. Replace `insights(...)` internals with CoreML or a server-side model while keeping the `PatternInsight` contract. |
| **App icon variants (stealth mode)** | `Info.plist` | Add `CFBundleAlternateIcons` with "Calculator" and "Notes" variants, wire `UIApplication.setAlternateIconName` from the toggle in `MeView`. |
| **Notifications** | `Utilities/NotificationCenter.swift` | Already calls through `VoicePack` for copy. Add cycle-aware scheduling when `lastPeriodStart` changes. |

---

## Custom fonts

The prototype targets Fraunces (serif display) and Inter (body). Both are optional — if missing, iOS falls back to SF Pro. To add them:

1. Download from Google Fonts.
2. Drop the `.ttf` files into the `Luna/` folder in Xcode (check "copy if needed").
3. In Info (target settings), add `UIAppFonts` → array of file names.
4. `LunaType` already references the custom names; no code changes needed.

---

## Testing on device

For the simulator: no extra setup.
For a physical device: you'll need a free Apple ID for signing. See [SETUP.md](./SETUP.md).

---

## Known prototype limitations

- Paywall does NOT make real purchases; it flips a local flag.
- Screen time data is faked to a default value; real numbers come from HealthKit + `DeviceActivity` entitlements (both require App Store approval).
- Stealth mode toggle doesn't change the icon without alternate icons added to the asset catalog.
- ML-driven pattern insights are scaffolded but use deterministic heuristics.

None of these block the emotional experience — they're the typical production seams that get filled in after the prototype is loved.
