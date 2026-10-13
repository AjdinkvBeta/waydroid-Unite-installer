#!/bin/bash
# =====================================================================
#  Unite Waydroid Installer – Pokémon Unite on Steam Deck via Waydroid
#  https://github.com/AjdinkvBeta/waydroid-Unite-installer
#
#  Graphical (zenity) front-end around ryanrudolfoba's SteamOS Waydroid
#  installer (GPL-3, vendored in vendor/steamos-waydroid-installer) with
#  fixes for SteamOS 3.8+:
#    * builds the binder kernel module when the kernel lacks it
#    * never installs cage/wlroots0.18 system-wide (that downgrades
#      libdisplay-info and breaks Desktop Mode); cage gets its own
#      private copy of its libraries instead
#    * can repair Desktop Mode if it was broken by an earlier install
# =====================================================================

APP="Unite Waydroid Installer"
GH_REPO="https://github.com/AjdinkvBeta/waydroid-Unite-installer"
export GIT_TERMINAL_PROMPT=0

BASE="$HOME/unite-waydroid"
SELF="$BASE/unite-waydroid.sh"
SRC="$BASE/src"                                  # clone of this repository
LOG="$BASE/install.log"
CAGE_DIR="$BASE/cage"
CAGE_BIN="$CAGE_DIR/cage"
REPO_DIR="$HOME/steamos-waydroid-installer"      # working copy of the installer
DESKTOP_FILE="$HOME/Desktop/Unite-Waydroid.desktop"
CERT_URL="https://www.google.com/android/uncertified"

# Valve's original libdisplay-info 0.3.0-1 (MIT licensed), used to repair Desktop Mode
LDI_FILE="libdisplay-info-0.3.0-1-x86_64.pkg.tar.zst"
LDI_SHA="858599998c434b97a79c997b26ccfed21acf8b12037f7313ef485ca884005b93"
LDI_FALLBACK_URL="https://raw.githubusercontent.com/Timbo303/SteamOS-Waydroid-Installer/5b15e6e475d2140299fe210de0bf9da784a670db/extras/pacman/$LDI_FILE"

PW=""

mkdir -p "$BASE"
echo "===== $(date) =====" >> "$LOG"

# ---------------------------------------------------------------- dialogs
info()  { zenity --info     --title "$APP" --width 480 --text "$1" 2>/dev/null; }
warn()  { zenity --warning  --title "$APP" --width 480 --text "$1" 2>/dev/null; }
ask()   { zenity --question --title "$APP" --width 480 --text "$1" 2>/dev/null; }

error_with_log() {
  local tmp
  tmp=$(mktemp)
  {
    echo "$1"
    echo
    echo "Last lines of the log ($LOG):"
    echo "------------------------------------------------------------"
    tail -n 25 "$LOG"
  } > "$tmp"
  zenity --text-info --title "$APP – something went wrong" --width 820 --height 520 \
         --filename "$tmp" 2>/dev/null
  rm -f "$tmp"
}

# Runs a command/function with a pulsating progress window that shows the
# latest output line. Returns the command's exit status.
run_with_progress() {
  local text="$1"; shift
  local st="$BASE/.status"
  rm -f "$st"
  {
    ( "$@"; echo $? > "$st" ) 2>&1 | tee -a "$LOG" | sed -u -e 's/[<>&]//g' -e 's/^/# /'
    echo 100
  } | zenity --progress --pulsate --auto-close --no-cancel --title "$APP" \
             --width 620 --text "$text" 2>/dev/null
  return "$(cat "$st" 2>/dev/null || echo 1)"
}

# ---------------------------------------------------------------- sudo
as_root() { printf '%s\n' "$PW" | sudo -S -p '' "$@"; }

get_password() {
  [ -n "$PW" ] && return 0
  if [ "$(passwd --status "$(whoami)" 2>/dev/null | awk '{print $2}')" != "P" ]; then
    info "Your Steam Deck has no sudo password yet, and one is needed.\n\nA small window will open: type a new password, press Enter, type it again and press Enter.\nThe characters stay hidden while you type – that is normal.\n\nTip: in Game Mode press STEAM + X for the keyboard."
    konsole -e passwd 2>/dev/null || xterm -e passwd 2>/dev/null
    if [ "$(passwd --status "$(whoami)" 2>/dev/null | awk '{print $2}')" != "P" ]; then
      warn "No password was set. Please try again."
      return 1
    fi
  fi
  local i pw
  for i in 1 2 3; do
    pw=$(zenity --password --title "$APP – sudo password" 2>/dev/null) || return 1
    if printf '%s\n' "$pw" | sudo -S -k -p '' true 2>/dev/null; then
      PW="$pw"; return 0
    fi
    warn "Wrong password, please try again."
  done
  return 1
}

# ---------------------------------------------------------------- sources & self-update
update_sources() {
  if git -C "$SRC" rev-parse >/dev/null 2>&1; then
    git -C "$SRC" fetch -q --depth 1 origin main >>"$LOG" 2>&1 && \
      git -C "$SRC" reset -q --hard origin/main >>"$LOG" 2>&1
  else
    rm -rf "$SRC"
    git clone -q --depth 1 "$GH_REPO" "$SRC" >>"$LOG" 2>&1
  fi
}

install_self() {
  local src
  src="$(readlink -f "$0")"
  [ "$src" != "$SELF" ] && cp "$src" "$SELF"
  chmod +x "$SELF"
  mkdir -p "$HOME/Desktop"
  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Unite Waydroid
Comment=Install, repair or certify Waydroid for Pokémon Unite
Exec=bash "$SELF"
Icon=applications-games
Terminal=false
EOF
  chmod +x "$DESKTOP_FILE"
  local marker="$BASE/.added-to-steam"
  if [ ! -f "$marker" ] && command -v steamos-add-to-steam >/dev/null 2>&1; then
    steamos-add-to-steam "$DESKTOP_FILE" >>"$LOG" 2>&1 && touch "$marker"
  fi
}

# ---------------------------------------------------------------- Desktop Mode check & repair
desktop_broken() {
  [ -x /usr/bin/kwin_wayland ] || return 1
  ldd /usr/bin/kwin_wayland 2>/dev/null | grep -q 'not found'
}

ldi_ok() { echo "$LDI_SHA  $1" | sha256sum -c --quiet - >/dev/null 2>&1; }

do_repair_desktop() {
  local f="$BASE/$LDI_FILE"
  if ! ldi_ok "$f"; then
    if [ -f "$SRC/vendor/$LDI_FILE" ] && ldi_ok "$SRC/vendor/$LDI_FILE"; then
      cp "$SRC/vendor/$LDI_FILE" "$f"
    else
      echo "Downloading repair package..."
      curl -fL --retry 3 -o "$f" "$LDI_FALLBACK_URL" || return 1
    fi
  fi
  ldi_ok "$f" || { rm -f "$f"; echo "Repair package has a wrong checksum - NOT installed."; return 1; }
  as_root steamos-readonly disable
  local rm_pkgs
  rm_pkgs=$(pacman -Qq cage wlroots0.18 2>/dev/null)
  if [ -n "$rm_pkgs" ]; then
    echo "Removing $rm_pkgs ..."
    as_root pacman -R --noconfirm $rm_pkgs
  fi
  echo "Restoring libdisplay-info 0.3.0 ..."
  as_root pacman -U --noconfirm "$f"
  as_root steamos-readonly enable
  ! desktop_broken
}

repair_desktop() {
  get_password || return 1
  if run_with_progress "Repairing Desktop Mode..." do_repair_desktop; then
    info "Desktop Mode is repaired. You can switch to Desktop Mode again."
    return 0
  fi
  error_with_log "Desktop Mode could not be repaired automatically."
  return 1
}

# ---------------------------------------------------------------- installer patches
patch_installer() {
  local inst="$REPO_DIR/steamos-waydroid-installer.sh"
  local launcher="$REPO_DIR/extras/Android_Waydroid_Cage.sh"
  local shutdown="$REPO_DIR/extras/waydroid-shutdown-scripts"
  local updater="$REPO_DIR/extras/Waydroid-Updater.sh"
  local toolbox="$REPO_DIR/extras/Waydroid-Toolbox.sh"

  # 1) Build the binder module when the kernel does not provide it (SteamOS 3.8+)
  if grep -qw binder /proc/filesystems 2>/dev/null; then
    echo "Kernel provides binder."
  else
    echo "Kernel $(uname -r) has no binder - the installer will build the module."
    sed -i 's/^if awk "BEGIN {exit ! (\$STEAMOS_VERSION == \$BASE_VERSION)}"$/if true # unite-patch: build binder/' "$inst"
    grep -q 'unite-patch: build binder' "$inst" || { echo "Patch failed (binder)."; return 1; }
  fi

  # 2) Never install cage/wlroots system-wide (breaks Desktop Mode)
  sed -i -E 's/(pacman -S --noconfirm )(wlroots )?cage (wlr-randr)/\1\3/' "$inst"
  if grep -qE 'pacman -S[^#]*[[:space:]]cage([[:space:]]|$)' "$inst"; then
    echo "Patch failed (cage)."; return 1
  fi

  # 3) Use our private cage in the launcher and shutdown script
  sed -i "s|^\([[:space:]]*\)cage -- |\1$CAGE_BIN -- |" "$launcher" "$shutdown"
  if [ "$(grep -c "$CAGE_BIN -- " "$launcher")" -lt 2 ] || ! grep -q "$CAGE_BIN -- " "$shutdown"; then
    echo "Patch failed (launcher)."; return 1
  fi

  # 4) Don't log out at the end - we still have work to do
  sed -i 's/^if zenity --question --text="Do you Want to Return to Gaming Mode?"; then/if false; then # unite-patch/' "$inst"

  # 5) The installer's "Updater" points to a repository that no longer exists
  printf '#!/bin/bash\nexec bash "%s"\n' "$SELF" > "$updater"

  # 6) Toolbox uninstall: don't try to remove packages we never install, keep plymouth
  sed -i -E '/pacman -R/ { s/ plymouth//; s/ wlroots cage//; }' "$toolbox"
  return 0
}

# ---------------------------------------------------------------- private cage
do_setup_private_cage() {
  local tmp root p
  tmp=$(mktemp -d)
  root="$CAGE_DIR/root"
  echo "Downloading cage packages (nothing is installed system-wide)..."
  as_root steamos-readonly disable
  if ! as_root pacman -Sw --noconfirm --cachedir "$tmp" cage wlroots0.18 libliftoff libdisplay-info; then
    as_root steamos-readonly enable
    rm -rf "$tmp"; echo "Could not download the cage packages."; return 1
  fi
  as_root steamos-readonly enable
  rm -rf "$root"; mkdir -p "$root"
  for p in "$tmp"/cage-[0-9]*.pkg.tar.zst "$tmp"/wlroots0.18-[0-9]*.pkg.tar.zst \
           "$tmp"/libliftoff-[0-9]*.pkg.tar.zst "$tmp"/libdisplay-info-[0-9]*.pkg.tar.zst; do
    [ -f "$p" ] || { rm -rf "$tmp"; echo "Missing package: $(basename "$p")"; return 1; }
    echo "Extracting $(basename "$p")"
    if command -v bsdtar >/dev/null 2>&1; then
      bsdtar -xf "$p" -C "$root" --exclude '.*'
    else
      tar --zstd -xf "$p" -C "$root" --exclude='.*'
    fi
  done
  as_root rm -rf "$tmp"

  cat > "$CAGE_BIN" <<'EOF'
#!/bin/bash
# Private cage for Waydroid - uses its own libraries, not the system's
R="$(dirname "$(readlink -f "$0")")/root"
export LD_LIBRARY_PATH="$R/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$R/usr/bin/cage" "$@"
EOF
  chmod +x "$CAGE_BIN"

  if [ ! -x "$root/usr/bin/cage" ] || \
     LD_LIBRARY_PATH="$root/usr/lib" ldd "$root/usr/bin/cage" | grep -q 'not found'; then
    echo "The private cage is missing libraries:"
    LD_LIBRARY_PATH="$root/usr/lib" ldd "$root/usr/bin/cage" | grep 'not found'
    return 1
  fi
  echo "Private cage is ready."
}

setup_private_cage() {
  get_password || return 1
  run_with_progress "Setting up the display window for Android (cage)..." do_setup_private_cage \
    || { error_with_log "Setting up cage failed."; return 1; }
}

# ---------------------------------------------------------------- install
run_installer() {
  cd "$REPO_DIR" || return 1
  chmod +x steamos-waydroid-installer.sh
  printf '%s\n' "$PW" | ./steamos-waydroid-installer.sh
}

install_waydroid() {
  get_password || return 1

  if desktop_broken; then
    run_with_progress "Repairing Desktop Mode first..." do_repair_desktop \
      || { error_with_log "Desktop Mode could not be repaired."; return 1; }
  fi

  update_sources
  if [ ! -f "$SRC/vendor/steamos-waydroid-installer/steamos-waydroid-installer.sh" ]; then
    error_with_log "Could not download the installer files. Check your internet connection."
    return 1
  fi
  rm -rf "$REPO_DIR"
  cp -r "$SRC/vendor/steamos-waydroid-installer" "$REPO_DIR"
  patch_installer >>"$LOG" 2>&1 || { error_with_log "Could not prepare the installer."; return 1; }

  info "The installation starts now and takes about 5–15 minutes.\n\nWhen a window asks which Android image to use, choose:\n\n<b>A13_GAPPS</b>  (Android 13 with Google Play – already selected)\n\nKeep the Steam Deck plugged in and connected to Wi-Fi."

  run_with_progress "Installing Waydroid – this takes a while..." run_installer
  if ! command -v waydroid >/dev/null 2>&1 || [ ! -d /var/lib/waydroid ]; then
    error_with_log "Installing Waydroid failed (kernel $(uname -r))."
    return 1
  fi

  setup_private_cage || return 1

  if desktop_broken; then
    run_with_progress "Repairing Desktop Mode..." do_repair_desktop \
      || { error_with_log "Desktop Mode was affected and could not be repaired."; return 1; }
  fi

  info "<b>Waydroid is installed!</b>\n\n1. Go to Game Mode → Library → Non-Steam → <b>Waydroid</b>\n2. Open Play Store and sign in with Google\n3. Come back here and choose <b>Get Android ID</b> to certify the device"
}

# ---------------------------------------------------------------- Android ID
get_android_id() {
  get_password || return 1
  local db id py
  db=$(as_root find "$HOME/.local/share/waydroid" /var/lib/waydroid "$HOME/waydroid" \
        -path '*com.google.android.gsf/databases/gservices.db' 2>/dev/null | head -n1)
  if [ -z "$db" ]; then
    info "No Google data found yet.\n\nStart Waydroid in Game Mode, open Play Store, sign in – then try again."
    return 1
  fi
  py="$BASE/get_android_id.py"
  cat > "$py" <<'PY'
import sqlite3, sys, shutil, tempfile, os
src = sys.argv[1]
tmp = tempfile.mkdtemp()
dst = os.path.join(tmp, "g.db")
shutil.copy(src, dst)
for ext in ("-wal", "-shm"):
    if os.path.exists(src + ext):
        shutil.copy(src + ext, dst + ext)
row = sqlite3.connect(dst).execute(
    "select value from main where name='android_id'").fetchone()
print(row[0] if row else "")
shutil.rmtree(tmp, ignore_errors=True)
PY
  id=$(as_root python3 "$py" "$db" 2>>"$LOG")
  if [ -z "$id" ]; then
    info "The Android ID has not been created yet.\n\nOpen Play Store in Waydroid, wait a minute and try again."
    return 1
  fi
  for q in qdbus qdbus6; do
    command -v "$q" >/dev/null 2>&1 && \
      "$q" org.kde.klipper /klipper setClipboardContents "$id" >/dev/null 2>&1 && break
  done
  zenity --entry --title "$APP – Android ID" --width 560 \
    --text "Your Android ID (already copied to the clipboard):\n\n1. Press OK – the Google page opens in your browser\n   (you can also do this on your phone).\n2. Sign in with the <b>same Google account</b> as in Waydroid.\n3. Paste the ID and press Register.\n4. Wait 30 min – a few hours, then restart Waydroid.\n\nCheck: Play Store → profile picture → Settings → About →\n<b>Play Protect certification: Device is certified</b>." \
    --entry-text "$id" >/dev/null 2>&1 || return 0
  ( xdg-open "$CERT_URL" >/dev/null 2>&1 & )
}

# ---------------------------------------------------------------- uninstall
do_uninstall() {
  as_root steamos-readonly disable
  as_root systemctl stop waydroid-container.service 2>/dev/null
  local pkgs
  pkgs=$(pacman -Qq waydroid python-gbinder libgbinder libglibutil wlr-randr cage wlroots0.18 \
         binder_linux-dkms 2>/dev/null)
  [ -n "$pkgs" ] && as_root pacman -R --noconfirm $pkgs
  as_root rm -rf /var/lib/waydroid /etc/waydroid-extra \
    /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid_binder.conf \
    /etc/modprobe.d/waydroid_binder.conf /usr/bin/waydroid-startup-scripts \
    /usr/bin/waydroid-shutdown-scripts
  as_root steamos-readonly enable
  as_root rm -rf "$HOME/waydroid" "$HOME/.local/share/waydroid"
  rm -rf "$HOME/Android_Waydroid" "$CAGE_DIR" "$REPO_DIR" \
         "$HOME/Desktop/Waydroid-Toolbox" "$HOME/Desktop/Waydroid-Updater"
  desktop_broken && do_repair_desktop
  echo "Uninstalled."
}

uninstall_waydroid() {
  ask "Remove Waydroid and all Android data (apps, Google sign-in, Pokémon Unite download)?\n\nYour Steam games and files are not touched." || return 0
  get_password || return 1
  if run_with_progress "Removing Waydroid..." do_uninstall; then
    info "Waydroid has been removed.\n\nYou can delete the <b>Waydroid</b> and <b>Unite Waydroid</b> shortcuts from your Steam library manually."
  else
    error_with_log "Uninstall did not finish cleanly."
  fi
}

# ---------------------------------------------------------------- start
if ! command -v zenity >/dev/null 2>&1; then
  echo "zenity is missing - this installer must run on SteamOS." >&2
  exit 1
fi

# Self-update: always run the newest version from the repository
if [ -z "${UW_REEXEC:-}" ] && update_sources && [ -f "$SRC/unite-waydroid.sh" ] && \
   ! cmp -s "$SRC/unite-waydroid.sh" "$(readlink -f "$0")"; then
  cp "$SRC/unite-waydroid.sh" "$SELF"; chmod +x "$SELF"
  UW_REEXEC=1 exec bash "$SELF"
fi

install_self

if desktop_broken; then
  ask "<b>Desktop Mode is broken</b> (a system library was replaced by an earlier Waydroid install).\n\nRepair it now?" \
    && repair_desktop
fi

if ! command -v waydroid >/dev/null 2>&1; then
  ask "Waydroid is not installed (or was removed by a SteamOS update).\n\nInstall it now? This takes about 5–15 minutes." \
    && install_waydroid
elif [ ! -x "$CAGE_DIR/root/usr/bin/cage" ]; then
  ask "Waydroid is installed, but its display window (cage) still needs to be set up.\n\nDo it now? (Takes about a minute.)" \
    && setup_private_cage \
    && info "Done! Go to Game Mode → Library → Non-Steam → <b>Waydroid</b>."
fi

while true; do
  choice=$(zenity --list --title "$APP" --width 520 --height 380 \
      --text "Pokémon Unite on Steam Deck – what do you want to do?" \
      --column "Action" \
      "Install / reinstall Waydroid" \
      "Get Android ID (Google Play certification)" \
      "Repair Desktop Mode" \
      "Uninstall Waydroid" \
      "Show log" \
      "Exit" 2>/dev/null) || exit 0
  case "$choice" in
    "Install / reinstall Waydroid")                install_waydroid ;;
    "Get Android ID (Google Play certification)")  get_android_id ;;
    "Repair Desktop Mode")
        if desktop_broken; then repair_desktop; else info "Desktop Mode looks fine – nothing to repair."; fi ;;
    "Uninstall Waydroid")                          uninstall_waydroid ;;
    "Show log")
        zenity --text-info --title "$APP – log" --width 820 --height 520 --filename "$LOG" 2>/dev/null ;;
    *) exit 0 ;;
  esac
done
