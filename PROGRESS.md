# BlockKing Implementation Progress

Last updated: 2026-01-28

## Current Status (Summary)

- Core flow: Main loads/unloads sections and switches via Transport.
- Sections: `section1_1` and `section1_2` exist with checkpoints, transport, floor, and debug markers.
- Player: movement, jump, physical/magic block, fall + combat respawn triggers.
- Input: mappings corrected in `project.godot`.
- Checkpoints: activation updates respawn point (E2E verified).
- Enemies: Slime/Skeleton melee, Skeleton Archer projectile (physical), Priest projectile (magic).
- Test stability: melee enemies set to stand still (move_speed = 0) for E2E.
- Web E2E: verified via Chrome DevTools input injection and console logs (projectile reflect, melee block/hit, respawn).
- E2E scaffolding: combo-key debug moves, marker teleport/set, forced block toggles, test projectile spawn (physical/magic).
- E2E scaffolding: PageUp/PageDown section switch (debug).

## Milestones

### 0) Foundation (Done)

- [x] Section flow (Main/GameFlowConfig/Section)
- [x] Checkpoint spawn + Transport switch
- [x] Input mapping in `project.godot`
- [x] Player move/jump/physical+magic block
- [x] Fall-based respawn
- [x] Chrome DevTools E2E verification
- [x] E2E debug scaffolding (combo keys + DebugMarkerA/B)

### 1) Combat Model (Done)

- [x] Define attack types: physical vs magic (data + enums)
- [x] Block resolution: physical blocks physical, magic blocks magic

### 2) Enemy + Projectile MVP (Done)

- [x] Base enemy AI (idle, approach, attack)
- [x] Slime + Skeleton placeholders (Chapter 1)
- [x] Skeleton Archer boss + basic projectile
- [x] Physical projectile reflection on block

### 3) Chapter 1 Layout (Per DESIGN.md)

- [ ] Room 1: Slime x2
- [ ] Room 2: Slime x3 -> Skeleton x2
- [ ] Room 3: Skeleton x3
- [ ] Room 4: Skeleton Archer boss
- [ ] Section split into room checkpoints/trigger volumes

### 4) Chapters 2–6 (Sequence)

- [ ] Chapter 2: Armored/Greatsword skeletons + Axeman boss
- [ ] Chapter 3: Orc + Archer + Orc rider boss
- [ ] Chapter 4: Soldier/Swordsman/Priest + Knight boss
- [ ] Chapter 5: Werewolf/Lancer + Werebear boss
- [ ] Chapter 6: Priest/Elite Orc + Wizard boss

### 5) UI / VFX / SFX (Placeholder → Final)

- [ ] UI: HP + physical/magic guard meters
- [ ] VFX: block sparks / magic shield glow
- [ ] SFX: block / jump / hit / death

## Next Actions (Proposed)

1) Implement attack-type model + HitBox/HurtBox baseline.
2) Add simple enemy spawner and projectile system.
3) Build Chapter 1 rooms per DESIGN.md and verify via E2E.
