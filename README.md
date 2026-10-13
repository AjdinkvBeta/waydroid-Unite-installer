# Unite Waydroid Installer

Play **Pokémon Unite** on the **Steam Deck** by running the Android version in
[Waydroid](https://waydro.id) — with a point-and-click installer, no terminal needed.

Pokémon Unite has no PC/Steam version. It exists for Nintendo Switch, Android and iOS,
and the Switch 1 version is known to run poorly. This project sets up Android on the
Steam Deck so you can install the Android version from Google Play.

> [!NOTE]
> **Status (October 2026):** On SteamOS 3.8 Pokémon UNITE installs, starts, downloads its
> in-game update and reaches the login. Logging in can currently fail with
> *"Data error detected. Please try again."* – see [Troubleshooting](#data-error-detected-at-logging-in).

> [!WARNING]
> **Unofficial and with no guarantees.** Pokémon Unite has anti-cheat and may refuse to
> run inside Waydroid, or stop working later. Try it with a **new Pokémon Trainer Club
> account** first and only link your main Nintendo Account once it runs well.
> This project is not affiliated with Nintendo, The Pokémon Company, TiMi Studio Group or Valve.

---

## Contents

- [Requirements](#requirements)
- [Install](#install)
- [Start Android and sign in](#start-android-and-sign-in)
- [Install Pokémon Unite](#install-pokémon-unite)
- [Play with the Steam Deck controls](#play-with-the-steam-deck-controls)
- [Google Play certification (optional)](#google-play-certification-optional)
- [After a SteamOS update](#after-a-steamos-update)
- [Troubleshooting](#troubleshooting)
- [Uninstall](#uninstall)
- [What this installer fixes](#what-this-installer-fixes)
- [Credits and licenses](#credits-and-licenses)

---

## Requirements

- Steam Deck on **SteamOS 3.7 or newer** (developed on SteamOS 3.8, kernel 6.18)
- At least **10–15 GB** free storage
- Wi-Fi and the Deck plugged in during installation
- A Google account (for Play Store)

You do **not** need to know how to use the terminal.

---

## Install

1. Switch to **Desktop Mode**: press the **STEAM** button → **Power** → **Switch to Desktop**.
2. Open a web browser and go to this page.
3. Right-click (left trigger on the Deck) on this link and choose **Save Link As…**:
   **[Unite-Waydroid-Installer.desktop](https://raw.githubusercontent.com/AjdinkvBeta/waydroid-Unite-installer/main/Unite-Waydroid-Installer.desktop)**
4. Open your **Downloads** folder and **double-click** `Unite-Waydroid-Installer.desktop`.
   If KDE asks whether you trust/want to run it, choose **Continue** / **Execute**.
5. The installer opens and guides you with windows:
   - **Sudo password** – if your Deck doesn't have one yet, a small window lets you create one.
     The characters stay hidden while you type – that is normal.
   - When it asks which Android image to use, choose **A13_GAPPS**
     (Android 13 with Google Play – already selected).
   - The installation takes about **5–15 minutes**.
6. When it says **"Waydroid is installed!"** you are done.

The installer also creates a shortcut called **Unite Waydroid** on your desktop **and in your
Steam library** (Non-Steam). Use it later to reinstall, repair, uninstall or get the Android ID.

---

## Start Android and sign in

1. Go back to **Game Mode** (double-click **Return to Gaming Mode** on the desktop).
2. **Library → Non-Steam → Waydroid**. The first start can take a minute.
3. Open **Play Store** and sign in with your Google account.

In Game Mode you get the on-screen keyboard with **STEAM + X**.

If Play Store won't let you sign in or complains that the device is not certified, do the
[Google Play certification](#google-play-certification-optional) first.

---

## Install Pokémon Unite

1. Search for **Pokémon UNITE** in Play Store and install it.
2. Open it and let it download its extra data.
3. Test with a **new Pokémon Trainer Club account** first. If it runs well, sign in with your
   **Nintendo Account** to keep your Switch progress (cross-progression).

---

## Play with the Steam Deck controls

The mobile version of Pokémon Unite has **no controller support** – it only understands touch.
You can always play directly on the **touchscreen**. To use the sticks and buttons you need a
**key-mapper app** inside Android, which turns button presses into touches on the screen.

The installer already **activates Mantis Gamepad Pro and K2er automatically** every time
Waydroid starts, so you don't need a PC, ADB or Shizuku. Pick one of them:

1. In Waydroid, install **Mantis Gamepad Pro** (or **K2er**) from Play Store.
2. Open it once and follow its first-time setup, then **close Waydroid and start it again** –
   the activation runs automatically on start.
3. Start **Pokémon Unite** with the key-mapper's overlay and place controls on top of the
   game's buttons, for example:

   | Steam Deck | Pokémon Unite |
   |---|---|
   | Left stick | Movement joystick |
   | **A** | Basic attack |
   | **X** / **Y** | Move 1 / Move 2 |
   | **R1** | Unite Move |
   | **L1** | Battle item |
   | **B** | Score (at a goal zone) |
   | **R2** / **L2** | Recall / Ping (optional) |

4. Save the profile – it loads automatically next time you play.

Tips:
- In the Steam library, keep the **Waydroid** shortcut on the default controller layout
  (*Gamepad*), so Android sees a normal controller.
- Moves that must be aimed are the trickiest with buttons. Many players map them to tap
  (auto-aim) and aim the occasional skill shot on the touchscreen – touch keeps working
  while the key-mapper is active.
- Controller not detected? Restart Waydroid. Bluetooth headphones can interfere with
  controller detection.

---

## Google Play certification (optional)

**Try installing and playing Pokémon Unite first – you may not need this.**

Google doesn't trust Waydroid automatically. On an uncertified device the Play Store can refuse
sign-in, say *"Device is not certified"*, hide some apps, or Google sign-in and in-app purchases
can fail. Registering the device fixes that. It does **not** help against a game's anti-cheat –
if Pokémon Unite rejects Waydroid, certification won't change it.

1. In Desktop Mode, open **Unite Waydroid** and choose **Get Android ID (Google Play certification)**.
2. Your Android ID is shown and copied to the clipboard. Press **OK** and the Google page opens:
   <https://www.google.com/android/uncertified> (you can also do this on your phone).
3. Sign in with the **same Google account** you use in Waydroid, paste the ID and press **Register**.
4. Wait **30 minutes to a few hours**, then restart Waydroid.

**How do I know it worked?** In Play Store: tap your **profile picture → Settings → About** →
**Play Protect certification** should say **"Device is certified"**.

Still not certified after several hours? In Android go to **Settings → Apps**, clear the data of
**Google Play Store** and **Google Play services**, and restart Waydroid.

---

## After a SteamOS update

SteamOS updates replace the system files, which removes Waydroid (your Android data and
Pokémon Unite stay in your home folder). To get it back:

1. Switch to **Desktop Mode** and open **Unite Waydroid**.
2. It detects that Waydroid is missing and offers to reinstall it — press **Yes**.

The installer always updates itself to the newest version from this repository first.

---

## Troubleshooting

All output is logged to `~/unite-waydroid/install.log`. You can also open it from the menu
(**Show log**). Please attach it if you open an issue.

### Desktop Mode goes straight back to Game Mode

This is the known problem of the original installer on SteamOS 3.8: it replaced the system
library **libdisplay-info 0.3.0** with an older 0.2.0, and Desktop Mode (KWin) can't start
without 0.3.0.

**Fix A – with this installer:** in Game Mode open **Library → Non-Steam → Unite Waydroid**.
It detects the problem and offers to repair it.

**Fix B – manually, if you never ran this installer** (needs a terminal, e.g. Konsole added
to Steam):

```bash
cd /tmp && curl -LO https://raw.githubusercontent.com/AjdinkvBeta/waydroid-Unite-installer/main/vendor/libdisplay-info-0.3.0-1-x86_64.pkg.tar.zst && sha256sum libdisplay-info-0.3.0-1-x86_64.pkg.tar.zst
```

The checksum must be `858599998c434b97a79c997b26ccfed21acf8b12037f7313ef485ca884005b93`. Then:

```bash
sudo steamos-readonly disable; sudo pacman -R --noconfirm cage wlroots0.18; sudo pacman -U --noconfirm libdisplay-info-0.3.0-1-x86_64.pkg.tar.zst; sudo steamos-readonly enable
```

**Fix C – without a terminal:** *Settings → System → OS Update Channel* → switch to **Beta**
and install the update. A SteamOS update rewrites the system and removes the broken library
(your games and files are kept).

### "Failed to load binder driver" / "Module binder_linux not found"

The kernel on SteamOS 3.8+ has no binder module. This installer builds it automatically —
make sure you use this installer and not the original one.

### Pokémon Unite closes at "Preparing to start game… 30%"

Waydroid is using the **libndk** ARM translator, which crashes on the game's native code
(`Guest call didn't restore sp` in `libndk_translation.so`). Open **Unite Waydroid** and choose
**Switch ARM translator to libhoudini**. New installs use libhoudini automatically.

### Pokémon Unite closes immediately when you tap it

No ARM translator is active (the log says `libanogs.so … is for EM_AARCH64`). Run
**Switch ARM translator to libhoudini** from the menu.

### "Data error detected" at "Logging in…"

Known open issue. The game is fully downloaded but the login is refused. Likely causes are the
game's anti-cheat (Tencent AntiCheat Expert, `libanogs.so`) or the device not being Google-certified.
Things to try: press **Retry**, restart the game, complete the
[Google Play certification](#google-play-certification-optional), and clear the game's
**cache** (not data) in Android *Settings → Apps → Pokémon UNITE → Storage*.
If you find a fix, please open an issue.

### Pokémon Unite crashes or says the device is not supported

Most likely the game's anti-cheat blocks Waydroid. There is no reliable fix for that.

### Collecting a crash log

With the Android window open right after a crash, in Konsole:

```bash
sudo waydroid shell -- logcat -d | grep -iE " F DEBUG|FATAL|UnsatisfiedLink" | tail -40
```

You can start Android in a window in Desktop Mode with `~/Android_Waydroid/Android_Waydroid_Cage.sh`.

### Something else

Open an issue and attach `~/unite-waydroid/install.log` plus your SteamOS version
(*Settings → System*).

---

## Uninstall

Open **Unite Waydroid** and choose **Uninstall Waydroid**. This removes Waydroid and all Android
data. Your Steam games and files are not touched. Afterwards you can delete the **Waydroid** and
**Unite Waydroid** shortcuts from your Steam library and the `~/unite-waydroid` folder.

---

## What this installer fixes

It is a graphical front-end around ryanrudolfoba's
[SteamOS Waydroid Installer](vendor/README.md) (bundled in `vendor/`, because the original
repository was removed from GitHub). At install time it applies these fixes to a copy:

| Problem on SteamOS 3.8+ | Fix |
|---|---|
| Kernel has no binder module → Android can't start | Builds `binder_linux-dkms` for the running kernel |
| Installing `cage` pulls an old `wlroots0.18` that downgrades `libdisplay-info` → **Desktop Mode breaks** | cage is never installed system-wide; it runs from a private folder (`~/unite-waydroid/cage`) with its own libraries |
| Desktop Mode already broken by an earlier install | Detects it and restores Valve's `libdisplay-info 0.3.0` (checksum-verified) |
| The libndk ARM translator crashes Pokémon Unite while loading | Installs **libhoudini** instead (and offers to switch older installs) |
| Waydroid's overlay folder is on the ~230 MB `/var` partition, too small for the translator ("No space left on device") | Bind-mounts it from `~/waydroid/overlay` on `/home` (via `/etc/fstab`) |
| Original installer and updater point to a deleted repository | Uses the bundled copy; the "Updater" opens this installer |
| Terminal-only | Windows for password, progress, errors and every step |

Advanced users can also run it from a terminal:

```bash
mkdir -p ~/unite-waydroid && curl -fsSL https://raw.githubusercontent.com/AjdinkvBeta/waydroid-Unite-installer/main/unite-waydroid.sh -o ~/unite-waydroid/unite-waydroid.sh && bash ~/unite-waydroid/unite-waydroid.sh
```

---

## Credits and licenses

- **SteamOS Waydroid Installer** by ryanrudolfoba / 10MinuteSteamDeckGamer — GPL-3.0,
  bundled unmodified in `vendor/steamos-waydroid-installer`
- **[Waydroid](https://waydro.id)** — the Android container
- **[waydroid_script](https://github.com/casualsnek/waydroid_script)** by casualsnek — installs the ARM translator (Intel **libhoudini**) and Widevine
- **[binder_linux-dkms](https://github.com/choff/anbox-modules)** — binder kernel module
- **libdisplay-info** — MIT, Valve's SteamOS package bundled in `vendor/` for repairs

Pokémon and Pokémon UNITE are trademarks of Nintendo / Creatures Inc. / GAME FREAK inc. /
The Pokémon Company.
