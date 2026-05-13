# PsstWhisperOS

![macOS](https://img.shields.io/badge/macOS_14%2B-000?style=flat-square&logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-F05138?style=flat-square&logo=swift&logoColor=white)
![WhisperKit](https://img.shields.io/badge/WhisperKit-on--device_AI-333?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-2ea44f?style=flat-square)
![Price](https://img.shields.io/badge/Price-Free_Forever-8b5cf6?style=flat-square)
[![Releases](https://img.shields.io/badge/Releases-latest-0969da?style=flat-square&logo=github&logoColor=white)](https://github.com/anthonyjohn17/PsstWhisperOS/releases/latest)
[![Source code](https://img.shields.io/badge/Source_code-ZIP%20or%20tar.gz-24292f?style=flat-square&logo=github&logoColor=white)](https://github.com/anthonyjohn17/PsstWhisperOS/releases/latest)

**A local-first macOS voice layer for AI-native work.**

**Free, open-source alternative to [WisperFlow](https://wisperflow.com) and [SuperWhisper](https://
superwhisper.com).**

PsstWhisperOS is a local-first voice operating layer for builders. Hold a key, speak, and paste anywhere. Then optionally shape speech into prompts, commands, specs, and AI workflows.

On-device speech-to-text for macOS. Press a hotkey, talk, and your words appear wherever your cursor is. No cloud. No subscription. No audio leaves your Mac.

Powered by [WhisperKit](https://github.com/argmaxinc/WhisperKit) — Apple's CoreML-optimized Whisper running entirely on your hardware.

<p align="center">
  <img src=".github/screenshot-styles.png" alt="PsstWhisperOS Settings" width="720" />
</p>

## Download

**[Download the latest release](https://github.com/anthonyjohn17/PsstWhisperOS/releases/latest)** — opens this repository’s **Releases** page on GitHub.

From there you can grab the full project to build and run locally:

1. On the release you want, expand **Assets** (same pattern as any GitHub release).
2. Download **Source code (zip)** or **Source code (tar.gz)** — that is the complete repository snapshot for that tag.
3. Unpack the archive, open a terminal, `cd` into the folder, then follow **[Building from source](#building-from-source)** below (`./scripts/dev-build.sh` for a debug `.app`, or `./build-app.sh` to produce a DMG under `dist/`).

You can also **clone** the repo instead of using the zip/tarball:

```bash
git clone https://github.com/anthonyjohn17/PsstWhisperOS.git
cd PsstWhisperOS
```

If a **pre-built DMG** is attached to a release, it will appear under **Assets** as well — download it, open the DMG, and drag **PsstWhisperOS** into Applications (then use **Installation** below). Until then, use the source archive + build steps.

> Ad-hoc or dev-signed builds may require **right-click → Open** the first time to satisfy Gatekeeper.

## What This Codebase Is

PsstWhisperOS is a macOS menu bar app built with Swift and SwiftUI. It captures microphone audio, transcribes speech on-device with WhisperKit, formats the result, and pastes it into the frontmost application. The project is a Swift Package Manager executable with a small set of services, models, and settings views wired through a single `AppState` observable object.

The app is designed for builders who want a fast, private voice layer across editors, terminals, browsers, and AI tools. The core loop is intentionally simple: hold a hotkey, speak, release, and paste. Around that loop, the codebase adds transcription modes, custom prompt templates, vocabulary, **prompts** (trigger phrases that expand into reusable text), writing styles, model management, recording history, and **notes**.

## How It Works

```
HotkeyManager (global key events via CGEvent tap)
  → AppState.startRecording / stopRecording
  → AudioEngine (AVAudioEngine mic capture, PCM buffers)
  → WhisperRecognizer (WhisperKit transcription)
  → TextFormatter (vocabulary → prompts/snippets expansion → cleanup → mode → style)
  → ClipboardManager (NSPasteboard + CGEvent Cmd+V paste)
```

1. Press your hotkey (default: hold `Fn`)
2. Speak
3. Release — text appears in your current app

That is the default path. The same pipeline can also format output for different writing contexts before paste.

## Features

- **100% on-device** — transcription runs locally via WhisperKit; nothing is sent to a server
- **Menu bar app** — lives in the menu bar and stays out of the way
- **Global hotkeys** — hold-to-record or toggle mode, with customizable key combos
- **Auto-paste** — transcribed text is pasted into the frontmost app
- **Transcription modes** — Default, Professional, Casual, Code Comment, Bullet Points
- **Custom modes** — create your own with prompt templates using the `{{text}}` placeholder
- **Vocabulary** — custom word replacements for names and technical terms
- **Prompts** — trigger phrases that expand into reusable AI instructions or boilerplate (built-in starter pack on first launch)
- **Writing styles** — apply formatting preferences to output
- **Whisper model selection** — choose model size to balance speed and accuracy
- **Recording history** — search prior transcriptions
- **Notes** — keep working notes inside the app
- **Appearance** — System / Light / Dark mode for the settings window and recording overlay

## Project Layout

```
Sources/PsstWhisperOS/
├── Models/              AppState, settings, transcription modes, storage keys
├── Services/            Audio, WhisperKit, hotkeys, clipboard, formatting, updates
├── Views/               Menu bar UI, settings panes, recording overlay
│   └── DesignSystem/    AppTheme, SettingsCard, sidebar, appearance (System/Light/Dark)
├── Resources/           App icon and bundled assets
├── Info.plist           Bundle metadata and permission strings
└── PsstWhisperOSApp.swift
```

Persistence is handled with `UserDefaults`. There is no database and no sandboxing; the app needs global hotkeys, paste automation, and clipboard access.

## Requirements

- macOS 14 (Sonoma) or later
- Apple Silicon or Intel Mac
- Accessibility, Input Monitoring, and Microphone permissions

## Installation

After you have an app bundle (from a release **DMG** in **Assets**, or from `./scripts/dev-build.sh` / `./build-app.sh`):

1. If you used a **DMG**: open it and drag **PsstWhisperOS** into your **Applications** folder. If you used **dev-build**, run the `.app` from `dist-dev/` or open it from Finder.
2. Launch the app — **right-click → Open** on first launch if Gatekeeper blocks an ad-hoc or dev-signed build.
3. Grant the permissions it asks for:
   - **Accessibility** — needed for global hotkeys and paste automation
   - **Input Monitoring** — needed for capturing key events
   - **Microphone** — needed for recording your voice

**All releases:** [github.com/anthonyjohn17/PsstWhisperOS/releases](https://github.com/anthonyjohn17/PsstWhisperOS/releases)

## Building from Source

```bash
# Clone
git clone https://github.com/anthonyjohn17/PsstWhisperOS.git
cd PsstWhisperOS

# One-time dev signing cert (preserves TCC permissions across rebuilds)
./scripts/setup-dev-cert.sh

# Build and run (debug)
./scripts/dev-build.sh --run

# Build release DMG
./build-app.sh
# Output: dist/PsstWhisperOS-x.x.x.dmg
```

Raw Swift builds are also supported:

```bash
swift build -c debug
swift build -c release
```

## Attribution

PsstWhisperOS is forked from [Psst Free](https://github.com/dougwithseismic/psst-free) by Doug with Seismic. See [NOTICE.md](NOTICE.md).

## Maintainer

[John Anthony](https://github.com/anthonyjohn17)

## License

MIT
