# Setting up Luna on your Mac — for someone with zero CS experience

Hi. This is a step-by-step, no-jargon guide to getting the Luna app running on your computer so you can play with it. You don't need to know any code. You need a Mac. That's it.

Estimated time: 30–45 minutes (most of it is waiting for Xcode to download).

---

## What you'll do, in plain English

1. Install Xcode (Apple's free app for building iPhone apps).
2. Open this Luna project in Xcode.
3. Press play. Watch the app run on a pretend iPhone on your screen.

Optional bonus: install it on your real iPhone.

---

## Step 1 — Check you have a Mac

Luna requires a Mac running macOS **Sonoma 14** or newer.

To check:
- Click the Apple logo (top left of your screen).
- Click **About This Mac**.
- If it says macOS 14 or 15 or higher, you're good. If older, update macOS first (System Settings → General → Software Update).

---

## Step 2 — Install Xcode

Xcode is the free Apple app that builds iPhone apps. It's big (~10 GB). Grab a coffee.

1. Open the **App Store** on your Mac.
2. Search for **Xcode**.
3. Click **Get**, then **Install**. Enter your Apple ID password if asked.
4. Wait. This takes 20–40 minutes depending on your internet.

Once installed:
5. Open Xcode from your Applications folder.
6. When it asks "Install additional required components?", click **Install** and enter your Mac password.
7. Accept the license agreement.

You only do this once, ever.

---

## Step 3 — Download the Luna project

If you're reading this in a folder on your Mac already, great — skip ahead.

If the project is in GitHub and you have the link:
- Click the green **Code** button on the repo page.
- Click **Download ZIP**.
- Find the downloaded `Luna-main.zip` (usually in your Downloads folder).
- Double-click it to unzip. You now have a folder called `Luna` or `Luna-main`.

---

## Step 4 — Open the project

Inside the Luna folder, you'll see a file called **`Luna.xcodeproj`**.
It has a blue icon that looks like a blueprint.

Double-click it.

Xcode will open. It might take 30–60 seconds the first time. You'll see a bunch of panels. That's normal.

---

## Step 5 — Pick a pretend iPhone (Simulator)

Near the top of the Xcode window, you'll see a row that says:
**▶︎ Luna > [some device name]**

Click the device name. A dropdown appears.
Pick anything that starts with **iPhone 15** or **iPhone 16** (whichever you see).

If you see "No Simulators Found":
- Click **Window** in the menu bar → **Devices and Simulators**.
- Click the **Simulators** tab.
- Click the **+** button at the bottom left.
- Pick any iPhone model, click **Create**.

---

## Step 6 — Press play

Look for the ▶︎ (play) button at the top left of Xcode. Click it.

Xcode will:
1. Build the app (first build takes 1–2 minutes — this is normal).
2. Open a pretend iPhone window called **Simulator**.
3. Launch Luna on that pretend phone.

You'll see Luna's opening screen. You can click through the onboarding, answer the questions, and the app will respond.

**To interact with the simulator:**
- Click = tap.
- Click and drag = swipe.
- `Cmd ⌘ + Shift + H` = home button (take you back to the home screen of the pretend phone).

---

## Step 7 — What to do if something goes wrong

### "Build failed" with red errors in the top right

Most common cause: Xcode needs a moment to sync. Try:
1. **Product → Clean Build Folder** (or `Cmd ⌘ + Shift + K`).
2. Close Xcode completely.
3. Reopen `Luna.xcodeproj`.
4. Press ▶︎ again.

### "No such module" or "SwiftData errors"

This means your Xcode is older than 15. Update Xcode from the App Store.

### "Signing for Luna requires a development team"

This only matters if you're trying to run on a real iPhone. For the simulator, select **Luna** at the top left of the Xcode file tree → **Signing & Capabilities** tab → in the **Team** dropdown, pick whatever's there (or sign in with a free Apple ID via Xcode → Settings → Accounts).

---

## Step 8 (optional) — Run on your real iPhone

1. Plug your iPhone into your Mac with a cable.
2. Unlock the iPhone.
3. If your iPhone asks "Trust this computer?" — tap **Trust**.
4. Back in Xcode, click the device dropdown at the top (where the simulator is) and pick your iPhone from the list.
5. You'll likely need to sign in with a free Apple ID:
   - Xcode menu → **Settings** → **Accounts** tab → click **+** → **Apple ID** → sign in.
   - Back in the Luna project: click **Luna** in the file tree → **Signing & Capabilities** → pick your name in the **Team** dropdown.
6. Press ▶︎. The app will build and install on your iPhone.
7. First time: your iPhone will say "Untrusted Developer." To fix: on iPhone, go to **Settings → General → VPN & Device Management → Developer App → your Apple ID → Trust**.
8. Open Luna from the home screen of your iPhone. Done.

Apps built with a free Apple ID expire every 7 days — you just press ▶︎ from Xcode again to reinstall.

---

## Step 9 (optional) — Make it your own

You can change any text, color, or number without breaking things:

- **Colors** → `Luna/Theme/LunaColors.swift`
- **What Luna says to the user** → `Luna/Utilities/VoicePack.swift`
- **Onboarding questions** → `Luna/Views/Onboarding/OnboardingFlow.swift`

Make a small change (e.g. change `"hi. it's nice to meet you."` to `"hi babe."`), save (`Cmd ⌘ + S`), press ▶︎ again. Xcode rebuilds, the simulator relaunches with your change.

---

## Common "dumb" questions (they're not dumb)

**Q: I closed Xcode, how do I get back in?**
A: Open the `Luna` folder → double-click `Luna.xcodeproj`.

**Q: How do I turn off the simulator?**
A: Click the Simulator window → `Cmd ⌘ + Q`, or right-click its dock icon → Quit.

**Q: Can I use this without spending money?**
A: Yes. Xcode is free, simulators are free, running on your own iPhone with a free Apple ID is free. Only publishing to the App Store costs $99/year.

**Q: The app doesn't have my data from before. Is it broken?**
A: No. Each build is fresh on the simulator. Onboard again. Or install to a real iPhone for persistence.

**Q: I don't see Fraunces or Inter fonts — does it still look right?**
A: iOS falls back to SF Pro (Apple's default serif/sans). The app still looks polished. To add the custom fonts, see the note in [README.md](./README.md) — it's a 2-minute task once you're comfortable.

---

## You did it

Congratulations. You just built an iPhone app. Share it with whoever you want to show. The whole point of Luna is for it to feel like a best friend in your phone — see if it does.

If you get stuck, the Xcode error messages are usually specific enough to paste into a search engine. That's how every developer debugs too.
