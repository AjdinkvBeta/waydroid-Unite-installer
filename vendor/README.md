# Vendored files

These files are bundled so the installer keeps working even if the original
sources disappear (the original installer repository was removed from GitHub
in 2026).

## `steamos-waydroid-installer/`

An **unmodified** copy of ryanrudolfoba's *SteamOS Waydroid Installer*,
commit `d7dd9503c849f9e03b3d2aaa38a0c66b191aa9d6` (December 2025), taken from
the mirror https://github.com/Legato666/steamos-waydroid-installer.

- Author: ryanrudolfoba / 10MinuteSteamDeckGamer
- License: GNU GPL v3 (see `steamos-waydroid-installer/LICENSE`)

`unite-waydroid.sh` copies this folder and applies its fixes to the copy at
install time (see `patch_installer` in the script). The files here are never
changed.

## `libdisplay-info-0.3.0-1-x86_64.pkg.tar.zst`

Valve's own SteamOS package of libdisplay-info 0.3.0 (packager:
`GitLab CI Package Builder <ci-package-builder-1@steamos.cloud>`), used only to
**repair Desktop Mode** after an install that downgraded this library.

- SHA-256: `858599998c434b97a79c997b26ccfed21acf8b12037f7313ef485ca884005b93`
- License: MIT (included inside the package at
  `usr/share/licenses/libdisplay-info/LICENSE`)
- Originally shipped by ryanrudolfoba for the same repair purpose.
