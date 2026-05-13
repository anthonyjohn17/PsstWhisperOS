# PsstWhisperOS v0.2 — PRD & Technical Specification

> **Document type:** Product Requirements Document + Technical Specification
> **Version:** 0.2 (Rebrand & UX Refresh)
> **Author:** John Anthony
> **Date:** May 12, 2026
> **Status:** Draft
> **Predecessor docs:** `01_superwhisper-brief.md`, `02_PsstFree.md`, `03_PsstWhisperOS.md`

---

## Problem Statement

PsstWhisperOS is a fork of Psst Free that has been rebranded and repositioned as a local-first macOS voice layer for AI-native work. The initial fork (v1.0.x) preserved the original Psst Free feature set with basic renaming. However, the current version still carries stale terminology (Scratchpad, Snippets, Dictionary references in some UI paths), uses a functional but visually plain settings UI, lacks a cohesive design system, and does not yet reflect the Superwhisper-inspired UX polish described in the project vision.

The goal of v0.2 is to complete the product-level transformation: finish the terminology rename, introduce a lightweight design system, modernize the settings UI to match the target "soft native utility" aesthetic, add a Dark/Light mode toggle, and position the codebase for the roadmap described in `03_PsstWhisperOS.md` (context-lite layer, voice-first coding modes, onboarding, v1.0 release).

Users experience friction because:

1. The sidebar labels and internal naming still mix old Psst Free terminology with the new PsstWhisperOS identity, creating cognitive dissonance.
2. The settings UI is functional but does not feel like a polished, trustworthy macOS utility — it lacks the rounded-card, soft-surface, icon-led sidebar aesthetic that modern macOS tools (Superwhisper, Arc, Raycast) have normalized.
3. There is no appearance toggle — the app inherits system appearance but gives users no local override to switch between dark and light mode within the app.
4. The prompts concept (renamed from snippets) is underexplained in the UI — the empty state and hero banner still use snippets-era copy.
5. The design system is implicit (inline SwiftUI modifiers) rather than extracted into reusable components, making future UI work slow and inconsistent.

---

## Solution

Deliver PsstWhisperOS v0.2 as a focused product pass that:

1. **Completes the terminology rename** — all user-facing labels, empty states, help text, and documentation reflect the new naming: Prompts (not Snippets), Notes (not Scratchpad), Vocabulary (not Dictionary).
2. **Introduces a lightweight SwiftUI design system** — extracted `AppTheme`, `SidebarItem`, `SettingsCard`, `SettingsRow`, `ToggleRow`, and `PillPicker` components that encode the target visual language.
3. **Modernizes the settings window** — new sidebar with colored rounded-square icons, soft selected state, and breathing room; content panels use rounded cards with grouped settings.
4. **Adds a Dark/Light mode toggle** — a user-facing appearance switch in the sidebar footer (or Configuration panel) that lets users override system appearance for the settings window and recording overlay.
5. **Polishes the recording overlay** — minor refinements to the floating HUD states (recording, processing, model loading) to align with the design system colors and radii.
6. **Updates the README and docs** — reflect the new UI, new feature (appearance toggle), and updated screenshots.

The core transcription loop, hotkey system, audio engine, WhisperKit integration, clipboard manager, and text formatter are **not modified** in this release. The upgrade is a thin, high-leverage product pass over the presentation layer.

---

## User Stories

1. As a daily PsstWhisperOS user, I want all sidebar labels and page titles to use consistent naming (Vocabulary, Prompts, Notes, Styles, Modes), so that the app feels intentionally designed and not like a half-renamed fork.
2. As a macOS user who prefers light mode, I want the settings window and recording overlay to feel native and polished in light mode, so that the app does not look like a dark-only afterthought.
3. As a macOS user who prefers dark mode, I want the app to look equally polished in dark mode, so that I get the same quality experience regardless of system appearance.
4. As a user who switches between light and dark mode based on context (e.g., daytime vs nighttime coding), I want a toggle inside PsstWhisperOS to override the system appearance for just this app, so that I can control the look independently of macOS settings.
5. As a new user opening Settings for the first time, I want the sidebar to feel calm, organized, and visually inviting with colored icons and clear grouping, so that I feel confident the app is well-made.
6. As a user navigating settings, I want each settings panel to use rounded cards that group related controls, so that the information hierarchy is immediately clear without reading every label.
7. As a user creating prompts (formerly snippets), I want the empty state to explain that prompts are trigger phrases that expand into reusable AI instructions, so that I understand the feature's value before adding my first entry.
8. As a user who has existing snippets data from a previous version, I want my data to be preserved after the upgrade without any manual migration, so that nothing breaks silently.
9. As a user viewing the Modes page, I want the layout to use grouped cards (Preset, Language/Model, Activation, Advanced), so that mode configuration feels structured rather than a flat list.
10. As a user who opens the Vocabulary page, I want the page title to say "Vocabulary" (not "Dictionary"), so that the naming matches Superwhisper-style conventions and the rest of the app.
11. As a user who opens the Notes page, I want the page title to say "Notes" (not "Scratchpad"), so that the feature feels more permanent and intentional.
12. As a developer extending the UI, I want reusable SwiftUI components (`SettingsCard`, `SidebarItem`, `SettingsRow`, `ToggleRow`, `PillPicker`), so that future settings panels are consistent without copy-pasting style code.
13. As a user looking at the recording overlay, I want the pill shape, colors, and typography to feel cohesive with the settings window, so that the app feels like one unified product.
14. As a user reading the README, I want the feature list and screenshots to accurately represent the current version, so that my expectations match reality.
15. As a user toggling dark/light mode, I want the change to apply immediately without restarting the app, so that the experience feels responsive and native.
16. As a user, I want the Dark/Light toggle to be easily accessible in the settings sidebar (left panel footer area), so that I can switch appearance with one click from any settings page.
17. As a power user, I want the option to leave appearance set to "System" (auto) so that the app follows my macOS appearance preference by default without requiring manual toggling.
18. As a user exploring modes, I want the built-in mode descriptions to use clear, action-oriented language, so that I can quickly understand what each mode does without trial and error.
19. As a user with many prompts, I want the prompts page to support search and sorting, so that I can find specific triggers quickly.
20. As a developer building a new settings panel in the future, I want `AppTheme` to define all shared design tokens (colors, radii, spacing, typography weights) in one place, so that I never hardcode visual values.

---

## Implementation Decisions

### Module Map

The following modules will be created or modified. The design intentionally extracts a **design system module** as a deep module — it encapsulates visual tokens and reusable components behind simple interfaces that rarely change, even as individual settings panels evolve.

#### New Modules

| Module | Role | Interface |
|--------|------|-----------|
| **AppTheme** | Central design token store. Defines colors, corner radii, spacing, typography, and appearance state. | Static properties for tokens. `@AppStorage`-backed `appearanceMode` enum (`system`, `light`, `dark`). A computed `NSAppearance?` property that views use. |
| **SidebarItemView** | Reusable sidebar row component. | `init(icon: String, iconColor: Color, label: String, isSelected: Bool)`. Renders colored rounded-square icon, label, and selection background. |
| **SettingsCard** | Rounded card container for grouped settings. | `init(@ViewBuilder content: () -> Content)`. Wraps content in a rounded rectangle with theme padding, fill, and optional border. |
| **SettingsRow** | Standard row inside a `SettingsCard`. | `init(title: String, subtitle: String?, @ViewBuilder trailing: () -> Trailing)`. Label left, control right, optional description below. |
| **ToggleRow** | Specialized `SettingsRow` with a toggle. | `init(title: String, subtitle: String?, isOn: Binding<Bool>)`. |
| **PillPicker** | Capsule-shaped segmented picker. | `init(selection: Binding<T>, options: [T])` where `T: Hashable & CustomStringConvertible`. |
| **AppearanceMode** | Enum: `.system`, `.light`, `.dark`. Codable, stored in UserDefaults. | `var nsAppearance: NSAppearance?` computed property. `.system` returns `nil` (inherit), `.light` returns `NSAppearance(named: .aqua)`, `.dark` returns `NSAppearance(named: .darkAqua)`. |

#### Modified Modules

| Module | Changes |
|--------|---------|
| **SettingsView** | Replace `SettingsTab` enum labels and icons with new naming. Replace inline `SidebarRow` with `SidebarItemView`. Add appearance toggle in sidebar footer. Apply `AppTheme` tokens. Wire `appearance` override onto the settings `NSWindow`. |
| **SettingsTab enum** | Update `.vocabulary` label from "Dictionary" to "Vocabulary". Update `.snippets` label from "Snippets" to "Prompts". Update `.scratchpad` label from "Scratchpad" to "Notes". Update icons to colored rounded-square SF Symbols. |
| **SnippetsSettingsView** | Rename page title from "Snippets" to "Prompts". Update hero banner copy. Update empty state copy. Update "Add new" button label to "New Prompt". Update field labels from "Trigger" / "Expansion" to "Prompt Trigger" / "Prompt Text". |
| **ScratchpadSettingsView** | Rename page title from "Scratchpad" to "Notes". Update empty state copy. |
| **VocabularySettingsView** | Confirm page title already says "Vocabulary" (verify — original Psst Free used "Dictionary"; some banner copy may reference old name). Update any stale copy. |
| **HomeSettingsTab** | Restyle using `SettingsCard` components. Update the "Get Started" cards to use new design system. |
| **ConfigurationSettingsView** | Add an "Appearance" section with a three-way segmented picker: System / Light / Dark. Persist to `UserDefaults` via `AppTheme.appearanceMode`. |
| **ModeEditorView** | Restyle using grouped `SettingsCard` layout (Preset card, Language/Model card, Activation card, Advanced disclosure card). |
| **RecordingOverlayView** | Apply `AppTheme` colors to the model-loading pill background. Ensure overlay respects the app-level appearance override. |
| **PsstWhisperOSApp** | In `SettingsWindowController.open()`, apply `NSWindow.appearance` based on `AppTheme.appearanceMode`. Observe changes to re-apply without restart. |
| **StorageKeys** | Add `static let appearanceMode = "appearanceMode"`. |
| **README.md** | Update feature list (add Dark/Light mode toggle), update screenshot, update project layout if new files added. |

### Architectural Decisions

1. **Appearance override via `NSWindow.appearance`**: Rather than injecting `@Environment(\.colorScheme)` overrides throughout the view hierarchy, the appearance mode is applied at the `NSWindow` level. Setting `window.appearance = NSAppearance(named: .darkAqua)` or `.aqua` makes all SwiftUI views inside inherit the correct scheme automatically. Setting `window.appearance = nil` reverts to system default. This is the standard macOS pattern and requires zero changes to individual views.

2. **Three-state toggle, not a binary switch**: The appearance control is a segmented picker with three options — System (default), Light, Dark. "System" means `nil` appearance (inherit from macOS). This avoids the common UX trap where users lose the ability to follow system appearance after toggling manually.

3. **Design system as extracted views, not a framework**: The design system components live in a `Views/DesignSystem/` subdirectory alongside existing views. They are plain SwiftUI structs, not a separate package or target. This keeps the build simple (single SPM executable target) while providing reuse.

4. **Storage key compatibility**: The `snippets` UserDefaults key is preserved for data. The UI label changes to "Prompts" but the underlying storage key remains `snippets` to avoid data migration. Same for `scratchpadNotes` (Notes) and `vocabularyEntries` (Vocabulary). A migration path can be added later if key renaming is ever needed.

5. **No new dependencies**: The v0.2 upgrade adds zero new Swift packages. All visual changes are achieved with SwiftUI primitives and SF Symbols.

6. **Sidebar icon style**: Each sidebar item gets a colored SF Symbol inside a rounded square background. This mirrors the iOS/macOS Settings app pattern. Icon colors are defined in `AppTheme` as a per-tab color map.

7. **Recording overlay appearance**: The `OverlayPanel` (NSPanel) that hosts `RecordingOverlayView` also gets the appearance override applied, so the overlay and settings window stay visually consistent regardless of system theme.

### Design Token Specification

```
// Light mode tokens
Surface background:         Color(nsColor: .windowBackgroundColor)
Sidebar background:         Color.gray.opacity(0.04)
Sidebar selected fill:      Color.accentColor.opacity(0.10)
Card fill:                  Color(nsColor: .controlBackgroundColor)
Card border:                Color.gray.opacity(0.10)
Card corner radius:         12
Sidebar item corner radius: 10
Sidebar icon bg radius:     8
Sidebar icon bg size:       28x28
Primary text:               Color.primary
Secondary text:             Color.secondary
Muted text:                 Color.secondary.opacity(0.6)
Spacing unit:               8
Card padding:               16
Sidebar width:              200
Window size:                820 x 580

// Dark mode tokens (same semantic names, SwiftUI resolves automatically
// when NSWindow.appearance is set — no manual dark palette needed)

// Accent colors per sidebar tab
Home:           .orange
Vocabulary:     .blue
Prompts:        .green
Styles:         .purple
Notes:          .yellow
Configuration:  .gray
Sound:          .pink
Models:         .indigo
History:        .teal
```

### Appearance Toggle Placement

The Dark/Light mode toggle is placed in **two locations** for maximum accessibility:

1. **Sidebar footer** — A compact three-segment pill picker (`☀️` / `Auto` / `🌙`) pinned to the bottom of the sidebar, visible from any settings page. This is the primary quick-access point.
2. **Configuration page** — A full "Appearance" section with the same three-way picker and a brief description. This is the discoverable settings-panel location.

Both controls bind to the same `@AppStorage(StorageKeys.appearanceMode)` value, so they stay in sync.

### File Organization

```
Sources/PsstWhisperOS/
├── Views/
│   ├── DesignSystem/
│   │   ├── AppTheme.swift           // Tokens, appearance mode enum, color maps
│   │   ├── SidebarItemView.swift    // Reusable sidebar row
│   │   ├── SettingsCard.swift       // Rounded card container
│   │   ├── SettingsRow.swift        // Label + trailing control row
│   │   ├── ToggleRow.swift          // Toggle-specific row
│   │   └── PillPicker.swift         // Capsule segmented control
│   ├── SettingsView.swift           // Modified: new sidebar, footer toggle
│   ├── SnippetsSettingsView.swift   // Modified: rename to Prompts UX
│   ├── ScratchpadSettingsView.swift // Modified: rename to Notes UX
│   ├── VocabularySettingsView.swift // Modified: verify/update copy
│   ├── ConfigurationSettingsView.swift // Modified: add Appearance section
│   ├── ModeEditorView.swift         // Modified: grouped card layout
│   ├── HomeSettingsTab (in SettingsView.swift) // Modified: use SettingsCard
│   ├── RecordingOverlayView.swift   // Modified: theme alignment
│   └── ... (other views unchanged)
├── Models/
│   ├── StorageKeys.swift            // Modified: add appearanceMode key
│   └── ... (other models unchanged)
├── PsstWhisperOSApp.swift           // Modified: appearance on NSWindow
└── ... (services unchanged)
```

---

## Testing Decisions

### What Makes a Good Test Here

Since this release is primarily a UI/presentation layer pass, the highest-value tests are **snapshot/visual regression tests** and **behavior preservation tests** — not unit tests on view layout. However, no test suite currently exists in this codebase.

Given the project's current state (no tests, no CI, no linter), the pragmatic testing strategy is:

### Manual Verification Checklist

Each item must be verified before release:

| Area | Verification |
|------|-------------|
| **Terminology** | All sidebar labels read: Home, Vocabulary, Prompts, Styles, Notes, Configuration, Sound, Models, History. No instances of "Snippets", "Scratchpad", or "Dictionary" in any user-facing text. |
| **Appearance toggle** | Toggle in sidebar footer and Configuration page. "System" follows macOS. "Light" forces light. "Dark" forces dark. Changes apply immediately without restart. |
| **Appearance persistence** | Close and reopen settings. Appearance mode persists. |
| **Overlay appearance** | Recording overlay respects the same appearance override as settings. |
| **Data preservation** | Existing prompts (snippets), notes (scratchpad), vocabulary, history, modes, and settings survive the upgrade with no data loss. |
| **Sidebar interaction** | Clicking each sidebar item navigates to the correct panel. Selected state highlights correctly. |
| **Card layout** | Settings panels use rounded cards. Controls are aligned. No clipping or overflow. |
| **Prompts page** | Empty state copy references "prompts" and "trigger phrases." Hero banner (if shown) is updated. Add/edit/delete prompts works. |
| **Notes page** | Empty state says "No notes yet." Create/edit/delete/search works. |
| **Home page** | Get Started cards display if no history. Recent timeline displays if history exists. |
| **Modes page** | Cards are grouped. Preset/mode switching works. Custom mode create/edit works. |
| **Build** | `swift build -c debug` succeeds. `./scripts/dev-build.sh` produces a working .app. `./build-app.sh` produces a DMG. |
| **Hotkey** | Hold-to-record and toggle-to-record both work after the UI changes (no regressions). |
| **Auto-paste** | Text appears in the frontmost app after recording. |

### Modules Worth Testing (Future)

If a test suite is introduced in a later version:

- **AppTheme.AppearanceMode** — unit test the `nsAppearance` computed property for all three cases.
- **StorageKeys round-trip** — verify that reading/writing appearance mode to UserDefaults works correctly.
- **TextFormatter** — the formatting pipeline already has enough complexity to warrant unit tests (vocabulary replacement, snippet expansion, mode formatting, style application). This is the highest-value test target in the codebase.
- **SidebarItem/SettingsCard** — snapshot tests if snapshot testing infrastructure is added.

---

## Out of Scope

The following are explicitly **not** part of v0.2:

1. **Cloud transcription** — no server-side model routing, no API key management, no BYOK.
2. **Context awareness** — no selected text capture, no clipboard capture, no active app detection.
3. **AI post-processing** — no language model (LLM) rewriting of transcription output. The TextFormatter remains regex/template-based.
4. **Meeting mode / system audio** — no recording from system audio, no speaker diarization.
5. **Onboarding flow** — no guided first-run wizard. The Home page "Get Started" section serves as a lightweight substitute.
6. **Account system / licensing** — no login, no payment, no license validation changes. The existing `LicenseManager` is left as-is.
7. **Auto-update system** — Sparkle integration exists but is not modified.
8. **File transcription** — no drag-and-drop or "Open With" audio file support.
9. **Deep links / URL schemes** — no `psstwhisperos://` URL handler.
10. **Automated test suite** — no XCTest, no snapshot tests, no CI pipeline. Testing is manual for this release.
11. **iOS / cross-platform** — macOS only.
12. **Prompt categories / import-export** — prompts remain a flat list. Categorization and JSON import/export are roadmap items for v0.3.
13. **History reprocessing** — history remains read-only. Reprocess-with-different-mode is a future feature.
14. **Recording overlay redesign** — only minor color/radius alignment. The fluid wave animation and layout are preserved.
15. **New SF Symbol icon set or custom icons** — uses existing SF Symbols with colored backgrounds.

---

## Implementation Phases

### Phase 1: Design System Foundation

Create `Views/DesignSystem/` with `AppTheme`, `AppearanceMode`, and the five reusable components. Define all design tokens. This is the foundation that every subsequent phase depends on.

**Deliverable:** Components compile and render in isolation. `AppTheme.appearanceMode` reads/writes UserDefaults.

### Phase 2: Appearance Toggle

Add `appearanceMode` to `StorageKeys`. Wire the three-way picker into `ConfigurationSettingsView`. Apply `NSWindow.appearance` override in `SettingsWindowController`. Apply to the overlay panel. Add the sidebar footer picker.

**Deliverable:** User can switch appearance. Change is immediate and persists.

### Phase 3: Sidebar Modernization

Replace the current `SidebarRow` with `SidebarItemView`. Update `SettingsTab` enum with new labels, icons, and per-tab accent colors. Adjust sidebar spacing, padding, and selected state.

**Deliverable:** Sidebar matches the target "soft native utility" aesthetic with colored icons.

### Phase 4: Terminology Rename Completion

Update all user-facing strings:
- SnippetsSettingsView → "Prompts" title, updated hero banner, updated empty state, updated field labels.
- ScratchpadSettingsView → "Notes" title, updated empty state.
- VocabularySettingsView → verify all copy says "Vocabulary" (not "Dictionary").
- HomeSettingsTab → verify "Get Started" card labels match new naming.

**Deliverable:** Zero instances of "Snippets", "Scratchpad", or "Dictionary" in user-facing UI.

### Phase 5: Settings Panel Restyling

Apply `SettingsCard` and `SettingsRow` to:
- HomeSettingsTab (Get Started cards, recent timeline)
- ModeEditorView (grouped card layout)
- ConfigurationSettingsView (shortcuts card, behavior card, appearance card)
- SoundSettingsView
- All other settings panels as needed

**Deliverable:** Each settings panel uses the design system components. Visual consistency across all pages.

### Phase 6: Recording Overlay Alignment

Apply `AppTheme` colors to the model-loading pill. Ensure the overlay panel respects appearance override. Minor radius/color adjustments.

**Deliverable:** Overlay feels visually cohesive with the settings window.

### Phase 7: Documentation and Release

Update README.md with:
- New feature: Dark/Light mode toggle
- Updated feature list reflecting renamed features
- Updated project layout showing `Views/DesignSystem/`
- Screenshot placeholder (to be replaced with actual screenshot)

Update `CLAUDE.md` if the design system adds important architectural context.

Tag release as `v0.2.0`.

**Deliverable:** README is accurate. Docs are current. Release is tagged.

---

## Version Roadmap Context

This PRD covers **v0.2 only**. For reference, the planned trajectory from `03_PsstWhisperOS.md`:

| Version | Focus |
|---------|-------|
| **v0.2** | Rebrand completion, UX refresh, design system, Dark/Light toggle **(this PRD)** |
| v0.3 | Prompt power-user layer (categories, import/export, default pack, search) |
| v0.4 | Context-lite layer (selected text, clipboard, active app, app-specific modes) |
| v0.5 | Voice-first coding modes (Cursor Task, Debug Brief, Refactor Plan, Commit Summary) |
| v1.0 | Polished onboarding, signed release, stable updater, docs site, community-ready |

---

## Further Notes

### On the "Prompts" Rename

The snippets-to-prompts rename is not merely cosmetic. It repositions the feature from "text expansion utility" to "AI instruction layer." The same engine (trigger phrase → expansion text) becomes the foundation for v0.3's prompt categories and v0.5's voice-first coding modes. The v0.2 rename plants the seed; later versions grow it.

Example prompt entries to ship as defaults or document in README:

| Trigger | Prompt Text |
|---------|-------------|
| `debug brief` | Create a debugging brief with observed behavior, expected behavior, suspected root causes, files to inspect, and verification steps. |
| `refactor plan` | Create a safe refactor plan. Preserve behavior, list files to modify, risks, tests, and rollback notes. |
| `cursor task` | Turn this into a precise Cursor agent instruction with objective, constraints, implementation steps, and acceptance criteria. |
| `commit summary` | Write a concise git commit message summarizing the changes described above. |
| `architecture review` | Review the described architecture. Identify strengths, risks, missing components, and recommendations. |

### On Dark/Light Mode

The three-state approach (System / Light / Dark) is deliberate. Many macOS apps ship with only a binary toggle and lose the ability to follow system appearance. The "System" default means the app inherits macOS behavior out of the box — users who want to override only need to touch it once.

The `NSWindow.appearance` approach is preferred over `@Environment(\.colorScheme)` overrides because:
- It requires a single point of application (the window), not per-view injection.
- All standard SwiftUI controls and system colors automatically adapt.
- It matches how Apple's own apps (System Preferences, Xcode) handle per-window appearance.

### On the Design System Scope

The design system is intentionally minimal — six components and one token file. It is not a general-purpose design framework. It encodes exactly the visual language needed for PsstWhisperOS settings panels and nothing more. If future versions need more components (e.g., toast notifications, modal sheets, progress bars), they are added incrementally to the same `DesignSystem/` directory.

### On the Subagent-Driven Development Approach

Per the skills folder's `subagent-driven-development` workflow, this PRD is structured so that each implementation phase is an independent task suitable for dispatch to a fresh implementation subagent. Phases 1-7 have clear inputs, outputs, and verification criteria. The dependency chain is:

```
Phase 1 (foundation) → Phase 2 (appearance) → Phase 3 (sidebar) → Phase 4 (rename)
                                                                  → Phase 5 (restyle)
                                                                  → Phase 6 (overlay)
                                                                  → Phase 7 (docs)
```

Phases 4, 5, and 6 can run in parallel after Phase 3 is complete. Phase 7 runs last.

---

## Acceptance Criteria Summary

v0.2 is complete when:

- [ ] All sidebar labels match: Home, Vocabulary, Prompts, Styles, Notes, Configuration, Sound, Models, History
- [ ] Zero user-facing instances of "Snippets", "Scratchpad", or "Dictionary"
- [ ] Dark/Light/System appearance toggle works in sidebar footer and Configuration page
- [ ] Appearance change is immediate (no restart) and persists across app launches
- [ ] Recording overlay respects appearance override
- [ ] Settings sidebar uses colored rounded-square icons with soft selection state
- [ ] Settings panels use rounded-card layout via `SettingsCard` component
- [ ] `Views/DesignSystem/` directory exists with `AppTheme`, `SidebarItemView`, `SettingsCard`, `SettingsRow`, `ToggleRow`, `PillPicker`
- [ ] Existing user data (prompts, notes, vocabulary, history, modes, settings) is preserved
- [ ] `swift build -c debug` succeeds
- [ ] `./scripts/dev-build.sh` produces a working .app
- [ ] Hold-to-record and toggle-to-record work without regression
- [ ] Auto-paste works without regression
- [ ] README.md is updated with new features and accurate project layout
