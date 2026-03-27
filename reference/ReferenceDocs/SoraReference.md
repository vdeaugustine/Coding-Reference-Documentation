# Mastering Sora 2 Prompting: A Complete Technical & Narrative Playbook

> Sora 2 is OpenAI’s latest text-to-video (with audio) model focused on **more accurate physics**, **sharper realism**, **stronger steerability**, and **synchronized dialogue/SFX**. Treat it like a camera you direct with words—use precise film grammar, structure, and iteration to get predictable results. ([OpenAI][1])

---

## 1) Core Principles (that actually move the needle)

* **Be concrete, not poetic.** Name **subject, setting, time, camera, motion, lighting, style**. If you’re vague, Sora fills gaps unpredictably.
* **Structure over soup.** Use a **shot-list / storyboard** with timestamps. Sora 2 follows direction with higher fidelity when events are “anchored” in time. ([OpenAI][2])
* **Film grammar works.** Shot types, angles, lenses, and camera moves are reliably understood and help control framing and motion. ([Skywork][3])
* **Iterate methodically.** Change **one variable at a time** (lighting, lens, motion) and keep a library of winning fragments (prompt modules). ([Skywork][4])
* **Right detail, right place.** Use **physics-aware cues** (weight, friction, elasticity); keep character descriptors **short and consistent**; rely on **reference stills** for look-locking. ([OpenAI][2])

---

## 2) The Shot-List Framework (your default prompt skeleton)

Include these six elements (one line each; expand as needed):

1. **Subject / Action** — who/what and doing what
2. **Setting / Time** — place, time of day, weather/atmosphere
3. **Camera & Lens** — shot type (WS/MS/CU), angle, focal length (24/35/85 mm)
4. **Motion Path** — camera move + speed (dolly, crane, gimbal, handheld push-in; pan/tilt)
5. **Lighting / Texture** — key/fill/ambient, golden hour, film grain, reflections, materials
6. **Tone / Style** — cinematic/doc/anime/hyperreal; palette (“muted earth tones”, “neon”)

This structure mirrors Sora 2’s improved steerability and helps it stick to your plan. ([OpenAI][2])

**Example (single-shot):**

> *Rainy neon alley, Tokyo, night.* **MCU** on courier adjusting helmet. **35 mm, eye-level.** **Handheld push-in (slow).** **Wet asphalt** with mirror reflections; **soft practicals** and light mist. **Moody, synthwave palette.**

---

## 3) Cinematography Tokens That Consistently Steer Sora 2

* **Shot types:** establishing / wide / medium / close-up / extreme close-up
* **Angles:** low / high / eye-level / Dutch / bird’s-eye
* **Lenses:** 24 mm wide, 35 mm standard, 85 mm portrait
* **Moves:** dolly in/out, crane up/down, gimbal track, handheld push-in, pan/tilt
* **Composition:** rule of thirds, leading lines, foreground framing

These tokens are repeatedly cited by creators as reliable steering language and align with Sora 2’s “follows user direction with high fidelity” claim. ([Skywork][3])

---

## 4) Physics-Aware Prompting (realism without guessing)

Sora 2 improves physical plausibility—objects keep momentum, collisions look believable, and fluid/wind effects read better when described clearly. Use **material + force** language:

* **Materials:** rigid/soft, wet/dry, heavy/light, elastic/brittle
* **Forces:** gravity/float/buoyancy; wind (gusty/steady); drag/resistance (underwater/smoke)
* **Interactions:** bounce pattern, skid/slide, splash, wobble, deformation
* **Failure modeling:** “misses the catch,” “ragdoll stumble,” “wheels wobble,” “regains balance”

These cues help Sora 2’s physics and motion rendering. Avoid numeric parameters; think **qualitative physics**. ([OpenAI][2])

**Example (action micro-beat):**

> *A skateboarder attempts a kickflip; board clips the curb and tumbles; wheels wobble; skater stumbles then regains balance; camera tracks right at ankle height.*

---

## 5) Audio & Timing: Dialogue, Ambience, SFX, Music

Sora 2 generates **dialogue, SFX, and ambient audio** aligned to visuals. Prompt with **timestamps** and **roles** to get tighter sync and tone:

* **Dialogue:** `0.7s: (whisper, urgent, British accent) “We’re late—move.”`
* **Ambience (amb):** `rain on tin roofs, distant traffic, room tone`
* **SFX:** `muffled train horn @3s, footsteps on wet gravel`
* **Music:** `low synth pulse, slow tempo, subtle crescendo 2–8s`

Treat frame-perfect sync as a creative goal (results are strong but not guaranteed). ([OpenAI][2])

---

## 6) Character & Scene Consistency (10+ shots without drift)

* **Reference board first.** Generate a multi-angle stills sheet of the protagonist.
* **Use the same anchor tokens** every time (hair, wardrobe silhouette, signature prop).
* **Storyboard timestamps:** “Cut back to main character (ref_03). Same raincoat, same alley practicals.”
* **Keep descriptors lean** (3–5 essential traits); wall-of-text bios invite drift.
* **Lock lighting + palette** across shots to stabilize look.

This workflow mirrors how creators are keeping continuity as Sora 2 boosts cross-shot consistency. ([OpenAI][2])

---

## 7) Multi-Shot Storytelling: Build Sequences, Not One-offs

* **Temporal anchors:** `0s/3s/7s` to mark beats.
* **Transitions:** call cuts explicitly (hard cut, match cut, crossfade, whip pan).
* **World state persistence:** reference on-screen changes (“door remains ajar,” “broken glass visible”).
* **Coverage:** shoot it like a set—WS for geography, MS for action, CU for emotion; cut between them.

Sora 2’s increased controllability makes storyboarded sequences far more reliable than “one long paragraph.” ([OpenAI][2])

---

## 8) Style & Mood Control

Pair **visual medium** with **palette** and **lighting**:

* **Medium:** cinematic / documentary / hyperrealistic / anime-inspired
* **Palette:** warm golden hour / cool blue hour / neon / muted earth tones
* **Lighting:** soft diffused / harsh directional / ambient fill / chiaroscuro
* **Texture:** film grain, halation, lens flares, fog/dust motes

These tokens consistently map to look & feel in creator guides and reviews of Sora 2’s expanded stylistic range. ([Skywork][3])

---

## 9) Common Pitfalls → Fixes (quick table)

| Pitfall                                        | How to Fix                                                                                                         |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **Overloaded prompt** (too many ideas at once) | Break into multiple shots; keep 1–2 primary ideas per clip; iterate variables one at a time. ([Skywork][4])        |
| **Crowds feel cloned / uncanny**               | Reduce crowd scale; shoot tighter; stagger motion directions; intercut WS→MS/CU. ([Skywork][4])                    |
| **Hand–object micro-interactions deform**      | Favor implied action; cut to result; keep hands off-camera or partially framed; insert cutaways. ([Skywork][4])    |
| **Lip-sync slightly off**                      | Timestamp dialogue; reduce simultaneous SFX; shorten lines; re-generate just the dialogue beat. ([Venturebeat][5]) |
| **Style drift across shots**                   | Reuse identical anchor tokens + reference image ID; fix lighting/palette language verbatim. ([OpenAI][2])          |
| **Glitches / extra limbs / flicker**           | Add negative cues: “avoid glitching, no extra limbs, no text overlays, no flicker.” Keep it short. ([Skywork][3])  |

---

## 10) Prompt Grammar Cheat-Sheet (copy/paste blocks)

**Timestamp beats**

```
0s: [wide establishing, describe setting]
3s: [cut to MS/CU, action beat]
7s: [insert/POV, reveal detail]
```

**Camera & lens**

```
[WS/MS/CU], [low/high/eye-level], [24mm/35mm/85mm]
Move: dolly in/out | crane up/down | gimbal tracking | handheld push-in | pan/tilt (slow/fast)
```

**Physics cues**

```
Materials: [wet/dry, heavy/light, elastic/brittle]
Forces: [gravity/buoyancy, wind (gusty/steady), drag/resistance]
Interactions: [bounce, skid, splash, wobble, deformation]
Failure: [missed catch, ragdoll stumble, wheels wobble]
```

**Audio block**

```
dialogue @2.0s: (whisper, urgent, [accent]) "…"
amb: [room tone | rain on metal roofs | distant traffic]
sfx: [footsteps on wet gravel @1.2s, train horn @3s]
music: [slow tempo, low synth pulse, crescendo 2–8s]
```

**Continuity & constraints**

```
continuity: [same lighting/palette as prior shot], [ref_image: hero_ref_03], [door still ajar]
avoid: [glitches, extra limbs, text overlays, flicker]
```

Tokens and structure reflect consistent community guidance + OpenAI’s steerability emphasis. ([Skywork][3])

---

## 11) Ready-to-Use Prompt Templates

### A) Cinematic Realism (single shot, 10 s)

> **Scene:** Rainy neon alley, Tokyo, night. **Subject/Action:** Motorcycle courier adjusts helmet, glances down alley. **Camera/Lens:** MCU, eye-level, **35 mm**. **Motion:** **Handheld push-in (slow)**; slight **pan right**. **Lighting/Texture:** Practical neons; **wet asphalt** with mirror reflections; soft mist; subtle **film grain**. **Tone/Style:** **Cinematic, moody synthwave**. **Audio:** `dialogue @2.0s (whisper, urgent): "We’re late—move."` `amb: rain on tin roofs` `sfx: muffled train horn @3.0s` `music: low synth pulse, crescendo 2–8s`. **Avoid:** flicker, text overlays, extra limbs.

### B) Stylized Animation (anime-inspired)

> **Scene:** Rooftop at sunrise above a pastel city. **Action:** Protagonist ties scarf; wind lifts it. **Camera/Lens:** **WS**, **24 mm**, **low angle**. **Motion:** **Crane up** to reveal skyline. **Lighting/Texture:** Soft diffused light, **cel-shaded** edges, gentle bloom. **Style:** **Anime-inspired**, warm palette. **Audio:** `amb: morning breeze` `music: gentle strings, slow tempo`. **Avoid:** hyperreal skin textures; keep outlines clean.

### C) Physics-Heavy Sports Beat

> **Scene:** Indoor court, evening. **Action:** Player attempts **corner 3**; **ball rims out** and **realistically bounces**; defender boxes out. **Camera/Lens:** **MS**, **85 mm**, **eye-level**. **Motion:** **Gimbal track** from baseline (slow). **Physics:** **elastic bounce**, rim rattle, **momentum carries** to weak-side. **Audio:** `sfx: rim clang @4.2s, sneaker squeaks, crowd murmur`. **Avoid:** teleporting ball paths or morphs.

### D) Dialogue-Driven Drama (two-shot + inserts)

> **0s (WS):** Dim cafe, golden hour; **two-shot** at table.
> **3s (MS):** Over-shoulder on **A**; **dialogue @3.1s:** “You weren’t there.” **Tone:** restrained, hurt.
> **6s (CU):** On **B**; small **micro-expression** (averted gaze).
> **Audio:** `amb: espresso machine hiss`, `music: slow piano, soft`.
> **Continuity:** Same key/fill ratio, same wardrobe; cup remains half-full.
> **Avoid:** exaggerated expressions; keep gestures minimal.

(Templates A–D align with Sora 2’s strengths: controllable camera/motion, physics cues, and audio-timed beats. ([OpenAI][2]))

---

## 12) Iteration Workflow (fast to pro)

1. **Scout pass** (short clip): Confirm **framing, palette, physics beat, audio beats**.
2. **Refine** by toggling **one** lever: lens, camera speed, lighting ratio, palette, or physics descriptors.
3. **Continuity lock:** Freeze identity tokens + lighting + palette; reuse exact phrasing.
4. **Coverage:** Generate alt angles for the same beat; pick best in edit.
5. **Polish pass:** Re-prompt micro-beats (e.g., the line delivery) if needed.

This mirrors creator workflows reported around Sora 2’s steerability and the importance of disciplined iteration. ([Skywork][4])

---

## 13) Negative & Constraint Language (use sparingly)

Short, targeted constraints reduce artifacts without over-constraining:
`avoid: glitches, extra limbs, text overlays, flicker`
`style guard: consistent palette, no hyperreal pores (if stylized)`

Creators report these as effective safety rails when kept concise. ([Skywork][3])

---

## 14) What Sora 2 Still Finds Tricky (plan around it)

* **Dense crowds** with many independent agents
* **Fine hand–object** manipulation
* **Subtle micro-expressions** in extreme close-ups
* **On-screen text** (diegetic signs/UI) can wobble

Plan tighter framing, cutaways, and inserts; keep hands partially framed; underplay facial beats; use negatives judiciously. ([Skywork][4])

---

## 15) Why this works (the model’s side)

OpenAI’s Sora 2 materials repeatedly emphasize **accuracy of physics**, **synchronized audio**, and **improved controllability/steerability**—so prompts that read like a **director’s plan** (camera, motion, physics, and sound beats) match how the model is intended to be used and tested. ([OpenAI][1])

---

### Minimal Master Template (paste, then fill)

```
[Scene]: [place, time, weather]
[Subject/Action]: [who/what + action beat]
[Camera & Lens]: [WS/MS/CU], [angle], [24/35/85 mm]
[Motion]: [dolly/crane/gimbal/handheld + speed]; [pan/tilt if needed]
[Physics cues]: [materials, forces, interactions, failure beat]
[Lighting/Texture]: [key/fill/ambient], [golden hour/soft diffused], [grain/flares/fog]
[Tone/Style]: [cinematic/doc/anime/hyperreal], [palette]
[Audio]: dialogue @[t]: (tone/accent) "…"; amb: […]; sfx @[t]: […]; music: [tempo/mood/crescendo @t]
[Continuity]: [same lighting/palette], [ref_image id], [world state note]
[Avoid]: [glitches, extra limbs, text overlays, flicker]
```

---

## Key Sources (for your records)

* **OpenAI — “Sora 2 is here”** (physics realism, synchronized audio, controllability). ([OpenAI][1])
* **OpenAI — Sora 2 System Card** (capability overview; steerability; realism). ([OpenAI][2])
* **Creator Prompting Guides** (film-grammar tokens & examples). ([Skywork][3])
* **Launch coverage (app behaviors, audio sync in practice)**. ([Venturebeat][5])
* **Workflow best practices (iteration, pitfalls)**. ([Skywork][4])

[1]: https://openai.com/index/sora-2/?utm_source=chatgpt.com "Sora 2 is here"
[2]: https://openai.com/index/sora-2-system-card/?utm_source=chatgpt.com "Sora 2 System Card"
[3]: https://skywork.ai/blog/sora-2-prompting-tips-2025/?utm_source=chatgpt.com "12 Essential Sora 2 Prompting Tips for Video Creators (2025)"
[4]: https://skywork.ai/blog/sora-2-workflow-guide-2025-video-production-best-practices/?utm_source=chatgpt.com "Sora 2 Workflow Guide (2025): Boosting Your Video ..."
[5]: https://venturebeat.com/ai/openai-debuts-sora-2-ai-video-generator-app-with-sound-and-self-insertion?utm_source=chatgpt.com "OpenAI debuts Sora 2 AI video generator app with sound ..."
