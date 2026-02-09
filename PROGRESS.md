# BlockKing 进度看板（长期协作版）

更新时间：2026-02-09

## 1. 当前实现快照（基于仓库实际）

- 关卡主流程已跑通：`Main.gd` + `system/GameFlowConfig.gd` 支持 Section 加载/切换/重生。
- 当前关卡流包含教学与第一章：`stage0/section0_tutorial`、`stage1/section1_1`、`stage1/section1_2`。
- 玩家核心动作可用：移动、跳跃、攻击、物理/魔法格挡、受击重生（`player/Player.gd`）。
- 教学关卡已实现触发链：物理教学 -> 魔法教学 -> 解锁传送（`stages/stage0/TutorialSection.gd`）。
- 对话 UI 已接入主场景并由 `AssetRegistry` 动态取素材（`Main.tscn`、`ui/DialogueUI.gd`）。
- 已修复：切关后对话框残留显示，`unload_section()` 会统一隐藏 `DialogueUI`（`Main.gd`）。
- 已接入全局 `ProceduralSFX`（Autoload），短 SFX 支持代码生成与多声部混音（`system/ProceduralSFX.gd`）。
- 玩家已接入生成式短 SFX 触发：跳跃/落地/挥砍/格挡命中（`player/Player.gd`）。
- `DialogueUI` 翻页音默认走生成式 click，保留采样流作为回退（`ui/DialogueUI.gd`）。
- 已接入 `DifficultyManager` 统一冷却配置：教学关提高敌人攻击冷却，非教学关按已选难度配置（`system/DifficultyManager.gd`、`Main.gd`、`enemies/BaseEnemy.gd`）。
- 已接入 `bgm.section_story`：主流程由 `Main.gd` 全局循环播放 `assets/Audio/BGM/section_story.ogg`。
- 已接入 BGM 路由与切换淡入淡出：按 `section_id` 选择音乐，缺失资源自动回退 `bgm.section_story`（`Main.gd`）。
- `DialogueUI` 已支持 `portrait.narrator_frame + portrait.narrator_character` 双图优先加载，保留 `portrait.narrator` 单图回退。
- `DialogueUI` 文本风格统一代码已就绪：支持 `font.ui_serif_cn` 自动加载、暖色字/描边/阴影参数、轻量 parchment shader（`ui/DialogueUI.gd`、`ui/shaders/text_parchment.gdshader`）。
- `font.ui_serif_cn` 已落地：`assets/Fonts/ui_serif_cn.otf`（SourceHanSerifCN-Regular），已与对话文本主题联通。
- `DialogueUI` 文本可读性已调优：黄底场景改为深墨主字 + 浅暖描边 + 弱阴影，并在 shader material 显式锁定参数，避免主题与材质不一致。
- 已加入对话截图调色辅助：`F12` / `P`（兼容 `Ctrl+Alt+Shift+F12` / `P`）在对话显示时保存 `user://dialogue_preview.png`，编辑器下额外写入 `res://dialogue_preview.png`。
- 文本主色已按调色结果更新并冻结：`RGB(182,51,32)`（`#B63320`），描边/阴影暂不调整。
- 教程开场文案已更新为三行（`A/D移动`、`W跳跃`、`L攻击，先向右前进。`），并去掉“教学：”前缀（`story_data/section0_tutorial.json`）。
- 第一章剧情数据化已推进：`section1_1`、`section1_2` 新增进场触发器并改为读取 `story_data/*.json`（`stages/stage1/Section.gd`、`story_data/section1_1.json`、`story_data/section1_2.json`）。
- 战斗 BGM 已落地：`D:/download/cute_bass.mp3` 转码为 `assets/Audio/BGM/section_battle.ogg` 并可被 `Main.gd` 路由命中，版本 `bgm-battle-v2026-02-09-01`。
- 音频署名信息已统一收敛到 `docs/ATTRIBUTION.md`（唯一来源）。
- HUD 最小版已接入：`HP 条 + 物理/魔法格挡状态` 常驻显示（`ui/HUD.tscn`、`ui/HUD.gd`、`Main.tscn`）。
- `ui.hud_objective_panel` 已接入并完成素材适配（`300x156`），当前默认隐藏（简洁模式，后续可折叠展开）。
- Boss BGM 已落地：`D:/project/sucai/Lament of the War - MP3 Preview.mp3` 转码为 `assets/Audio/BGM/section_boss.ogg`，版本 `bgm-boss-v2026-02-09-01`，署名见 `docs/ATTRIBUTION.md`。

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
- [x] `StoryTrigger` 通用节点
- [x] `StoryEventRunner`（Autoload）
- [x] `StoryData`（JSON 数据驱动，教程对白已迁移到 `story_data/section0_tutorial.json`）

### M3 可发行 Demo 配套（未完成）

- [ ] 主菜单与完整流程入口
- [x] HUD（HP/格挡状态；目标提示面板已接入但默认隐藏）
- [ ] Demo 结算页与回环

## 3. 本周执行清单（2026-02-08 起）

1. 补齐 W1 缺口素材并接入：
   - `sfx.block_physical`（已由代码生成替代）
   - `sfx.block_magic`（已由代码生成替代）
   - `sfx.ui_next`（已由代码生成替代）
   - `portrait.narrator`（已到位并规范化为 256x256，采用双图拆分+合成回退）
2. 开始 W3 通用剧情架构（已完成）：
   - `StoryEventRunner` 最小可用版本（仅串行播放对白）
   - `StoryTrigger` 抽出，并替换教学关卡内硬编码触发
3. 建立每周固定回归：
   - 从入口到通关/切关全流程跑一轮，记录到本文件“回归记录”。

## 4. 阻塞与风险

- 外部音频资产已开始落地：`bgm.section_story`、`bgm.section_battle`、`bgm.section_boss` 已就绪，仍缺 `bgm.section_result`。
- 剧情系统目前偏场景脚本实现，若不尽快抽象为 `StoryTrigger/Runner/Data`，后续章节复制成本会升高。
- 文本风格统一已完成第一版，后续仍需在更多场景下做实机对比（明亮背景/低亮背景各一轮）。

## 5. 回归记录

### 2026-02-08

- 场景：教学关卡通关后切关。
- 预期：切换 Section 后不显示上一关遗留 DialogBox。
- 实际：`Main.unload_section()` 调用 `_hide_dialogue_ui()` 后隐藏成功。
- 结果：通过。

### 2026-02-09

- 场景：短 SFX 走代码生成（玩家动作 + 对话翻页）。
- 预期：跳跃/落地/挥砍/格挡与对话翻页可发声，且可并发叠加。
- 实际：`ProceduralSFX` 作为 Autoload 接入，`Player` 与 `DialogueUI` 已连接触发点。
- 结果：通过（已完成代码接入，待实机听感调参）。

## 6. 下次会话入口

- 优先处理：文本风格统一（中文字体 + 主题/shader）并行推进 BGM 资源补齐。
- 完成后同步更新：
  - `DEMO_RELEASE_PLAN.md` 的“当前现状”
  - `docs/integration_board.md` 的素材状态
