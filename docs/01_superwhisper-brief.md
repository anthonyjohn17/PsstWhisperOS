# Superwhisper Product Brief

> Prompt:
Let's thoroughly study SuperWhisper's product, architecture, and its design system exactly to its pixel-perfect level. Study the documentation meticulously.

https://superwhisper.com/docs/get-started/introduction

I want to understand all the various features that it's providing and what the product experience actually looks like, what are all the core features and all the workflows involved, settings, key settings, the distinction between free and pro tier, everything. I want to understand everything, the onboarding process, cloud versus local. Be detailed and thorough. I'm mainly interested in understanding the design system used because I really like the user experience and I want to use it for building other macOS desktop apps.

---

Superwhisper is worth studying as a **reference-class macOS AI utility**: it is not flashy, but it has that “small, fast, always-there” product quality that makes it feel native rather than bloated.

One caveat: I can analyze the docs, public product pages, and screenshots, but I cannot guarantee **literal pixel-perfect measurements** without inspecting the actual app binary/assets or reproducing screenshots in a design tool. What I *can* do is extract its product architecture, UX patterns, interaction model, and design-system language with high fidelity.

---

# 1. Product thesis

Superwhisper’s core promise is simple:

> Speak naturally, get polished text in any app.

The homepage frames it as voice-to-text that works across Slack, Gmail, Cursor, Notes, and other apps, using a default shortcut shown as **⌥ + Space**. Its docs describe a three-stage flow: dictation, transcription, then smart processing, where AI transforms the raw transcript to match the desired output. ([Superwhisper][1])

The product is not merely “Whisper in a box.” It is closer to:

> **global macOS input layer + mode engine + model router + formatting agent + history/debug console.**

That is why it feels good. The app is not trying to become your writing workspace. It stays out of the way and injects text into the apps you already use.

---

# 2. Core product architecture

The underlying system appears to follow this structure:

```text
Mic / system audio
      ↓
Recording window / hotkey controller
      ↓
Voice model
      ↓
Raw transcript
      ↓
Optional AI language model processing
      ↓
Mode-specific output
      ↓
Clipboard / paste into active app
      ↓
History record + reprocessing
```

The docs explicitly distinguish **voice processing** from **AI processing**. Voice processing transcribes audio first; AI processing then formats, enhances, or transforms the transcript based on the selected mode. Voice-to-Text mode skips AI processing, while Message, Email, Note, Super, Meeting, and Custom modes use AI instructions. ([Superwhisper][2])

That separation is the genius bit. It lets the app support both:

* **fast raw dictation**
* **AI-shaped communication**

without making every use case expensive, slow, or overprocessed.

---

# 3. Main feature map

## Global dictation

Superwhisper works across apps rather than living inside one editor. The homepage explicitly says it works in Slack, Gmail, and “any other site or app.” The free plan includes voice-to-text in any app. ([Superwhisper][1])

This is why it works well with Cursor. Cursor does not need native Whisper integration because Superwhisper becomes the system-level mouthpiece.

## Modes

Modes are the heart of the product. They determine how your voice is processed. Each mode can have different voice models, AI models, language settings, context behavior, and activation rules. ([Superwhisper][2])

Built-in modes include:

| Mode              | Purpose                                                                    |
| ----------------- | -------------------------------------------------------------------------- |
| **Voice to Text** | Fast transcription with basic formatting and no AI post-processing         |
| **Message**       | Cleans speech, fixes grammar/punctuation, makes messages readable          |
| **Email**         | Turns natural speech into email-shaped prose                               |
| **Note**          | Structures spoken thoughts into organized notes                            |
| **Meeting**       | Records/transcribes meetings and summarizes with action items              |
| **Super**         | Context-aware mode that adapts to active app, selected text, and clipboard |
| **Custom**        | User-defined AI instructions and workflow-specific behavior                |

Voice-to-Text is speed-first and recommended for quick inputs or longer transcriptions when AI processing is not needed. Message Mode applies AI processing to remove filler, fix grammar, improve punctuation, and preserve conversational tone. ([Superwhisper][3])

## Super Mode

Super Mode is the most architecturally interesting. It uses context from the active app, selected text, and clipboard to produce smarter output. It can adapt messages to app context, correct app-specific names/terms, format spoken URLs/emails, and preserve tone while improving clarity. ([Superwhisper][4])

For Cursor, Super Mode is especially interesting because it can potentially understand that you are speaking into a coding environment and shape output accordingly. But the docs warn that Super Mode may need stronger cloud language models for complex contextual behavior. ([Superwhisper][4])

## Context awareness

Superwhisper captures three kinds of context:

| Context type            | What it captures                     | Timing                                                |
| ----------------------- | ------------------------------------ | ----------------------------------------------------- |
| **Selected text**       | Highlighted text in active window    | When recording starts                                 |
| **Clipboard**           | Recently copied text                 | Within 3 seconds before recording or during dictation |
| **Application context** | Active input fields, app/window info | After transcription, before AI processing             |

Super Mode has all three context types enabled by default; custom modes can selectively enable them. The docs warn not to enable unnecessary context because too much context can reduce result quality. ([Superwhisper][5])

This is a superb design lesson: **context is treated as a power tool, not a default swamp.**

## File transcription

Superwhisper can transcribe audio and video files. It supports menu-bar transcription, Finder “Open With” flow, and command-line usage via `open /path/to/audiofile.mp3 -a superwhisper`. Recommended formats include MP3, MP4, and mono 16 kHz WAV. ([Superwhisper][6])

## History and reprocessing

History is not just a log. It is a recovery and debugging layer. You can reprocess old dictations with the currently active mode, allowing you to retry failed transcriptions, compare mode outputs, or generate alternate versions without recording again. ([Superwhisper][7])

History also helps debug whether an issue happened in the transcription stage or the AI-processing stage. The hallucination docs explicitly recommend checking history to isolate where unexpected output occurred. ([Superwhisper][8])

## Vocabulary

Vocabulary lets users add custom terms, names, abbreviations, and domain-specific words. The homepage describes this as “Use your own words,” where names and specialized terms are remembered. ([Superwhisper][1])

The docs also show vocabulary can influence language detection, though they caution that too much vocabulary can confuse transcription and contribute to hallucinations. ([Superwhisper][9])

---

# 4. Free vs Pro

The current public pricing says:

| Feature                             | Free | Pro |
| ----------------------------------- | ---: | --: |
| Voice-to-text in any app            |    ✅ |   ✅ |
| Meeting recording/transcription     |    ✅ |   ✅ |
| 100+ languages                      |    ✅ |   ✅ |
| Unlimited small AI models           |    ✅ |   ✅ |
| Custom prompt control               |    ✅ |   ✅ |
| Email support                       |    ✅ |   ✅ |
| Use your own API keys               |    ❌ |   ✅ |
| Unlimited cloud and local AI models |    ❌ |   ✅ |
| Translate any language to English   |    ❌ |   ✅ |
| Transcribe audio/video files        |    ❌ |   ✅ |
| Priority support                    |    ❌ |   ✅ |

The homepage says new users get **15 minutes of Pro feature recording** for free, after which the free tier remains available permanently. Pro is shown at **$8.49/month** with student discount messaging, and the site says Pro can be activated across as many of your own devices as you like. ([Superwhisper][1])

For your use case, if the free local models are accurate enough, you likely do **not** need Pro for basic Cursor dictation. You upgrade when you want better models, cloud models, file transcription, translation, BYOK, or more advanced AI-processing workflows.

---

# 5. Local vs cloud model architecture

Superwhisper separates **voice models** and **language models**.

## Voice models

Voice models convert speech to text. They can be local or cloud-based. Local models run on your machine; cloud models are hosted by Superwhisper or another provider. The docs say local Whisper models are based on OpenAI Whisper and run through `whisper.cpp`. ([Superwhisper][10])

Free local models include:

* Standard
* Standard English
* Nano
* Nano English
* Fast
* Fast English

Pro voice models include larger local models, Superwhisper cloud models, Parakeet, and Deepgram Nova models. ([Superwhisper][10])

## Language models

Language models enhance, format, or transform the transcript after transcription. Superwhisper lists cloud language options from Superwhisper, Anthropic, OpenAI, and Groq, with Pro licensing. ([Superwhisper][11])

This creates a clean two-model pipeline:

```text
Voice model = what did I say?
Language model = how should this be written?
```

That is the product’s intellectual spine.

---

# 6. Onboarding flow

The docs describe onboarding as a guided setup that helps users:

* grant system permissions
* choose transcription language
* select local or cloud AI model with system-optimized suggestions
* configure microphone/audio settings
* complete a first dictation using shortcuts
* verify the setup works ([Superwhisper][12])

The onboarding design appears to be very Apple-like:

* centered setup card
* plain language
* one task per screen
* obvious primary button
* light or dark macOS surface
* permission-driven progression

The product avoids making users understand the full model/mode system before their first success. First it gets them to “speak → text appears.” Then power settings unfold later.

That is exactly how a good pro tool should onboard: **magic first, machinery later.**

---

# 7. The actual product experience

## Default daily workflow

```text
1. Put cursor in any app
2. Press hotkey
3. Speak naturally
4. Stop recording
5. Superwhisper transcribes/processes
6. Text appears in target app
```

The homepage presents this as selecting an app, pressing **⌥ + Space**, and dictating. ([Superwhisper][1])

## Mode workflow

```text
1. Choose mode manually, by shortcut, menu bar, auto-rule, or deep link
2. Dictate
3. Mode applies its voice + AI settings
4. Output gets pasted
```

Mode switching supports keyboard shortcuts, menu bar selection, auto-activation rules, and deep links such as `superwhisper://mode?key=YOUR_MODE_KEY` and `superwhisper://record`. ([Superwhisper][13])

## Power-user automation workflow

```text
Automation tool / Raycast / Alfred / Shortcut
      ↓
Switch mode via deep link
      ↓
Start recording
      ↓
Process with selected mode
      ↓
Paste result
```

The deep-link support is a quiet but major extensibility feature. It turns Superwhisper into a voice subsystem you can route from automations. ([Superwhisper][13])

---

# 8. Settings architecture

Based on docs and screenshots, the app settings are organized around a sidebar model:

* Home
* Modes
* Vocabulary
* Configuration
* Sound
* Models Library
* History

This is a strong macOS pattern: sidebar navigation, content panel, grouped cards, rounded controls, minimal chrome. Public screenshots show a dark translucent macOS-style window with compact sidebar navigation, pill-shaped active states, icon labels, and large rounded setting groups.

## Important settings areas

### Keyboard shortcuts

Superwhisper supports shortcuts for toggling recording, canceling recording, changing modes, and push-to-talk style interaction. The mode-switching docs describe cycling modes from the recording window via a configured shortcut. ([Superwhisper][13])

### Sound settings

Sound settings include microphone configuration, silence removal, automatic microphone volume behavior, sound effects, and volume control. Silence removal is specifically recommended to reduce hallucinations caused by silent periods. ([Superwhisper][8])

### Advanced mode settings

Per-mode advanced options include muting audio while recording, pausing media, recording from system audio, and identifying speakers. System-audio recording is positioned for meetings, video content, interviews, or live audio. Speaker-separated results appear in History segments. ([Superwhisper][2])

### Auto-activation rules

Modes can activate automatically based on apps and websites. The docs warn that once a mode activates for a matched app/site, it cannot be manually overridden in that context and does not automatically return to the previous mode. ([Superwhisper][2])

This is a useful but sharp-edged feature. It is powerful for workflows like:

* Cursor → Voice-to-Text or Coding Prompt mode
* Gmail → Email mode
* Slack → Message mode
* Zoom/Meet → Meeting mode
* Notes/Obsidian → Note mode

---

# 9. Design system analysis

Superwhisper’s UX works because it borrows heavily from modern macOS spatial grammar.

## Visual identity

The visual language is:

* dark-first
* translucent
* low-chrome
* compact
* rounded
* quiet contrast
* icons + labels
* cards inside cards
* minimal gradients
* subtle status indicators

It feels less like a SaaS dashboard and more like a native utility with an AI engine hidden underneath.

## Window system

The app uses two main surfaces:

### Full settings window

A macOS-style app window with:

* left sidebar
* grouped navigation
* active selected pill
* content region
* rounded setting cards
* small iconography
* Pro badge at bottom
* dark gray panels

### Floating recording window

The recording window is the jewel. It has:

* waveform visualization
* stop/cancel controls
* mode indicator
* resize toggle
* mini and regular states
* pill-like compact shape
* red/alert state for recording
* hover-based affordances

Docs describe the recording window as the central hub for dictation, with waveform feedback and a resize toggle between main and mini view.

## Approximate design tokens

Not official tokens, but close inferred values:

```text
Surface background:        #1E1E1F / #242426
Elevated card:             #2E2E30 / #343436
Sidebar selected:          #4A4A4D with soft opacity
Primary text:              #F2F2F3
Secondary text:            #A6A6AA
Muted text:                #77777D
Divider:                   rgba(255,255,255,0.08)
Accent blue:               macOS system blue style
Recording red:             #FF4D4D / coral-red
Success green dot:         #8EF06C
Corner radius small:       8px
Corner radius card:        12–16px
Corner radius pill:        999px
Window radius:             14–18px
Spacing unit:              8px
Card padding:              14–20px
Sidebar item height:       ~32–38px
```

## Layout rhythm

The layout favors:

* **left navigation width:** roughly 150–180 px
* **content cards:** grouped in vertical stacks
* **setting rows:** label left, control right or secondary text below
* **section headers:** compact, not dramatic
* **hero actions:** only when needed

It avoids dense enterprise clutter. Each settings panel feels like a calm drawer of tools.

## Typography

The typography appears to follow native Apple/SF conventions:

* San Francisco style system font
* medium weight for section labels
* regular for descriptions
* small subdued helper copy
* no ornate branding typography inside the app

This is important: the brand expression is in *interaction*, not decorative typography.

## Interaction design

Superwhisper uses a few elegant recurring patterns:

| Pattern                    | Why it works                         |
| -------------------------- | ------------------------------------ |
| **Global hotkey**          | Makes the app feel ambient           |
| **Mini floating recorder** | Keeps attention on the target app    |
| **Waveform feedback**      | Confirms mic capture instantly       |
| **Mode switcher**          | Gives power without opening settings |
| **History reprocess**      | Lets users recover from mistakes     |
| **Auto-paste**             | Removes clipboard friction           |
| **Deep links**             | Opens automation pathways            |
| **Context awareness**      | Makes output feel app-sensitive      |

This is the “little machine with a velvet glove” design pattern.

---

# 10. What to steal ethically for your own macOS apps

Do not copy the brand or exact UI assets. But absolutely study these product principles:

## Product principles to reuse

### 1. Ambient utility, not destination app

The product wins because users do not have to “go to Superwhisper.” It comes to them.

For your apps:

```text
menu bar presence
global shortcut
floating HUD
quick action palette
history/debug console
settings as secondary surface
```

### 2. Modes as programmable behavior

Modes are basically user-facing presets over a processing pipeline. This is reusable for almost any AI desktop app.

Example:

```text
Mode = model + prompt + context rules + output behavior + shortcut
```

That could power:

* coding assistants
* writing tools
* research capture apps
* local knowledge agents
* screenshot-to-action tools
* meeting intelligence apps

### 3. History as both memory and debugger

History is not just “past stuff.” It is observability.

For AI apps, always show:

```text
input
raw model output
processed output
context used
model used
timestamp
reprocess button
copy/export controls
```

### 4. Context as selectable ingredient

Superwhisper does not treat context as one blob. It breaks it into selected text, app context, and clipboard. ([Superwhisper][5])

For your own apps, use context toggles:

```text
Use selected text
Use active app
Use clipboard
Use current file
Use terminal output
Use repo memory
Use recent browser tab
```

### 5. The floating pill is the new command line

The mini recorder is basically a voice command line: tiny, persistent, immediate, low-friction.

For your own app, this could become:

```text
[icon] [status/waveform/text] [mode] [expand]
```

Tiny enough to live over any app. Powerful enough to invoke a full agent.

---

# 11. What Superwhisper gets especially right

## It hides complexity until needed

Beginners get:

```text
press shortcut → speak → text appears
```

Power users get:

```text
modes
models
deep links
custom prompts
context rules
system audio
speaker separation
history reprocessing
```

That is perfect progressive disclosure.

## It separates local privacy from cloud power

Users can stay local for privacy/offline use, but Pro unlocks higher-capability local/cloud models and AI processing. The voice-model docs clearly distinguish local/offline and cloud-hosted models. ([Superwhisper][10])

## It treats dictation as transformation, not transcription

The best part of the product is not that it hears you. It understands that different destinations require different output shapes:

* Slack message
* email
* note
* meeting summary
* selected-text transformation
* raw transcript
* custom workflow

That is the product’s real moat.

---

# 12. Weak spots / design risks

## Context can become confusing

Because selected text, clipboard, and app context are captured at different times, users can get surprising results if they switch windows or copy something during dictation. The docs acknowledge these timing issues. ([Superwhisper][5])

## Auto-activation can feel sticky

The docs warn that auto-activated modes cannot be overridden in that app/site and do not automatically switch back. That could confuse users who expect mode switching to behave like focus modes. ([Superwhisper][2])

## Local models can hallucinate or struggle

The docs mention silence-related hallucinations and recommend silence removal. They also note that local language models may have more limited capabilities and require more specific prompts. ([Superwhisper][8])

## Power is split across many panels

Modes, models, vocabulary, sound, history, configuration: strong architecture, but users may need time to understand the mental model.

---

# 13. Best design-system pattern for your own apps

If you want to build macOS AI apps inspired by Superwhisper, use this skeleton:

```text
App shell
├── Menu bar controller
├── Global hotkey listener
├── Floating HUD
│   ├── idle state
│   ├── recording state
│   ├── processing state
│   ├── success state
│   └── error state
├── Mode engine
│   ├── built-in modes
│   ├── custom modes
│   ├── app/site activation rules
│   └── deep links
├── Context engine
│   ├── selected text
│   ├── clipboard
│   ├── active app
│   ├── files/project context
│   └── optional memory
├── Model router
│   ├── local models
│   ├── cloud models
│   └── BYOK providers
├── Output router
│   ├── paste into app
│   ├── copy to clipboard
│   ├── save to history
│   └── export/share
└── History/observability
    ├── raw input
    ├── processed output
    ├── context used
    ├── model used
    └── reprocess
```

That is the reusable blueprint.

---

# 14. My distilled read

Superwhisper’s design brilliance is not in one screen. It is in the product grammar:

> **tiny trigger → ambient capture → intelligent mode → invisible paste → recoverable history**

That five-step loop is why it feels smooth.

For your own apps, the lesson is:

* make the app global
* make the first action instant
* keep the floating UI tiny
* make modes programmable
* expose model/context choices only when useful
* keep a history/debug panel
* design for “flow recovery,” not just happy paths

Superwhisper is basically a masterclass in building an AI utility that feels native, light, and quietly powerful.

[1]: https://superwhisper.com/ "Superwhisper — AI Voice to Text for macOS, Windows & iOS | Superwhisper"
[2]: https://superwhisper.com/docs/modes/modes "Intro to Modes - Superwhisper"
[3]: https://superwhisper.com/docs/modes/voice "Voice to Text - Superwhisper"
[4]: https://superwhisper.com/docs/modes/super "Super - Superwhisper"
[5]: https://superwhisper.com/docs/common-issues/context "Context Awareness - Superwhisper"
[6]: https://superwhisper.com/docs/get-started/transcribe-files "File Transcription - Superwhisper"
[7]: https://superwhisper.com/docs/get-started/transcribe-history "Reprocess from History - Superwhisper"
[8]: https://superwhisper.com/docs/common-issues/hallucinations "Hallucinations & Unexpected Results - Superwhisper"
[9]: https://superwhisper.com/docs/common-issues/language-detection "Language Detection - Superwhisper"
[10]: https://superwhisper.com/docs/models/voice "Voice - Superwhisper"
[11]: https://superwhisper.com/docs/models/language "Language - Superwhisper"
[12]: https://superwhisper.com/docs/get-started/introduction "Introduction - Superwhisper"
[13]: https://superwhisper.com/docs/modes/switching-modes "Switching Modes - Superwhisper"

---

