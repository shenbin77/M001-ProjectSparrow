# Asset Checklist — Project Sparrow / 赤雀

**Status: DRAFT — verify all dimensions against Steamworks at upload**
**Last updated: 2026-09-11**

This document lists every asset needed for a Steam store page submission. No asset currently exists at final quality unless explicitly marked [DONE]. Dimensions below are based on Steam documentation — always verify against the current Steamworks spec at upload time, as requirements may change.

---

## 1. Capsule Images

| Asset | Required Size | Status | Notes |
|---|---|---|---|
| Header Capsule (460×215) | 460×215 px | [TODO] | Primary store page image. Must include game title. Current placeholder visuals only — final art direction undecided. |
| Small Capsule (231×87) | 231×87 px | [TODO] | Used in search results, queues. |
| Large Capsule (616×353) | 616×353 px | [TODO] | Used on store pages, wishlists. |
| Hero Capsule (384×184) | 384×184 px | [TODO] | Used on library, community hub. |
| Header Capsule (alternate) | 1920×620 | [TODO] | For certain Steam placements — verify if required for your setup. |

**Key question:** The game has no formal character art yet. Capsule images will need to use either: (a) placeholder geometric designs matching current in-game art, (b) a stylized title-only design, or (c) temporary art that clearly represents the final direction. Decision required before production.

---

## 2. Screenshots

| Asset | Required Size | Status | Notes |
|---|---|---|---|
| Screenshot 1 | 1920×1080 px (16:9) | [TODO] | Must show actual gameplay. Suggested: mahjong table mid-match with hand visible. |
| Screenshot 2 | 1920×1080 px | [TODO] | Club management view — roster, training, or club interior. |
| Screenshot 3 | 1920×1080 px | [TODO] | Match result screen showing scoring breakdown. |
| Screenshot 4 | 1920×1080 px | [TODO] | League standings or career progression screen. |
| Screenshot 5 | 1920×1080 px | [TODO] | Character/player detail screen showing stats and skills. |

**Minimum:** 5 screenshots recommended. Steam allows up to 8. All must be 16:9, JPG or PNG, no border. All must be from the actual shipping build — no mock-ups.

**AI disclosure note:** If Steam requires disclosure of AI-generated content in screenshots (e.g., AI-generated text in UI), determine policy at upload time and comply.

---

## 3. Trailer

| Asset | Specs | Status | Notes |
|---|---|---|---|
| Trailer video | 1920×1080, 60fps or 30fps, MP4 or WebM, max 1GB | [TODO] | Shot list defined in `TRAILER_SCRIPT.md`. Must be captured from final build. Duration 60–75 seconds. |

---

## 4. Store Page Build

| Item | Status | Notes |
|---|---|---|
| Windows build (.zip) | [TODO] | Must be a clean export, not an editor build. Verified on a clean Windows machine. |
| Build description | [TODO] | Brief text describing the build state. |
| Version number | [TODO] | Semantic version. Currently 0.1.0-dev — needs a release version before upload. |

---

## 5. Legal / Compliance

| Item | Status | Notes |
|---|---|---|
| Third-party licenses | [TODO] | Bundle majiang-core v1.4.1 MIT license text in the build. |
| EULA / Terms of Service | [TODO] | Required for Steam distribution. Content TBD. |
| Privacy Policy | [TODO] | Required if game collects any data. Currently: no data collection planned. |
| AI content disclosure | [TODO] | Steam may require disclosure if AI tools were used in development. Document which assets/text are AI-assisted. Comply with current Steam policy at upload time. |
| Content rating | [TODO] | No violence, no gambling, no mature content. Likely E/ESRB or equivalent — verify at upload. |

---

## 6. Build Packaging

| Item | Status | Notes |
|---|---|---|
| Export template (Godot) | [TODO] | Windows export template required. Currently using editor executable — must switch to proper export. |
| Clean machine test | [TODO] | Build must run on a Windows machine without Godot installed. Test on a fresh/clean system. |
| Save file path documented | [TODO] | Where saves go, how to back them up. |
| Input support documented | [TODO] | Mouse + keyboard. Verify and document. |

---

## 7. Metadata / Text

| Item | Status | Notes |
|---|---|---|
| Game title (Steam) | [TODO] | "Project Sparrow" or "赤雀" — decide. Both may work but verify character support. |
| Short description | [DRAFT] | See `STEAM_STORE_DRAFT.md`. Character count must be verified at upload. |
| Full description | [DRAFT] | See `STEAM_STORE_DRAFT.md`. |
| Developer name | [TODO] | Confirm legal entity or studio name for Steam. |
| Publisher name | [TODO] | If different from developer. |
| Tags | [DRAFT] | See `STEAM_STORE_DRAFT.md`. Verify against Steamworks tag list. |
| Genre | [DRAFT] | Primary: RPG. Secondary: Strategy. Verify at upload. |
| System requirements | [PLACEHOLDER] | Must be measured from actual build. All values TBD. |
| Release date | [UNKNOWN] | Depends on Steam AppID, payment, Coming Soon period, and build readiness. |

---

## Open Questions (require user decision)

1. **Capsule art direction:** Placeholder geometric style or invest in temporary key art before first upload?
2. **Game title on Steam:** English-first "Project Sparrow" or Chinese-first "赤雀" or both?
3. **AI disclosure:** What exactly does Steam require in 2026 for AI-assisted content? Research current policy.
4. **Legal entity:** What name goes on the Steam developer/publisher fields?
5. **Content rating:** Self-assess or formal rating required for your target markets?

---

**DRAFT CONFIRMATION:** No asset dimensions or requirements in this document are final. Steamworks specifications must be checked at upload. Placeholder sizes are based on known Steam documentation but may have changed. Do not produce final assets until build is stable and art direction is confirmed.
