# BlockKing 进度看板（长期协作版）

更新时间：2026-02-08

## 1. 当前实现快照（基于仓库实际）

- 关卡主流程已跑通：`Main.gd` + `system/GameFlowConfig.gd` 支持 Section 加载/切换/重生。
- 当前关卡流包含教学与第一章：`stage0/section0_tutorial`、`stage1/section1_1`、`stage1/section1_2`。
- 玩家核心动作可用：移动、跳跃、攻击、物理/魔法格挡、受击重生（`player/Player.gd`）。
- 教学关卡已实现触发链：物理教学 -> 魔法教学 -> 解锁传送（`stages/stage0/TutorialSection.gd`）。
- 对话 UI 已接入主场景并由 `AssetRegistry` 动态取素材（`Main.tscn`、`ui/DialogueUI.gd`）。
- 已修复：切关后对话框残留显示，`unload_section()` 会统一隐藏 `DialogueUI`（`Main.gd`）。

## 2. 里程碑状态

### M0 基础流程（完成）

- [x] Section 切换（Main/Transport）
- [x] Checkpoint 出生与重生
- [x] 输入映射与 E2E 调试快捷键

### M1 战斗最小闭环（完成）

- [x] 物理/魔法攻击类型区分
- [x] 对应格挡判定与受击重生
- [x] 基础敌人与投射物链路

### M2 教学与剧情基础（部分完成）

- [x] 教学关卡 `section0_tutorial`
- [x] `DialogueUI` 基础显示与素材注入
- [ ] `StoryTrigger` 通用节点
- [ ] `StoryEventRunner`（Autoload）
- [ ] `StoryData`（JSON/Resource 数据驱动）

### M3 可发行 Demo 配套（未完成）

- [ ] 主菜单与完整流程入口
- [ ] HUD（HP/格挡状态/目标）
- [ ] Demo 结算页与回环

## 3. 本周执行清单（2026-02-08 起）

1. 补齐 W1 缺口素材并接入：
   - `sfx.block_physical`
   - `sfx.block_magic`
   - `sfx.ui_next`
   - `portrait.narrator`
2. 开始 W3 通用剧情架构：
   - 先做 `StoryEventRunner` 最小可用版本（仅串行播放对白）
   - 再抽出 `StoryTrigger`，替换教学关卡内硬编码触发
3. 建立每周固定回归：
   - 从入口到通关/切关全流程跑一轮，记录到本文件“回归记录”。

## 4. 阻塞与风险

- 音频资产仍缺：`assets` 下未检出 `*.ogg/*.wav/*.mp3`，会限制对白音效与战斗反馈落地。
- 剧情系统目前偏场景脚本实现，若不尽快抽象为 `StoryTrigger/Runner/Data`，后续章节复制成本会升高。

## 5. 回归记录

### 2026-02-08

- 场景：教学关卡通关后切关。
- 预期：切换 Section 后不显示上一关遗留 DialogBox。
- 实际：`Main.unload_section()` 调用 `_hide_dialogue_ui()` 后隐藏成功。
- 结果：通过。

## 6. 下次会话入口

- 优先处理：`StoryEventRunner` 最小实现 + 接入 `section0_tutorial`。
- 完成后同步更新：
  - `DEMO_RELEASE_PLAN.md` 的“当前现状”
  - `docs/integration_board.md` 的素材状态
