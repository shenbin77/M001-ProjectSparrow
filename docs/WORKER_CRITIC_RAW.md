I'll read all four files in parallel to begin the review.
Now let me verify a couple of specific patterns I noticed by checking how `busy` interacts with concede and finish:
The file seems to have more content than initially read. Let me get the full current state:
Good — the current version has busy guards on most handlers. Let me also verify the save atomicity and cli transport more closely:
Here is the review.

---

## Code Review — P1 / P2 Bugs

### P1-1 `finish_match()` missing busy guard
**File:** `game/main.gd:271-274`
**Severity:** P1 (data corruption if UI ever exposes button during pending request)

`concede()` has a busy check (line 277), but `finish_match()` does not. Currently "Return to club" only renders when `match_data.done == true` (line 218), so it's not exploitable *today*. But it's a defensive gap — any future UI tweak that shows the button mid-match would let the user clear `match_data` while `advance()` is awaiting, causing the await to overwrite the empty dict and resurrect a stale match.

**Patch:**
```gdscript
func finish_match() -> void:
    if busy:
        return
    match_data = {}
    ...
```

---

### P1-2 `.out` file leak on process timeout
**File:** `game/main.gd:186-189`

When the rule process times out, the code kills the pid and removes `.in`, but never removes `.out`. If the child process wrote partial output before being killed, the stale `.out` sits on disk. Worse: a subsequent match with the same microsecond prefix (unlikely but possible after rapid retries) could pick up the stale file if `request_backend` were ever refactored.

**Patch (line 188, after `DirAccess.remove_absolute(prefix + ".in")`):**
```gdscript
DirAccess.remove_absolute(prefix + ".in")
DirAccess.remove_absolute(prefix + ".out")   # <-- add this
return {"ok": false, "error": "Rule process timeout; state retained"}
```

---

### P1-3 `settle()` called from `show_match()` — idempotent but semantically misplaced
**File:** `game/main.gd:221`

`career.settle(match_id, won)` is inside `show_match()`, which runs every time the match screen renders. The `settle()` function is idempotent (career.gd:32 checks `settled.has()`), so this won't double-reward. But coupling reward settlement to a *view function* means any future call to `show_match()` with a done state re-enters settlement logic. If `settle()` is ever extended (e.g., trigger side effects, emit signals), this becomes a bug. Settlement belongs in `advance()` after the final successful response, not in the render path.

**Suggested refactor (not a strict Day1 fix):** Move `career.settle()` into `advance()` when `result.done == true`, then call `show_match()` purely for display.

---

### P2-1 Windows atomic rename may fail
**File:** `game/career.gd:90-94`

```gdscript
if FileAccess.file_exists(path):
    var backup := DirAccess.copy_absolute(path, path + ".bak")
    if backup != OK:
        return backup
return DirAccess.rename_absolute(path + ".tmp", path)
```

On Windows, `rename_absolute` over an existing file is not guaranteed (Godot wraps `MoveFileExW`, which requires `MOVEFILE_REPLACE_EXISTING`). If the flag isn't set, the rename silently fails. Also, if `copy_absolute` succeeds but `rename_absolute` fails, the `.tmp` file is orphaned.

**Patch:**
```gdscript
if FileAccess.file_exists(path):
    var backup := DirAccess.copy_absolute(path, path + ".bak")
    if backup != OK:
        DirAccess.remove_absolute(path + ".tmp")
        return backup
if FileAccess.file_exists(path):
    DirAccess.remove_absolute(path)
var result := DirAccess.rename_absolute(path + ".tmp", path)
if result != OK:
    DirAccess.remove_absolute(path + ".tmp")
return result
```

---

### P2-2 `.tmp` orphan on write failure
**File:** `game/career.gd:84-86`

If `FileAccess.open(path + ".tmp", WRITE)` succeeds but `store_string` / `flush` / `close` throw (disk full, permission denied), the `.tmp` file remains. Same for the rename failure path above.

**Patch:** Wrap in `try/finally` equivalent (GDScript lacks try/finally, so check and remove on error paths as shown in P2-1 patch).

---

### P2-3 CLI output not written atomically
**File:** `backend/cli.cjs:14`

```js
fs.writeFileSync(process.argv[4], JSON.stringify(response));
```

`writeFileSync` is not atomic on all filesystems. If the node process is killed by the OS (OOM, signal) mid-write, Godot reads a truncated/corrupted `.out`. Godot does wait for process exit (main.gd:185), so this is low-risk, but for robustness use a temp-then-rename pattern:

**Patch:**
```js
const tmp = process.argv[4] + '.tmp';
fs.writeFileSync(tmp, JSON.stringify(response));
fs.renameSync(tmp, process.argv[4]);
```

---

### P2-4 `cli.cjs` stat-then-read TOCTOU
**File:** `backend/cli.cjs:11-12`

```js
if(fs.statSync(process.argv[3]).size>200000) throw Error('Request too large');
response=execute(JSON.parse(fs.readFileSync(process.argv[3],'utf8')));
```

The file could grow between `statSync` and `readFileSync`. In practice Godot has finished writing before spawning the process, so this is theoretical. Acceptable for Day1 but worth noting.

---

### P2-5 `adapter.cjs` monkey-patches `Math.random` globally
**File:** `backend/adapter.cjs:54-55`

```js
Math.random=()=>{...};
```

This is restored in the `finally` block (line 85), which is correct. But if two `execute()` calls ever run concurrently (e.g., with worker_threads), they'd corrupt each other's PRNG state. Not a problem in current single-request-per-process design, but a latent hazard.

---

### P2-6 `match_id` collision window
**File:** `game/main.gd:204`

```gdscript
match_id = "%s-%s" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()]
```

`get_unix_time_from_system()` returns seconds, `get_ticks_usec()` returns microseconds since app start. Two matches starting in the same second and same tick produce the same ID. The `busy` flag prevents this today, but after P1-1 is fixed it remains safe. Still, concatenating two time sources is fragile — consider `randi()` or a UUID.

---

### Summary Table

| ID | Severity | File:Line | Issue | Fix Complexity |
|----|----------|-----------|-------|---------------|
| P1-1 | P1 | main.gd:271 | `finish_match()` no busy guard | Trivial |
| P1-2 | P1 | main.gd:188 | `.out` file leak on timeout | Trivial |
| P1-3 | P1 | main.gd:221 | `settle()` in view function | Refactor |
| P2-1 | P2 | career.gd:90-94 | Windows atomic rename | Medium |
| P2-2 | P2 | career.gd:84-86 | `.tmp` orphan on failure | Medium |
| P2-3 | P2 | cli.cjs:14 | Non-atomic output write | Trivial |
| P2-4 | P2 | cli.cjs:11-12 | TOCTOU on file size check | Low |
| P2-5 | P2 | adapter.cjs:54 | Global PRNG mutation | Low |
| P2-6 | P2 | main.gd:204 | match_id collision window | Low |

**Overall assessment:** The busy-guard pattern is well-applied across all user-facing handlers. The two P1s (missing guard on `finish_match` and the `.out` leak) are straightforward fixes. The save atomicity on Windows (P2-1) is the most likely to bite in real use. Everything else is defensive hardening appropriate for post-Day1.
