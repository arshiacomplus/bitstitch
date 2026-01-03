# 🧵 BitStitch - File Rescue & Sticher

**BitStitch** is a cross-platform utility born from a common frustration: large downloads (OS images, high-end games, AI models) failing at 99% and leaving you with a corrupted, useless file. 

Instead of re-downloading gigabytes of data, BitStitch surgically "repairs" your file by cutting the corrupted end and appending only the missing parts.

![License](https://img.shields.io/github/license/arshiacomplus/bitstitch)
![Release](https://img.shields.io/github/v/release/arshiacomplus/bitstitch)
![Platform](https://img.shields.io/badge/platform-Android%20|%20Windows%20|%20Linux-blue)

## 💡 The Problem
When a download fails, the last few megabytes are often corrupted with junk data or "trailing nulls." Standard download managers usually force you to restart from scratch if the server doesn't natively support "Resume" (HTTP 206).

## 🔥 The Solution: The "BitStitch" Logic
1. **Truncate:** BitStitch removes the last 5MB (or a custom amount) of the corrupted file to reach a "clean" state.
2. **Direct Stitch:** If the server supports Range requests, the app fetches the missing bytes and appends them directly to your existing file.
3. **GitHub Action Assist:** If the server doesn't support Resume, BitStitch triggers a GitHub Action. The high-speed GitHub runners download the full file, cut the needed fragment, and send it back to your device to be stitched.

## ✨ Key Features
- **Android 13+ Support:** Uses `MANAGE_EXTERNAL_STORAGE` and `MethodChannel` for system-level file access and media scanning.
- **GitHub Integration:** Automate complex "Cut & Stitch" operations using your own GitHub PAT.
- **Multi-Platform:** One codebase running on Android (V8a, V7a), Windows (x64), and Linux (x64).

## 🛠 Installation

Grab the latest version from the **[Releases](https://github.com/arshiacomplus/bitstitch/releases)** tab.
- **Android:** Download the `.apk` (v8a for modern phones).
- **Windows:** Download the `.zip` and run `bitstitch.exe`.
- **Linux:** Download the `.zip` or build from source on Kali/Debian.

## ⚙️ Setup for GitHub Action Mode
To use the remote assist mode:
1. Fork this repo or create a new one.
2. Add `.github/workflows/fixer.yml` (found in this repo) to your repository.
3. Generate a **Personal Access Token (PAT)** with `workflow` scope.
4. Enter your Username, Repo Name, and Token into BitStitch Settings.

## 🏗 Built With
- [Flutter](https://flutter.dev) - The UI framework.
- [GitHub Actions](https://github.com/features/actions) - Remote file processing.
- [Zenity](https://help.gnome.org/users/zenity/stable/) - Linux file picking.

---
**Made with ❤️ by [Arshia](https://github.com/arshiacomplus) - Stay creative, even if you are lazy.**
