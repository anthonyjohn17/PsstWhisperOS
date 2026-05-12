## Followup to "02_PsstFree.md"

> Prompt:
Okay, great. So, my goal right now is to clone the original repo, and I wanna update the current version of this repo with a few simple features, and maybe even strip it of some features. At a high level, I wanna take inspiration from SuperWhisper, and I wanna upgrade the UI to be more modern. But everything actually already looks great in the current version of the app, and considering this is going to be a local first app, and I want it to be something that people can just use on the fly and not really think about the look and feel of it all. I just wanna, you know, do some minor UI updates. And, let's see here, I'm looking at the app. So at a high level, I wanna rename the app to 'PsstWhisperOS' across the codebase. That's number one. Number two... I want to rename the scratchpad feature to notes. Let's keep the styles feature exactly the same. And next, I want to rename and update the snippets feature to prompts. So the idea is I can come up with keywords that can turn it into a set prompt for me. The entire feature is the same, but it's just the naming is different, and the trigger phrase is going to be the same, and it's going to expand into a prompt. And let's change the dictionary feature to vocabulary. Those are all of the The key changes that I want to make for now, and I'm also going to provide a UI example for how I want the UI for the next version to look like. It's going to be similar to SuperWhisper, but I want the look and feel to resemble this specific image, screenshot. 

SO I want to rename it to 'PsstWhisperOS' and host it on my own GitHub as an open source project. So how can I go about doing that like a creative, and 10x engineer? I want to keep this project easy and simple updates to current repo/codebase but highly effective. 

I also want to take inspiration from SuperWhisper app UX deep dive and design system from earlier for this rebrand and upgrade. 

Write up a deatiled overview and breakdown for this new upgrade. Provide the step by step tasks and update process nedded to get to my desired new version. Be meticulous and thorough, using all the key context in this thread.

---

Here is the clean 10x-engineer plan: **do not rebuild the product yet. Rebrand, rename mental models, lightly modernize the UI, preserve the working core.** 🛠️🎙️

The current repo already gives you the essential spine: local WhisperKit transcription, global hotkeys, auto-paste, modes, vocabulary/snippets, styles, and model selection. The README describes it as a free, local, menu-bar macOS speech-to-text app powered by WhisperKit, with no cloud and no subscription. ([GitHub][1])

# North Star

Rename and evolve it into:

## **PsstWhisperOS**

**A local-first macOS voice layer for AI-native work.**

Not a Superwhisper clone. Not a bloated assistant. More like:

> Press hotkey → speak → clean text/prompt appears anywhere.

The product should feel:

* local
* lightweight
* private
* fast
* minimal
* Cursor/Claude-friendly
* open-source
* elegant enough to trust daily

---

# 1. Preserve the core app behavior

Do **not** mess with the core transcription loop yet.

Keep:

* global hotkey
* hold-to-record
* toggle recording
* auto-paste
* local WhisperKit transcription
* model selection
* modes
* styles
* vocabulary replacement
* history
* snippets engine, but renamed to prompts

The repo already supports hold/toggle hotkeys and defaults to `Fn` hold plus `⌥ Space` toggle in `Settings.swift`. ([GitHub][2])

Your upgrade should be a **thin, high-leverage product pass**, not a rewrite.

---

# 2. Naming architecture

Make these exact semantic changes:

| Current           | New                | Why                                       |
| ----------------- | ------------------ | ----------------------------------------- |
| Psst Free         | **PsstWhisperOS**  | Stronger identity, local voice OS framing |
| Scratchpad        | **Notes**          | More familiar, less throwaway             |
| Snippets          | **Prompts**        | Better aligned with AI workflows          |
| Snippet trigger   | **Prompt trigger** | Same behavior, clearer meaning            |
| Snippet expansion | **Prompt text**    | Same engine, new mental model             |
| Dictionary        | **Vocabulary**     | Matches Superwhisper-style terminology    |
| Styles            | **Styles**         | Keep unchanged                            |
| Modes             | **Modes**          | Keep unchanged                            |

The existing formatter already applies vocabulary replacements and snippet expansions before cleanup and mode/style formatting, so renaming snippets to prompts can be mostly UI/model-label work rather than a core engine rewrite. ([GitHub][3])

---

# 3. Rebrand tasks

## A. Repository-level changes

Rename:

```text
psst-free → PsstWhisperOS
```

Update:

```text
README.md
Package.swift
build scripts
DMG names
App bundle name
Menu bar app title
About text
Settings window title
Release names
GitHub description
Website copy if retained
```

The repo is MIT-licensed, so you can fork, modify, and publish your own version, while preserving license/copyright attribution. The GitHub page lists the project license as MIT. ([GitHub][1])

## B. Codebase search/replace plan

Run controlled replacements, not blind chaos gremlin replacements:

```bash
rg "Psst Free|PsstFree|psst-free|Psst"
rg "Snippet|snippet|snippets"
rg "Scratchpad|scratchpad"
rg "Dictionary|dictionary"
```

Then update deliberately:

```text
Psst Free        → PsstWhisperOS
PsstFreeApp      → PsstWhisperOSApp
PsstFree/        → PsstWhisperOS/
PsstFree-x.x.dmg → PsstWhisperOS-x.x.dmg
snippets         → prompts
Snippet          → Prompt
scratchpad       → notes
dictionary       → vocabulary
```

Keep internal storage compatibility carefully. For example, if current users have `UserDefaults` keys named `snippets`, you can either keep the key internally and rename only the UI, or migrate it to `prompts`.

For now, I’d do this:

```text
UI label: Prompts
Storage key: snippets
Code comment: legacy key retained for migration safety
```

That avoids breaking behavior.

---

# 4. Product structure for v0.2

Your first upgraded version should have this sidebar:

```text
Home
Modes
Vocabulary
Prompts
Styles
Configuration
Sound
Models Library
History
Notes
```

But to keep it simple, you can also combine:

```text
Home
Modes
Vocabulary
Prompts
Styles
Configuration
Sound
Models Library
History
Notes
```

If you want fewer items:

```text
Home
Modes
Vocabulary
Prompts
Configuration
Sound
Models Library
History
```

I would **not** add too much yet. The more items you add, the more “settings cathedral” you create. Superwhisper works because it keeps complexity tucked into calm panels. Its docs frame modes as configurable processing behaviors with voice models, AI models, app activation, and advanced settings. ([Superwhisper][4])

---

# 5. UI direction inspired by your screenshot

Your screenshot has a beautiful “soft native utility” feel:

* light mode
* large rounded macOS window
* translucent/sidebar feel
* soft white content cards
* compact icon sidebar
* gray dividers
* pill dropdowns
* bold section titles
* restrained controls
* lots of breathing room

This is the target style:

## Design language

```text
macOS native
soft rounded cards
light-first
minimal color
quiet icons
large radius
clean sidebar
one setting group per card
no dashboard clutter
```

## Approximate tokens

```text
Window background:        #F4F4F5
Sidebar background:       #F2F2F3
Content card:             #FFFFFF / #FAFAFA
Border:                   rgba(0,0,0,0.06)
Primary text:             #111111
Secondary text:           #555555
Muted text:               #9A9A9A
Accent orange/home:       #FF7A45
Accent blue/modes:        #2388FF
Accent purple/history:    #6C5CE7
Corner radius cards:      22–28px
Small controls radius:    12–16px
Sidebar selected radius:  18–22px
Spacing unit:             8px
Card padding:             24–32px
```

## Sidebar pattern

Each sidebar item should have:

```text
[rounded square icon] [label]
```

Selected state:

```text
soft white rounded rectangle
subtle shadow or no shadow
icon color vivid
label black/bold-ish
```

Unselected state:

```text
transparent background
icon muted or colored
label dark gray
```

---

# 6. Concrete UI upgrades

## A. Settings window

Modernize the settings view into reusable components:

```swift
SidebarItem
SettingsCard
SettingsRow
PillPicker
ToggleRow
InfoLabel
SectionHeader
```

This prevents one giant SwiftUI soup bowl.

### Target card layout

```text
Card
├── Row title
├── Optional description
└── Control aligned right
```

Example:

```text
Language                         [English ˅]
Voice Model                      [△ Standard ˅]
```

## B. Modes page

Make the Modes page resemble your screenshot:

```text
Top bar:
< back icon>    mic icon    Default

Cards:
Preset                         [Voice to text ˅]

Language                       [English ˅]
Voice Model                    [Standard ˅]

Activate for apps              [Add apps and sites]
Keyboard shortcut              Record shortcut

Advanced settings
Playback when recording        [Pause ˅]
Record from system audio       [toggle]
Identify Speakers              [toggle]
Autocapitalize Insert          [toggle]
```

Even if the current app does not support all of these features, do **not** fake features. Only show controls that work. For future-only controls, hide them or mark as “coming later” in a dev branch.

## C. Prompts page

Rename Snippets to Prompts.

Current behavior:

```text
trigger phrase → expansion text
```

New UX:

```text
Prompt trigger: "debug this"
Prompt text: "Analyze the selected/contextual code and identify likely root causes..."
```

This becomes your AI-native superpower.

Example prompt entries:

```text
Trigger: debug brief
Expansion:
Create a debugging brief with observed behavior, expected behavior, suspected causes, files to inspect, and verification steps.

Trigger: refactor plan
Expansion:
Create a safe refactor plan. Preserve behavior, list files to modify, risks, tests, and rollback notes.

Trigger: cursor task
Expansion:
Turn this into a precise Cursor agent instruction with objective, constraints, implementation steps, and acceptance criteria.
```

Same engine. Better meaning. Tiny change, huge leverage.

## D. Vocabulary page

Rename Dictionary to Vocabulary.

Use it for:

```text
Cursor
Claude
WhisperKit
PsstWhisperOS
FastAPI
Supabase
Postgres
RAG
LLMOps
Vercel
```

This gives the local model a practical correction layer for your technical terms.

## E. Notes page

Rename Scratchpad to Notes.

Keep it extremely simple:

```text
Recent notes
Search
Copy
Delete
Send to prompt / copy to clipboard
```

Do not build a Notion clone. Notes should be a landing pad for captured voice thoughts.

---

# 7. Feature stripping strategy

Strip anything that creates maintenance drag without serving the core.

Consider removing or hiding:

* licensing/payment scaffolding
* commercial upgrade references
* unnecessary website purchase copy
* overcomplicated distribution notes
* unfinished pro/paywall logic
* any feature labels that imply cloud or paid plans

Keep Sparkle updater only if you intend to distribute signed builds. Otherwise, defer it.

Your first public repo should say:

> Local-first. Open-source. No cloud. No subscription. Built for fast dictation into any macOS app.

That is clean.

---

# 8. Engineering task plan

## Phase 0: Fork and baseline

```bash
git clone https://github.com/dougwithseismic/psst-free.git PsstWhisperOS
cd PsstWhisperOS
git remote rename origin upstream
git remote add origin git@github.com:<your-user>/PsstWhisperOS.git
git checkout -b rebrand/v0.2
```

Run baseline:

```bash
swift build -c debug
./scripts/dev-build.sh --run
```

Document:

```text
baseline build works
hotkey works
auto-paste works
settings opens
model loads
recording overlay works
```

## Phase 1: Legal and attribution

Keep:

```text
LICENSE
Original attribution in README
Fork notice
Upstream link
```

Add to README:

```text
PsstWhisperOS is a fork/reimagining of Psst Free by dougwithseismic, licensed under MIT.
```

This keeps the karma clean and the repo professional.

## Phase 2: App rename

Update:

```text
Package.swift
executable target name
app bundle display name
Info.plist generation if present
build-app.sh
DMG output name
README title
menu bar labels
about window
settings window title
```

Test after each cluster.

Commit:

```bash
git add .
git commit -m "Rebrand app to PsstWhisperOS"
```

## Phase 3: Terminology rename

Update UI labels:

```text
Scratchpad → Notes
Snippets → Prompts
Dictionary → Vocabulary
```

Keep storage compatibility unless you want to write migration logic.

Commit:

```bash
git commit -m "Rename product concepts for AI-native workflows"
```

## Phase 4: Prompts UX pass

Rename data model only if safe:

```text
SnippetView → PromptsView
Snippet     → PromptSnippet or PromptTemplate
trigger     → trigger phrase
expansion   → prompt text
```

Suggested compromise:

```text
Internal type: Snippet
External label: Prompt
```

This is less risky.

Update empty states:

```text
No prompts yet.
Create trigger phrases that expand into reusable AI instructions.
```

Add examples:

```text
debug brief
refactor plan
cursor task
commit summary
architecture review
```

Commit:

```bash
git commit -m "Reframe snippets as reusable prompts"
```

## Phase 5: UI component extraction

Create:

```text
PsstWhisperOS/Views/DesignSystem/
├── AppTheme.swift
├── SidebarItem.swift
├── SettingsCard.swift
├── SettingsRow.swift
├── PillPicker.swift
├── ToggleRow.swift
└── IconTile.swift
```

This is the 10x move. You do not just repaint screens. You create a tiny design system.

Commit:

```bash
git commit -m "Add lightweight settings design system"
```

## Phase 6: Sidebar redesign

Implement:

* larger sidebar spacing
* rounded selected row
* colored rounded-square icons
* softer background
* clearer hierarchy

Target screenshot feel:

```text
Home
Modes
Vocabulary
Configuration
Sound
Models Library
History
```

Add Prompts/Notes only if you keep separate pages.

Commit:

```bash
git commit -m "Modernize settings sidebar"
```

## Phase 7: Modes page redesign

Make Modes page match screenshot structure:

```text
Header
Preset card
Language/model card
Activation/shortcut card
Advanced settings disclosure
Advanced settings card
```

Do not add fake Superwhisper features unless implemented. Superwhisper supports more advanced concepts like mode-level activation rules and advanced settings, but your fork should only expose what exists or what you implement. ([Superwhisper][4])

Commit:

```bash
git commit -m "Refresh modes settings layout"
```

## Phase 8: Recording overlay polish

Keep it minimal.

Target:

```text
compact floating HUD
rounded pill
mic icon
waveform or pulsing dot
mode name
timer
cancel/stop affordance
```

Do not overbuild.

States:

```text
idle
recording
processing
success
error
```

The overlay is the emotional center of the product. Make it delightful, but not theatrical. A tiny glowing beetle, not a Vegas marquee.

Commit:

```bash
git commit -m "Polish recording overlay states"
```

## Phase 9: README and positioning

New README structure:

```text
# PsstWhisperOS

Local-first voice dictation for macOS.

## What it does
## Why local-first
## Features
## How it works
## Installation
## Building from source
## Roadmap
## Attribution
## License
```

Position it as:

```text
A local-first macOS voice input layer for Cursor, Claude, ChatGPT, Notes, Slack, browsers, and any app with a text field.
```

Avoid claiming Superwhisper parity. Say:

```text
Inspired by modern voice dictation tools, built as a simple open-source local-first alternative.
```

## Phase 10: Release

```bash
swift build -c release
./build-app.sh
```

Create GitHub release:

```text
v0.2.0-rebrand
```

Release notes:

```text
- Rebranded to PsstWhisperOS
- Renamed Snippets to Prompts
- Renamed Scratchpad to Notes
- Renamed Dictionary to Vocabulary
- Refreshed settings UI
- Improved Modes layout
- Preserved local-only transcription behavior
```

---

# 9. Recommended GitHub project structure

Use branches like:

```text
main
dev
rebrand/v0.2
ui/superwhisper-inspired-settings
feature/prompts-rename
feature/notes-rename
```

Use issues:

```text
[Rebrand] Rename app to PsstWhisperOS
[UX] Rename Snippets to Prompts
[UX] Rename Scratchpad to Notes
[UX] Rename Dictionary to Vocabulary
[UI] Modernize sidebar
[UI] Redesign Modes page
[Docs] Rewrite README with attribution
[Build] Update DMG/app bundle names
```

Use labels:

```text
rebrand
ui
docs
local-first
good-first-issue
refactor
```

This makes the repo look intentional, not like a late-night fork goblin with a paintbrush.

---

# 10. What not to build yet

Do **not** add these in v0.2:

* cloud transcription
* account system
* payments
* sync
* meeting transcription
* speaker diarization
* agent orchestration
* Cursor API integration
* memory database
* full prompt marketplace
* complex automation rules

Those can come later.

For now, the win is:

```text
beautiful local dictation app
clean rebrand
AI-native prompt expansion
better settings UX
open-source credibility
```

---

# 11. Version roadmap

## v0.2: Rebrand and UX refresh

* PsstWhisperOS naming
* Notes rename
* Prompts rename
* Vocabulary rename
* sidebar polish
* modes page polish
* README rewrite

## v0.3: Prompt power-user layer

* prompt categories
* prompt import/export JSON
* default AI prompt pack
* Cursor/Claude prompt examples
* prompt search
* copy prompt without recording

## v0.4: Context-lite layer

* selected text capture
* clipboard capture
* active app detection
* app-specific default mode

## v0.5: Voice-first coding mode

* “Cursor Task” mode
* “Debug Brief” mode
* “Refactor Plan” mode
* “Commit Summary” mode
* “PR Review” mode

## v1.0: Local Voice OS

* polished onboarding
* signed release
* stable updater
* clean docs site
* repeatable build/release workflow
* community-ready issues

---

# 12. Final product definition

Your desired version should be:

## **PsstWhisperOS v0.2**

A clean, local-first macOS voice dictation app for AI-native workflows.

It should let users:

* speak into Cursor, Claude, ChatGPT, Notes, Slack, browser fields, and any app
* use local WhisperKit transcription
* trigger recordings with hotkeys
* auto-paste output
* maintain vocabulary corrections
* expand trigger phrases into reusable prompts
* use styles and modes
* review history
* jot voice-captured notes
* trust that the app stays private and simple

The heart of the update is not feature explosion.

It is this:

> **Rename the product around the future use case, polish the UI around trust, and preserve the local-first engine that already works.**

[1]: https://github.com/dougwithseismic/psst-free "GitHub - dougwithseismic/psst-free: Free, open-source macOS speech-to-text. WisperFlow / SuperWhisper alternative — on-device transcription via WhisperKit. No cloud, no subscription. · GitHub"
[2]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/PsstFree/Models/Settings.swift "raw.githubusercontent.com"
[3]: https://raw.githubusercontent.com/dougwithseismic/psst-free/main/PsstFree/Services/TextFormatter.swift "raw.githubusercontent.com"
[4]: https://superwhisper.com/docs/modes/modes "Intro to Modes - Superwhisper"

---