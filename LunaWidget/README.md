# LunaWidget

Lock-screen + Home-screen widget for Luna. **Scaffold only — not yet wired into the build.**

## What it does

Three taps on your lock screen log how you feel into Luna without ever opening the app. Backed by the existing `LogMoodIntent` (`Luna/Intents/LunaIntents.swift`).

## Activating it

Widgets in iOS 17+ require their own Xcode target. To turn this folder into a working widget:

1. **Add the target.** In Xcode: `File → New → Target → Widget Extension`. Name it `LunaWidget`. Untick "Include Configuration Intent."
2. **Replace** the auto-generated swift file with `LunaQuickLogWidget.swift` from this folder.
3. **Add the App Group capability** to BOTH the main `Luna` target and the new `LunaWidget` target:
   - Signing & Capabilities → `+ Capability` → `App Groups`
   - Create / select `group.com.luna.app`
4. **Share the SwiftData container.** Move `ModelContainer` configuration into a shared Swift package, OR make Luna's `LogMoodIntent` available to the widget by adding the widget target to its Target Membership.
5. **Build** the `LunaWidget` scheme. The widget will appear in the simulator's widget gallery.

## Why this isn't auto-included

The Widget Extension target needs an `Info.plist`, code signing, and a separate executable bundle. Generating those from scratch by hand is fragile — the Xcode UI does it correctly in 30 seconds. The scaffold here is the only handwritten part.

## Future widget ideas

- **Cycle phase complication** for Apple Watch (uses `WidgetKit` + `ClockKit`).
- **Today's forecast** widget that shows the home screen forecast line.
- **Heart status** — shows which relationships have been draining you this week.
