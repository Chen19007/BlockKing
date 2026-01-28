# BlockKing Web E2E Manual Cases

All steps use Chrome DevTools to dispatch input events (no in-game auto tests).
Focus the canvas before sending keys.

## Preconditions

1) Export Web:
   - `godot --headless --path "D:/project/godot/blockking" --export-release "Web" "build/web/BlockKing.html"`
2) Serve `build/web` with a local HTTP server and open in Chrome.
3) Open DevTools and use it to send key combos.

## Test Sections (E2E)

- `section0_1`: Physical/melee + archer projectile setup.
- `section0_2`: Magic projectile + checkpoint activation setup.

Load sections via combo keys:
- `Ctrl+Alt+Shift+Home` -> `section0_1`
- `Ctrl+Alt+Shift+End` -> `section0_2`

## Case List

### E2E-001 Load section0_1

Steps:
1) `Ctrl+Alt+Shift+Home`

Expected:
- Console: `[E2E] load_section target=section0_1`
- Player respawns near `(100, 300)` in logs.

### E2E-002 Physical projectile hits when unblocked

Steps:
1) `Ctrl+Alt+Shift+Home`
2) `Ctrl+Alt+Shift+F3` (clear overrides)
3) `Ctrl+Alt+Shift+F5` (spawn physical test projectile)

Expected:
- `[E2E] spawn_projectile type=0 ...`
- `[Projectile] hit_player blocked=false`
- `[State] respawn requested reason=projectile`
- `[Main] Respawn complete`

### E2E-003 Physical projectile reflects when blocking

Steps:
1) `Ctrl+Alt+Shift+Home`
2) `Ctrl+Alt+Shift+F1` (force physical block)
3) `Ctrl+Alt+Shift+F5`

Expected:
- `[State] blocking_physical=true`
- `[Projectile] blocked -> reflect`
- `[Projectile] reflected_hit_enemy`

### E2E-004 Melee hit without block

Steps:
1) `Ctrl+Alt+Shift+Home`
2) `Ctrl+Alt+Shift+F3`
3) `Ctrl+Alt+Shift+2` (teleport DebugMarkerB near melee enemies)

Expected:
- `[Enemy] melee hit`
- `[State] respawn requested reason=melee`
- `[Main] Respawn complete`

### E2E-005 Melee blocked

Steps:
1) `Ctrl+Alt+Shift+Home`
2) `Ctrl+Alt+Shift+F1`
3) `Ctrl+Alt+Shift+2`

Expected:
- `[Enemy] melee blocked`
- No respawn logs.

### E2E-006 Load section0_2

Steps:
1) `Ctrl+Alt+Shift+End`

Expected:
- Console: `[E2E] load_section target=section0_2`
- Player respawns near `(120, 280)` in logs.

### E2E-007 Magic projectile hits when unblocked

Steps:
1) `Ctrl+Alt+Shift+End`
2) `Ctrl+Alt+Shift+F3`
3) `Ctrl+Alt+Shift+F6`

Expected:
- `[E2E] spawn_projectile type=1 ...`
- `[Projectile] hit_player blocked=false`
- `[State] respawn requested reason=projectile`

### E2E-008 Magic projectile reflects when blocking

Steps:
1) `Ctrl+Alt+Shift+End`
2) `Ctrl+Alt+Shift+F2`
3) `Ctrl+Alt+Shift+F6`

Expected:
- `[State] blocking_magic=true`
- `[Projectile] blocked -> reflect`
- `[Projectile] reflected_hit_enemy`

### E2E-009 Checkpoint activation updates respawn point

Steps:
1) `Ctrl+Alt+Shift+End`
2) `Ctrl+Alt+Shift+2` (teleport DebugMarkerB -> CheckpointB)
3) Verify activation logs
4) `Ctrl+Alt+Shift+F3`
5) `Ctrl+Alt+Shift+F6` (force death)

Expected:
- `[Section] respawn_point set to (600.0, 280.0)`
- `[Checkpoint] activated pos=(600.0, 280.0)`
- After death, player respawns near `(600, 280)` in logs.
