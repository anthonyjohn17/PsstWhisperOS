# PsstWhisperOS

![macOS](https://img.shields.io/badge/macOS_14%2B-000?style=flat-square&logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-F05138?style=flat-square&logo=swift&logoColor=white)
![WhisperKit](https://img.shields.io/badge/WhisperKit-on--device_AI-333?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-2ea44f?style=flat-square)
![Price](https://img.shields.io/badge/Price-Free_Forever-8b5cf6?style=flat-square)

**A local-first macOS voice layer for AI-native work.**

**Free, open-source alternative to [WisperFlow](https://wisperflow.com) and [SuperWhisper](https://
superwhisper.com).**

PsstWhisperOS is a local-first voice operating layer for builders. Hold a key, speak, and paste anywhere. Then optionally shape speech into prompts, commands, specs, and AI workflows.

On-device speech-to-text for macOS. Press a hotkey, talk, and your words appear wherever your cursor is. No cloud. No subscription. No audio leaves your Mac.

Powered by [WhisperKit](https://github.com/argmaxinc/WhisperKit) — Apple's CoreML-optimized Whisper running entirely on your hardware.

<p align="center">
  <img src=".github/screenshot-styles.png" alt="PsstWhisperOS Settings" width="720" />
</p>



## What This Codebase Is

PsstWhisperOS is a macOS menu bar app built with Swift and SwiftUI. It captures microphone audio, transcribes speech on-device with WhisperKit, formats the result, and pastes it into the frontmost application. The project is a Swift Package Manager executable with a small set of services, models, and settings views wired through a single `AppState` observable object.

The app is designed for builders who want a fast, private voice layer across editors, terminals, browsers, and AI tools. The core loop is intentionally simple: hold a hotkey, speak, release, and paste. Around that loop, the codebase adds transcription modes, custom prompt templates, vocabulary, snippets, writing styles, model management, and recording history.

## How It Works

```
HotkeyManager (global key events via CGEvent tap)
  → AppState.startRecording / stopRecording
  → AudioEngine (AVAudioEngine mic capture, PCM buffers)
  → WhisperRecognizer (WhisperKit transcription)
  → TextFormatter (vocabulary → snippets → cleanup → mode → style)
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
- **Vocabulary and snippets** — custom word replacements and spoken text expansion
- **Writing styles** — apply formatting preferences to output
- **Whisper model selection** — choose model size to balance speed and accuracy
- **Recording history** — search prior transcriptions
- **Scratchpad** — keep working notes inside the app

## Project Layout

```
Sources/PsstWhisperOS/
├── Models/          AppState, settings, transcription modes, storage keys
├── Services/        Audio, WhisperKit, hotkeys, clipboard, formatting, updates
├── Views/           Menu bar UI, settings panes, recording overlay
├── Resources/       App icon and bundled assets
├── Info.plist       Bundle metadata and permission strings
└── PsstWhisperOSApp.swift
```

Persistence is handled with `UserDefaults`. There is no database and no sandboxing; the app needs global hotkeys, paste automation, and clipboard access.

## Requirements

- macOS 14 (Sonoma) or later
- Apple Silicon or Intel Mac
- Accessibility, Input Monitoring, and Microphone permissions

## Installation

1. Download `PsstWhisperOS-x.x.x.dmg` from [Releases](https://github.com/anthonyjohn17/PsstWhisperOS/releases/latest)
2. Open the DMG and drag **PsstWhisperOS** to your Applications folder
3. Launch the app — right-click → **Open** on first launch if Gatekeeper blocks an ad-hoc build
4. Grant the permissions it asks for:
   - **Accessibility** — needed for global hotkeys and paste automation
   - **Input Monitoring** — needed for capturing key events
   - **Microphone** — needed for recording your voice

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
