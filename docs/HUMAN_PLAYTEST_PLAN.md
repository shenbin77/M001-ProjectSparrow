# Human Playtest Plan — Project Sparrow / 赤雀

**Status: DRAFT — plan only, no results fabricated**
**Last updated: 2026-09-11**

This document defines a structured playtest protocol for a single 1–2 hour session of the career mode. It specifies what to observe, what to measure, and what constitutes success or failure. No participant results are recorded here — results are filled in after actual testing.

---

## Session Overview

| Item | Value |
|---|---|
| **Test type** | Single-session career mode playthrough |
| **Duration** | 1–2 hours (hard stop at 2 hours) |
| **Player count** | 1 player per session |
| **Environment** | Windows PC, clean install of the exported build |
| **Build version** | Record exact version number at test start |
| **Tester** | Record name/alias at test start |

---

## Pre-Test Checklist

Before the session begins, verify:

- [ ] Build is the exported release candidate, not the Godot editor
- [ ] Save directory is clean (no existing saves from development)
- [ ] Timer is set to 2 hours
- [ ] Note-taking tool is ready (spreadsheet, document, or paper)
- [ ] Build version and date are recorded
- [ ] Tester has not played this build before (if first-time test)

---

## Phase Breakdown with Time Checkpoints

### Phase 1: First Match & Tutorial (0:00–0:30)

**Goal:** Can the player start the game, understand what to do, and complete a first match?

| Checkpoint | Time | What to Observe | Pass Criteria |
|---|---|---|---|
| Game launches | 0:00–0:02 | Does the build open without error? | Window appears, title screen loads. |
| New career started | 0:02–0:05 | Can the player start a new career? | Career begins, club view appears. |
| Tutorial / first guidance | 0:05–0:10 | Does the game explain what to do? Is there a tutorial prompt, text, or guide? | Player understands they need to field a player and start a match. If no tutorial exists, note "no tutorial" and continue. |
| First match starts | 0:10–0:15 | Player selects a match and enters the table. | Table loads, hand is dealt. |
| First match played | 0:15–0:25 | Player makes discards, calls, or other moves. AI responds. | At least 4 turns complete without crash or rule error. |
| First match ends | 0:25–0:30 | Match concludes (win, draw, or loss). Result screen shown. | Score is displayed. Player returns to club view. Reward/progression is visible. |

**Record:**
- Time from launch to first match start: ___
- Time from launch to first match end: ___
- Any crashes or freezes: ___
- Any confusion points where the player didn't know what to do: ___

---

### Phase 2: Club Management & Recruiting (0:30–0:50)

**Goal:** Can the player recruit a new character, understand their stats, and make a meaningful choice?

| Checkpoint | Time | What to Observe | Pass Criteria |
|---|---|---|---|
| Club management explored | 0:30–0:35 | Player opens roster, training, or club screens. | Menus open and display character data. |
| Character stats visible | 0:35–0:38 | Player views a character's stats and skill slots. | At least one character's full stat sheet is readable. |
| Recruiting attempted | 0:38–0:45 | Player accesses the scouting/recruiting screen and makes a selection. | Recruiting completes. New character appears in roster. Cost is deducted. |
| Training attempted | 0:45–0:50 | Player assigns a character to training or uses a training action. | Training completes or XP/level gain is visible. |

**Record:**
- Did the player understand what recruiting does without external help? ___
- Was the cost of recruiting clear? ___
- Did training produce a visible result? ___
- Were skill slots visible and understandable? ___

---

### Phase 3: Skill Change & Effects (0:50–1:05)

**Goal:** Can the player change a character's skill and observe that it matters?

| Checkpoint | Time | What to Observe | Pass Criteria |
|---|---|---|---|
| Skill system accessed | 0:50–0:55 | Player opens the skill configuration screen for a character. | Skill slots are visible (4 slots per character). |
| Skill changed | 0:55–1:00 | Player assigns or swaps a skill. | Skill change is accepted. UI confirms the change. |
| Effect observable | 1:00–1:05 | Player enters a match after the skill change. Does anything feel different? | Player is asked if they noticed any difference. If skills only affect training XP (current implementation), note that clearly. |

**Record:**
- Was the skill change process intuitive? ___
- Did the player understand what the skill does? ___
- Was any effect observable in the next match? ___
- Did the player feel the skill change was meaningful? ___

---

### Phase 4: League Advancement (1:05–1:25)

**Goal:** Can the player progress through at least one league tier or challenge node?

| Checkpoint | Time | What to Observe | Pass Criteria |
|---|---|---|---|
| League/challenge screen accessed | 1:05–1:10 | Player views the league or challenge map. | Current position and next opponent are visible. |
| Match against higher-tier opponent | 1:10–1:20 | Player plays a match against a league opponent. | Match completes. Result affects league standing. |
| Advancement or progress | 1:20–1:25 | After winning (or accumulating enough wins), player advances. | League standing updates. New opponents or tier becomes available. |

**Record:**
- How many matches were played in this phase? ___
- Did the player feel progression was earned? ___
- Was the league structure clear? ___
- Did advancement feel rewarding? ___

---

### Phase 5: Save / Reload (1:25–1:40)

**Goal:** Can the player save their career, exit, reload, and resume without data loss?

| Checkpoint | Time | What to Observe | Pass Criteria |
|---|---|---|---|
| Game saved | 1:25–1:30 | Player saves the career (between matches). | Save completes. Confirmation shown. |
| Game exited | 1:30–1:32 | Player closes the application. | Application closes cleanly. |
| Game relaunched | 1:32–1:35 | Player opens the build again and loads the save. | Save loads. Club view appears with correct roster, currency, and progress. |
| Resume play | 1:35–1:40 | Player plays one more match after reload. | Match works. No data corruption, no duplicate rewards, no lost progress. |

**Record:**
- Time to save: ___
- Time to reload: ___
- Was all data preserved? (roster, currency, skills, league position) ___
- Any anomalies after reload? ___

---

### Phase 6: Wrap-Up & Free Play (1:40–2:00)

**Goal:** Open-ended exploration. Let the player do whatever they want. Observe emergent behavior.

| Checkpoint | Time | What to Observe | Pass Criteria |
|---|---|---|---|
| Free exploration | 1:40–2:00 | Player does whatever they find interesting. | No crashes. No softlocks. No game-breaking bugs. |
| Session ends | 2:00 | Timer expires. Session concludes. | Player stops. Final notes taken. |

**Record:**
- What did the player choose to do with free time? ___
- Any bugs discovered in open play? ___
- Would the player want to continue playing? (1–5 rating) ___

---

## Success Criteria Summary

The session is a **pass** if ALL of the following are true:

1. The build launches and runs for the full 1–2 hours without crash or data loss.
2. A full career loop is completed: start → recruit → train → match → progress → save → reload → resume.
3. Real Riichi rules function correctly (no illegal moves accepted, no rule errors visible).
4. The player can complete at least 3 full matches without external intervention.
5. Save/load works without data corruption.
6. No game-breaking bugs (softlock, crash, infinite loop, corrupt save).

The session is a **fail** if ANY of the following occur:

1. Crash to desktop at any point.
2. Save data lost or corrupted.
3. Player cannot complete a match due to a bug.
4. A rule error produces an illegal game state (e.g., wrong score, impossible move accepted).
5. Player is completely stuck with no way to proceed.

---

## Failure Recording Template

For each bug or issue found during the test, record:

| Field | Value |
|---|---|
| **Bug ID** | Sequential (BUG-001, BUG-002, ...) |
| **Phase** | Which phase was the player in? |
| **Time** | Timestamp in the session |
| **Description** | What happened, in plain language |
| **Steps to reproduce** | Exact steps the player took |
| **Expected behavior** | What should have happened |
| **Actual behavior** | What actually happened |
| **Severity** | Crash / Blocker / Major / Minor / Cosmetic |
| **Build version** | Version of the build tested |

---

## Post-Test Debrief

After the 2-hour session, the tester answers these questions verbally or in writing:

1. What was the most fun moment?
2. What was the most frustrating moment?
3. Did you understand what you were supposed to do at every point? Where were you confused?
4. Did the mahjong matches feel fair and functional?
5. Did the club management feel meaningful or like busywork?
6. Would you want to play another hour? Why or why not?
7. What one thing would make you want to play this again?

---

## Important Notes

- **This plan does not guarantee a passing result.** The purpose is to find what's broken, not to confirm what works.
- **Do not coach the tester.** Let them figure things out. If they're stuck for more than 3 minutes, note it and then offer a hint.
- **Do not fabricate results.** If the tester didn't do something, mark it "not tested." If something failed, record the failure honestly.
- **One session is not enough.** This plan covers one tester's experience. A second session with a different tester is recommended before making release decisions.

---

**DRAFT CONFIRMATION:** This is a test protocol, not a report. No results are recorded here. Actual test sessions must be conducted with real participants using the shipping build. Results will be documented in a separate report after testing.
