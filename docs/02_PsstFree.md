## Follow up to "01_superwhisper-brief.md"

>  Prompt:
Let's deeply analyze this following repo and actually tell me if it's a good alternative. If I can host it and have the codebase in my own local system, I would much rather like it if it's going to give me the basic features that I'm getting from other apps like SuperWhisper. So I want to really understand it. Give me a thorough breakdown of the entire codebase and the application and compare it to SuperWhisper, and tell me the pros and the cons.

Think deeply.

https://github.com/dougwithseismic/psst-free

---

**Psst Free is a genuinely promising local alternative** to Superwhisper for your exact “voice into Cursor” use case. But it is not yet a full Superwhisper replacement. Think of it as a **clean local dictation engine**, not yet a mature “voice productivity OS.” 🛠️🎙️

My blunt read:

> **For fast, free, private, local dictation into Cursor, Psst Free is a very good candidate. For Superwhisper-level polish, modes, cloud/local routing, meeting workflows, context awareness, and cross-device maturity, it is not there yet.**

---

# 1. What Psst Free actually is

Psst Free is a macOS menu-bar speech-to-text app. Its README describes it as a free, open-source alternative to WisperFlow and Superwhisper, using **on-device transcription via WhisperKit**, with no cloud, no subscription, and no data leaving your Mac. It supports global hotkeys, auto-paste, multiple transcription modes, custom modes, vocabulary/snippets, writing styles, and Whisper model selection. ([GitHub][1])

Its basic loop is exactly the loop you care about:

```text
Press hotkey → speak → release → text appears in current app
```

The default hold key is `Fn`, and the default toggle shortcut is `⌥ Space`, based on the code and README. ([GitHub][1]) ([GitHub][2])

---

# 2. Codebase architecture

The repo is small, readable, and Swift-native.

```text
psst-free/
├── PsstFree/
│   ├── Models/
│   │   ├── AppState.swift
│   │   ├── Settings.swift
│   │   ├── StorageKeys.swift
│   │   └── TranscriptionMode.swift
│   ├── Services/
│   │   ├── WhisperRecognizer.swift
│   │   ├── HotkeyManager.swift
│   │   ├── ClipboardManager.swift
│   │   ├── TextFormatter.swift
│   │   ├── LicenseManager.swift
│   │   ├── UpdaterManager.swift
│   │   └── AudioEngine.swift
│   ├── Views/
│   │   ├── SettingsView.swift
│   │   ├── RecordingOverlayView.swift
│   │   ├── MenuBarView.swift
│   │   ├── ModelsLibraryView.swift
│   │   ├── ModeEditorView.swift
│   │   ├── VocabularySettingsView.swift
│   │   ├── SnippetsSettingsView.swift
│   │   ├── SoundSettingsView.swift
│   │   ├── HistorySettingsView.swift
│   │   └── others
│   └── PsstFreeApp.swift
├── scripts/
├── website/
├── Package.swift
├── build-app.sh
└── README.md
```

It is a Swift Package Manager macOS app targeting **macOS 14+**, with dependencies on **WhisperKit** and **Sparkle**. It links Apple frameworks including AVFoundation, Carbon, and NaturalLanguage. ([GitHub][3])

That tells us the app is built around:

* **SwiftUI UI**
* **MenuBarExtra app shell**
* **WhisperKit transcription**
* **Carbon/CGEvent global hotkeys**
* **AVFoundation audio permissions**
* **Clipboard-based paste automation**
* **Sparkle-ready update system**

That is a sensible architecture for a small macOS utility.

---

# 3. The core runtime flow

The main app starts as a `MenuBarExtra`, showing a mic icon or recording icon depending on state. Settings are opened in a custom `NSWindow`, not SwiftUI’s default Settings scene, likely because menu-bar apps built via SPM can be finicky. ([GitHub][4])

The heart is `AppState`.

The lifecycle is roughly:

```text
App launches
  ↓
Load settings from UserDefaults
  ↓
Request microphone permission
  ↓
Start hotkey monitoring
  ↓
Load WhisperKit model in background
  ↓
User presses hotkey
  ↓
Start recording through WhisperKit audioProcessor
  ↓
Partial transcription updates overlay
  ↓
User releases / toggles off
  ↓
Final transcription runs
  ↓
TextFormatter formats output
  ↓
History saves result
  ↓
ClipboardManager copies and auto-pastes
```

`AppState` handles recording, model-loading states, live audio sample processing, the overlay state, formatting, history, clipboard copy, and auto-paste. ([GitHub][5])

This is not over-engineered. It is a small cockpit, not a spaceship cathedral.

---

# 4. Whisper transcription engine

`WhisperRecognizer.swift` is the core transcription service.

It uses **WhisperKit**, defaults to `distil-whisper_distil-large-v3_turbo`, keeps a fallback list of available models, and exposes WhisperKit’s `AudioProcessor` for recording. It also implements chunked transcription for longer recordings by maintaining confirmed and unconfirmed segments. ([GitHub][6])

Important implementation details:

* It loads the model in a detached task so the UI does not freeze.
* It supports cancellation during model loading.
* It tracks pipeline states like loading, ready, cancelled, and error.
* It uses `wordTimestamps`.
* It confirms older segments while keeping the last few segments editable.
* It avoids retranscribing confirmed chunks by using `clipTimestamps`.

This is more sophisticated than a toy demo. The chunking logic matters because long recordings can otherwise become slow and unstable.

But it is still young. The repo had only 4 commits and 3 stars when fetched, with a v1.0.1 release dated March 23, 2026. ([GitHub][1])

---

# 5. Hotkey system

`HotkeyManager.swift` is one of the better parts of the codebase.

It supports three recording states:

```text
idle
holding
toggled
```

It uses a CGEvent tap to listen for global key events and supports both:

* **hold-to-record**
* **toggle-to-record**

It explicitly checks for both Accessibility and Input Monitoring permissions, opens System Settings when missing, and retries every 2 seconds after permission changes. ([GitHub][7])

The default config is:

```text
Hold key: Fn
Toggle: Option + Space
```

That matches the user experience style of apps like Superwhisper: low-friction, global, always available. ([GitHub][2])

For your Cursor use case, this is exactly the architectural primitive you want.

---

# 6. Formatting, modes, snippets, vocabulary

Psst Free does not merely paste raw text. It has a lightweight formatting pipeline.

Built-in modes include:

| Mode          | Purpose                              |
| ------------- | ------------------------------------ |
| Default       | clean transcription with punctuation |
| Professional  | formal tone                          |
| Casual        | conversational tone                  |
| Code Comment  | formats output as code comments      |
| Bullet Points | turns speech into bullet points      |

Custom modes exist as `CustomMode` objects with a name, prompt, and icon. ([GitHub][8])

The `TextFormatter` applies:

```text
vocabulary replacements
→ snippet expansion
→ cleanup
→ built-in/custom mode formatting
→ writing style
→ restore snippet placeholders
```

It handles common dictation commands like “question mark,” “new line,” “open parenthesis,” “at sign,” and so on. It also uses placeholder tokens to prevent snippets from being mangled by capitalization or punctuation formatting. ([GitHub][9])

The changelog confirms v1.0.1 specifically improved the Models Library and fixed snippet integrity so snippet expansions are no longer damaged by writing styles. ([GitHub][10])

This is a very good sign: the maintainer is already fixing real workflow rough edges, not just painting the landing page.

---

# 7. Local-first privacy model

Psst Free’s strongest advantage is philosophical and architectural:

> **Everything is local. No cloud. No subscription. No server dependency.**

The README says transcription runs locally through WhisperKit and nothing is sent to a server. ([GitHub][1])

For you, that matters because your use case is mostly:

* Cursor dictation
* AI prompting
* technical notes
* possibly repo-specific ideas
* private product thinking
* architecture rambling

That kind of material is exactly what you may prefer to keep local.

---

# 8. Comparison with Superwhisper

Superwhisper is much more mature and more ambitious.

Superwhisper’s docs describe a three-stage flow:

```text
Dictation → Transcription → Smart Processing
```

It supports intelligent modes, context-aware AI, file transcription, language support across 100+ languages, BYOK, and unlimited cloud/local AI on Pro. ([Superwhisper][11])

Its modes allow per-mode voice models, AI models, app/site auto-activation rules, advanced audio handling, system audio recording, speaker identification, and AI post-processing. ([Superwhisper][12])

Superwhisper also distinguishes local and cloud voice models, including free local Whisper models and Pro cloud/local models. ([Superwhisper][13])

So the distinction is:

```text
Psst Free = local speech-to-text utility
Superwhisper = polished cross-platform AI dictation platform
```

---

# 9. Feature comparison

| Category                 | Psst Free                | Superwhisper                                             |
| ------------------------ | ------------------------ | -------------------------------------------------------- |
| Price                    | Free, open-source        | Free tier + Pro                                          |
| Source code              | Open                     | Closed                                                   |
| Local transcription      | Yes, WhisperKit          | Yes, local Whisper models                                |
| Cloud transcription      | No                       | Yes, Pro                                                 |
| App-wide dictation       | Yes                      | Yes                                                      |
| Auto-paste               | Yes                      | Yes                                                      |
| Hold-to-record           | Yes                      | Yes                                                      |
| Toggle recording         | Yes                      | Yes                                                      |
| Custom modes             | Yes, prompt templates    | Yes, deeper AI instructions                              |
| Built-in modes           | Basic                    | More mature: Voice, Message, Email, Note, Meeting, Super |
| Context awareness        | Not comparable / limited | Selected text, clipboard, app context                    |
| Meeting mode             | Not really               | Yes                                                      |
| System audio recording   | Not evident              | Yes                                                      |
| Speaker identification   | Not evident              | Yes                                                      |
| File transcription       | Not evident in README    | Yes                                                      |
| History                  | Yes, with search         | Yes, with reprocessing                                   |
| Reprocess old transcript | Not clearly equivalent   | Yes                                                      |
| BYOK                     | No                       | Yes, Pro                                                 |
| Cross-platform           | macOS only               | macOS, Windows, iOS                                      |
| Model variety            | WhisperKit local models  | Local + cloud + Deepgram + Parakeet etc.                 |
| Polished design system   | Early but promising      | Mature, refined                                          |
| Reliability maturity     | Young repo               | More mature product                                      |

---

# 10. Where Psst Free is good enough for you

For your current use case:

> “I want to speak into Cursor, Claude, browser apps, notes, and have the text appear.”

Psst Free can plausibly satisfy the **core 70%**:

* global hotkey
* local transcription
* auto-paste
* basic formatting
* custom modes
* snippets
* vocabulary
* model selection
* history

If Superwhisper’s free local model already feels accurate enough, Psst Free’s local WhisperKit-based path may be enough too. The key difference will be latency, punctuation, stability, and how well it handles long recordings on your Mac.

---

# 11. Where Psst Free will probably fall short

This is where the fairy dust thins out. 🧪

## 1. No mature AI-processing layer

Psst Free has formatting logic and prompt templates, but it does not appear to have a full language-model post-processing layer like Superwhisper’s Message, Email, Note, Super, and Custom AI modes.

Superwhisper explicitly separates voice processing from AI processing and uses AI to shape output based on mode purpose. ([Superwhisper][12])

Psst Free is more regex/template/style based.

That means:

```text
Psst Free = transcription + formatting
Superwhisper = transcription + AI transformation
```

## 2. No true Super Mode equivalent

Superwhisper’s Super Mode can use context such as active app, selected text, and clipboard. Its docs say context-aware modes can enhance AI processing using additional context. ([Superwhisper][12])

Psst Free currently does not look like it has a comparable context engine.

For coding, that matters because the dream workflow is:

```text
“Refactor this function”
```

and the app knows the selected code, app, clipboard, and current context.

Psst Free does not appear to be there yet.

## 3. No cloud fallback

Superwhisper can route to cloud models optimized for speed/accuracy and multiple providers. ([Superwhisper][13])

Psst Free is local-only. That is great for sovereignty, but weaker for:

* noisy audio
* complex long dictations
* multilingual work
* edge cases
* highest accuracy

## 4. Young project risk

The repo had 4 commits, 2 releases, and a tiny GitHub footprint at time of retrieval. ([GitHub][1])

That does not mean it is bad. It means you should treat it as:

> promising raw material, not battle-tested infrastructure.

## 5. Possible commercial remnants

`DISTRIBUTION.md` includes a commercial distribution checklist with Apple Developer Program, Sparkle updates, payment provider options, and references to `LicenseManager.swift`. It even suggests LemonSqueezy/Paddle setup and a one-time payment idea. ([GitHub][14])

That is not necessarily a problem. But it means the repo may contain scaffolding from a monetized version or intended commercial distribution. Worth inspecting before forking/rebranding.

---

# 12. Architecture judgment

I’d rate it like this:

| Dimension                            | Rating | Why                                                       |
| ------------------------------------ | -----: | --------------------------------------------------------- |
| Core concept                         |   9/10 | Strong, useful, clean local alternative                   |
| Technical architecture               | 7.5/10 | Sensible SwiftUI + WhisperKit + hotkey + clipboard design |
| Codebase maturity                    | 5.5/10 | Very young, small commit history                          |
| Feature completeness vs Superwhisper |   5/10 | Covers core dictation, misses advanced product brain      |
| Extensibility                        |   8/10 | Small, understandable, great for hacking                  |
| Privacy/sovereignty                  | 9.5/10 | Local-first, open source                                  |
| UX polish                            |   6/10 | Likely decent, not Superwhisper-level                     |
| Long-term fork potential             | 8.5/10 | Very good foundation for your own voice utility           |

Overall:

## As a Superwhisper replacement: **not fully yet**

## As a local Cursor dictation engine: **yes, very plausible**

## As a foundation for your own open-source voice-first macOS app: **strong candidate**

---

# 13. Pros

## Local and sovereign

No server, no subscription, no vendor lock-in. This is the big one.

## Open-source and hackable

You can inspect, fork, modify, rename, extend, and build your own version.

## Swift-native macOS app

It uses the right platform primitives: menu bar, global hotkeys, system permissions, clipboard automation, AVFoundation, SwiftUI.

## WhisperKit is a good choice

WhisperKit is optimized for Apple hardware and local inference. It is more “Mac-native” than wrapping a Python service.

## Global hotkey logic is solid

Hold and toggle states are implemented thoughtfully, with permission handling and retry logic.

## Custom modes, vocabulary, snippets

These give you immediate user-facing power without needing a cloud LLM.

## Long recording support exists

The confirmed/unconfirmed segment logic is a meaningful foundation for longer dictation.

---

# 14. Cons

## Not a complete Superwhisper clone

It lacks Superwhisper’s deeper mode system, context awareness, cloud/local routing, polished onboarding, cross-device support, and advanced AI transformations.

## Likely weaker formatting intelligence

Regex and prompt-template formatting are useful, but not the same as language-model rewriting.

## Young codebase

Small repo, few commits, few stars. Good for learning and forking, less ideal if you want something totally stable out of the box.

## No obvious robust plugin/automation layer

Superwhisper has deep links and broader workflow ergonomics. Psst Free may need added automation hooks.

## Potential signing/distribution friction

The README notes the release is ad-hoc signed and requires right-click Open to bypass Gatekeeper on first launch. ([GitHub][1])

## Possible commercial/license scaffolding

The commercial checklist references payment providers and license validation, which you should clean up if your fork is truly free/open-source. ([GitHub][14])

---

# 15. What I would do in your place

I would not immediately abandon Superwhisper.

I would run **Psst Free as a parallel experiment**.

Use this test matrix:

| Test                  | What to check                                   |
| --------------------- | ----------------------------------------------- |
| Cursor chat dictation | Does it paste reliably into Cursor?             |
| Long prompts          | Does it handle 5, 10, 20 minutes cleanly?       |
| Latency               | Does local inference feel fast enough?          |
| Punctuation           | Is output usable without manual cleanup?        |
| Technical terms       | Does vocabulary fix your AI/coding terms?       |
| Stability             | Does hotkey capture break after sleep/relaunch? |
| History               | Can you recover important dictations?           |
| Snippets              | Can you expand common prompt structures?        |
| CPU/battery           | Does model choice drain your Mac?               |

If it passes those tests, it becomes your local sovereign baseline.

---

# 16. The best use-case fit

Psst Free is best for:

```text
voice → text → paste into Cursor/Claude/ChatGPT/Notes
```

Superwhisper is better for:

```text
voice → intelligent transformation → app-aware output → meeting/files/context workflows
```

So if your main use case is:

> “I speak high-quality prompts into Cursor and Claude.”

Psst Free may be enough.

If your future use case becomes:

> “I want app-aware voice modes, AI formatting, meeting workflows, selected-text transformations, cloud fallback, file transcription, and cross-platform continuity.”

Superwhisper stays ahead.

---

# 17. The deeper opportunity

This repo is actually more interesting as **raw clay** than as a finished replacement.

You could fork it into something like:

```text
VoiceOS for Cursor
or
Psst Whisper OS
or
Local Voice Layer
```

Add:

* Cursor-specific mode
* Claude-specific mode
* “Prompt Builder” mode
* “Debug Brief” mode
* “Architecture Spec” mode
* selected text capture
* clipboard context
* app-aware routing
* local memory
* history reprocessing
* optional local LLM cleanup
* optional OpenAI/Anthropic BYOK mode
* Raycast/Shortcuts/deep-link support

Then it becomes not merely a Superwhisper clone, but a **voice-first agentic coding layer**.

That is the delicious path. 🧠⚙️

---

# Final verdict

Psst Free is a **good alternative for basic Superwhisper-style local dictation**, especially for Cursor. It has the right bones: SwiftUI, menu bar, global hotkeys, WhisperKit, auto-paste, modes, vocabulary, snippets, model selection, and history.

But Superwhisper is still the more complete product. It has a richer mode architecture, cloud/local model routing, AI post-processing, context awareness, file transcription, meeting features, broader platform support, and much more polish.

So the strategic answer is:

> **Use Superwhisper now for frictionless daily productivity. Clone Psst Free as your sovereign local foundation. If Psst Free’s accuracy and latency satisfy you, gradually evolve it into your own voice-first coding OS.**

[1]: https://github.com/dougwithseismic/psst-free "GitHub - dougwithseismic/psst-free: Free, open-source macOS speech-to-text. WisperFlow / SuperWhisper alternative — on-device transcription via WhisperKit. No cloud, no subscription. · GitHub"
[2]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/PsstFree/Models/Settings.swift "raw.githubusercontent.com"
[3]: https://github.com/dougwithseismic/psst-free/blob/main/Package.swift "psst-free/Package.swift at main · dougwithseismic/psst-free · GitHub"
[4]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/PsstFree/PsstFreeApp.swift "raw.githubusercontent.com"
[5]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/PsstFree/Models/AppState.swift "raw.githubusercontent.com"
[6]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/PsstFree/Services/WhisperRecognizer.swift "raw.githubusercontent.com"
[7]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/PsstFree/Services/HotkeyManager.swift "raw.githubusercontent.com"
[8]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/PsstFree/Models/TranscriptionMode.swift "raw.githubusercontent.com"
[9]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/PsstFree/Services/TextFormatter.swift "raw.githubusercontent.com"
[10]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/CHANGELOG.md "raw.githubusercontent.com"
[11]: https://superwhisper.com/docs/get-started/introduction "Introduction - Superwhisper"
[12]: https://superwhisper.com/docs/modes/modes "Intro to Modes - Superwhisper"
[13]: https://superwhisper.com/docs/models/voice "Voice - Superwhisper"
[14]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/DISTRIBUTION.md "raw.githubusercontent.com"


---
