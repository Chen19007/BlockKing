# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 默认长期协作方式（无需用户重复提醒）

- 每次对话默认按“长期计划协作”执行，不需要用户额外声明。
- 长期计划主文档：`DEMO_RELEASE_PLAN.md`（周目标/里程碑/验收口径）。
- 执行状态看板：`docs/integration_board.md`（`todo`/`in_review`/`ready`/`integrated`）。
- 进度日志：`PROGRESS.md`（本周完成、阻塞项、下周待办）。

### 默认执行规则

1. 会话开始先对齐当前周目标与未完成项，再开始具体实现。
2. 会话结束默认产出三项：本次完成、当前阻塞、下一步建议。
3. 涉及素材接入时，按 `asset_id + 文件路径 + 状态` 回写到 `docs/integration_board.md`。
4. 涉及阶段推进时，同步更新 `PROGRESS.md`，确保可跨会话连续推进。
5. 若用户指令与长期计划冲突，以用户当前指令优先，但在回复中提示影响范围。

## Project Overview

**BlockKing** is a rhythm-based action game in Godot 4.x where the protagonist can only "block" attacks. The core distinction is between **physical blocking** (short press, deflects melee/projectiles) and **magic blocking** (hold, absorbs/reflects spells). Distance (melee vs ranged) is secondary to the physical/magic dichotomy.

**Narrative**: The knight conspiracy has allied with monsters. The player discovers this truth through 6 chapters.

**Art**: Uses pixel art sprites from `aseprite_assets/`, exported to `assets/<sprite>/<animation>/<frame>.png`. Color variations (hue/lightness/saturation shifts) create enemy variants.

## Architecture

The game follows a **Section-based level flow** adapted from `instancing_starter`:

```
Main (Node)
 └─ current_section: Node2D (e.g., stage1/section1_1)
     ├─ Checkpoint (spawns Player)
     ├─ Transport (triggers section switch)
     ├─ RespawnPoint (marker)
     └─ Player (instantiated by Checkpoint)
```

**Key components**:

| Component | Role | Key methods/signals |
|-----------|------|---------------------|
| `Main.gd` | Loads/unloads sections, connects Transport signals | `load_section()`, `switch_section()` |
| `GameFlowConfig.gd` | Static config defining stage/section hierarchy | `get_section_path()`, `get_next_section_id()` |
| `Section.gd` | Per-section data: respawn point, camera limits | `get_respawn_point()`, `get_camera_limits()` |
| `Checkpoint.gd` | Spawns Player at respawn point | `spawn_player()` |
| `Transport.gd` | Area2D that emits `section_transport_requested` | Signal → `Main._on_transport_requested()` |
| `Player.gd` | Movement, jump, physical/magic block | Uses `is_blocking_physical`/`is_blocking_magic` |

**Adding a new section**:
1. Create `stages/stage<N>/section<N_<M>.tscn` with `Section.gd` root
2. Add `Checkpoint` and `Transport` as children
3. Add `section<N_<M>` to `GameFlowConfig.game_flow` array

## Input Controls

| Action | Keys | Purpose |
|--------|------|---------|
| `move_left` | A, Left Arrow | Move left |
| `move_right` | D, Right Arrow | Move right |
| `jump` | Space, Up Arrow | Jump |
| `block_physical` | J | Physical block (color: gray) |
| `block_magic` | K | Magic block (color: cyan) |

Both blocks cannot be active simultaneously; physical takes priority.

## Input Mapping Notes

- Keep `[input]` mappings in `project.godot` using `Object(InputEventKey, ...)` entries (as in instancing_starter).
- Avoid `null` entries or shorthand key-only entries in `events`, they can cause Web builds to ignore inputs.

## E2E Debug Scaffolding (Combo Keys)

All E2E scaffolding uses **Ctrl+Alt+Shift** combos to avoid conflicts with player controls.

- `F1`: Toggle force physical block
- `F2`: Toggle force magic block
- `F3`: Clear block overrides
- `F5`: Spawn physical test projectile (from right to left)
- `F6`: Spawn magic test projectile (from right to left)
- `PageUp`: Switch to next section (E2E debug)
- `PageDown`: Restart from first section (E2E debug)
- `Home`: Load test section `section0_1` (E2E debug)
- `End`: Load test section `section0_2` (E2E debug)
- `1`: Teleport to `DebugMarkerA`
- `2`: Teleport to `DebugMarkerB`
- `3`: Set `DebugMarkerA` to current position
- `4`: Set `DebugMarkerB` to current position
- `F7`: Smooth move left by `e2e_move_distance`
- `F8`: Smooth move right by `e2e_move_distance`
- `F9`: Step move right by `e2e_step_distance`
- `F10`: Step move left by `e2e_step_distance`
- `Up/Down`: Step move up/down by `e2e_step_distance`
- `F11`: Teleport to respawn

Markers `DebugMarkerA` and `DebugMarkerB` are placed in `section1_1.tscn` and `section1_2.tscn` for manual editing.
Test sections live under `stages/stage0/`:
- `section0_1`: Physical/melee + archer projectile E2E setup.
- `section0_2`: Magic projectile + checkpoint activation E2E setup.

## Web E2E Verification (Chrome DevTools Only)

- Export Web: `godot --headless --path "D:/project/godot/blockking" --export-release "Web" "build/web/BlockKing.html"`
- Serve `build/web` and open in Chrome.
- Use Chrome DevTools to perform the E2E input checks (do not use any in‑game auto test scripts).

**禁止**：使用 `WebInputTest` 或任何自动输入脚本替代 Chrome DevTools 的手动/工具操作验证。

## Code Verification

Run before committing:

```bash
# Lint (enforces naming, line length, etc.)
gdlint "D:/project/godot/blockking"

# LSP diagnostics (required for changed files)
# Use godot-lsp diagnostics on every modified GDScript file and clear all severity=1 errors.
# Example URIs:
# file:///D:/project/godot/blockking/player/Player.gd
# file:///D:/project/godot/blockking/system/ProceduralSFX.gd

# Format check
gdformat --check "D:/project/godot/blockking"

# Format apply
gdformat "D:/project/godot/blockking"

# Complexity metrics
gdradon cc "D:/project/godot/blockking"

# Export validation
godot --headless --path "D:/project/godot/blockking" --export-pack "Windows Desktop" "output/demo.pck"
```

## Design Philosophy: Compile-Time Guarantees

This project emphasizes **design guarantees over runtime checks**. Avoid nullable types and `null` checks where architecture can enforce invariants.

| Avoid | Prefer |
|-------|--------|
| `if node != null` | `@onready var node: NodeType = $Path` |
| Optional dependencies | Required components enforced by scene structure |
| `as` casting + null check | Collision layers/masks for type filtering |
| `var x := value` (type inference) | `var x: Type = value` (explicit type) |

**When null is acceptable**: Resource load failures, "not found" in search algorithms, explicitly optional components.

See `AGENTS.md` for detailed anti-patterns and refactoring examples.

## GDScript Conventions

- **Files**: `snake_case.gd`
- **Classes**: `class_name PascalCase`
- **Variables**: `snake_case` with explicit types
- **Signals**: `past_tense` (e.g., `section_transport_requested`)
- **Privates**: `_prefix` (e.g., `_update_block_state()`)
- **Constants**: `CONSTANT_CASE`
- **Order**: signals → enums → constants → @export → public vars → private vars → @onready → `_init()` → `_ready()` → virtuals → public methods → private methods

## Game Design Reference

- **DESIGN.md**: Full game design document (chapters, enemy types, color palettes, animation tags)
- **PLAN.md**: Implementation roadmap (instancing_starter migration, asset gaps)
- **AGENTS.md**: Coding standards and verification commands

## Sprite Assets

- **Source**: `aseprite_assets/<Name>.aseprite`
- **Exported**: `assets/<Name>/<Animation>/<Frame>.png`
- **Protagonist**: `Knight Templar.aseprite` (only used for player)
- **Animation tags**: See DESIGN.md §8 for per-sprite tag lists

Enemies with `Block` animation: `Armored Orc`, `Knight Templar`, `Knight`, `Orc rider`, `Skeleton`.

Enemies with magic/effect animations: `Priest`, `Wizard`.
