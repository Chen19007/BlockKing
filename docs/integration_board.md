# BlockKing 协作集成看板

更新时间：2026-02-09  
协作方式：你负责素材采购与处理，我负责代码接入与验证。

## 当前协作约定（2026-02-09 起）
- 短 SFX（点击/挥砍/命中/跳跃/落地）默认用代码生成，不再阻塞素材采购。
- BGM 与长音频继续走外部资源文件并按资产位接入。
- 本文档仅维护“资源协作状态与约定”，具体实现细节/回归记录请看 `PROGRESS.md`。

## 约定快照（避免后续遗漏）
- 已确认：`bgm.section_story` 允许保留轻微首尾留白（作为“呼吸感”），当前版本直接使用。
- 已确认：教学关冷却更长，正式关按难度配置返回冷却参数。
- 已确认：剧情对白逐步从场景硬编码迁移到 `story_data/*.json` 数据文件。
- 已实现：`Main.gd` 按 `section_id` 路由 BGM，缺失资源自动回退到 `bgm.section_story`。
- 已实现：BGM 切换带淡出/淡入，避免切关突兀。
- 已确认：文本风格统一走“项目内中文字体 + 轻量 shader/主题参数”，避免依赖系统字体。
- 已确认：对话文本采用高对比参数（深墨主字 + 浅暖描边 + 弱阴影），避免黄底场景发糊。
- 已实现：调色辅助截图快捷键 `F12` / `P`（也兼容 `Ctrl+Alt+Shift+F12` / `P`），对话显示时保存到 `user://dialogue_preview.png`，编辑器下额外保存 `res://dialogue_preview.png`。
- 已确认：当前文本主色冻结为 `RGB(182,51,32)`（`#B63320`），描边/阴影暂不调整，后续再细调。
- 已确认：教程开场文案去掉“教学：”前缀，改为三行动作提示，跳跃按键为 `W`。
- 已实现：`section1_1`、`section1_2` 新增 `TriggerIntro`，并从 `story_data/section1_1.json`、`story_data/section1_2.json` 读取进场对白。
- 已实现：`D:/download/cute_bass.mp3` 已转码并接入 `assets/Audio/BGM/section_battle.ogg`（版本：`bgm-battle-v2026-02-09-01`）。
- 署名信息统一收敛到 `docs/ATTRIBUTION.md`（唯一来源）。

## 并行开工任务（本轮）
- 你负责：
  `asset_id`: `font.ui_serif_cn`
  `路径`: `assets/Fonts/ui_serif_cn.otf`
  `建议`: 思源宋体（Noto Serif CJK / Source Han Serif）
  `用途`: 教程、剧情正文、系统提示主字体
- 你负责：
  `asset_id`: `font.ui_sans_cn`（可选）
  `路径`: `assets/Fonts/ui_sans_cn.ttf`（或 `.otf`）
  `建议`: 思源黑体（Noto Sans CJK / Source Han Sans）
  `用途`: 高密度 UI 文案（设置页/说明文字）
- 我负责：
  对话文本主题参数与 shader 落地：暖色文字、1px 描边、轻阴影、像素对齐。
- 我负责：
  完成后更新 `ui/DialogueUI.tscn`、`ui/DialogueUI.gd`、`PROGRESS.md`、本看板状态。

## 你下一步要找的素材（按此清单）
- `asset_id`: `bgm.section_battle`
  `路径`: `assets/Audio/BGM/section_battle.ogg`
  `规格`: `ogg`、循环、建议 `>= 60s`、峰值不高于 `-1 dB`
  `用途`: 普通战斗段落替换 `bgm.section_story`
- `asset_id`: `bgm.section_boss`
  `路径`: `assets/Audio/BGM/section_boss.ogg`
  `规格`: `ogg`、循环、建议 `>= 60s`、峰值不高于 `-1 dB`
  `用途`: Boss 段落音乐
- `asset_id`: `bgm.section_result`
  `路径`: `assets/Audio/BGM/section_result.ogg`
  `规格`: `ogg`、循环可选、建议 `30s~90s`、峰值不高于 `-1 dB`
  `用途`: 结算与过渡页音乐

## 状态定义
- `todo`：未开始
- `in_review`：已有候选，待确认
- `ready`：素材已放到目标路径
- `integrated`：代码已接入并在场景验证

## 每日同步模板
- 你给我：`asset_id + 文件路径 + 是否最终版`
- 我给你：`asset_id + 接入状态 + 是否通过`

## 第一批资源位（W1）
| asset_id | 截止 | 状态 | 备注 |
|---|---|---|---|
| `ui.dialog_box` | W1 | integrated | 已检测到 `assets/UI/dialog_box.png`，尺寸 `683x233` |
| `ui.dialog_name_plate` | W1 | ready | 已放置并规范到 `256x64` |
| `ui.hud_hp_bar` | W1 | ready | 外框层，已规范到 `256x48` |
| `ui.hud_hp_fill` | W1 | ready | 填充层，使用 `assets/UI/hud_hp.png`，已规范到 `256x48` |
| `ui.hud_guard_physical` | W1 | ready | 已放置并规范到 `48x48` |
| `ui.hud_guard_magic` | W1 | ready | 已放置并规范到 `48x48` |
| `vfx.block_physical_spark` | W1 | integrated | 已切为 4 帧并接入格挡触发（12fps） |
| `vfx.block_magic_shield` | W1 | integrated | 临时 4 帧接入格挡触发（12fps，后续可补到 6-10 帧） |
| `sfx.block_physical` | W1 | integrated | 已由 `ProceduralSFX` 代码生成（可选采样替换） |
| `sfx.block_magic` | W1 | integrated | 已由 `ProceduralSFX` 代码生成（可选采样替换） |
| `sfx.ui_next` | W1 | integrated | 已由 `ProceduralSFX` 代码生成（可选采样替换） |
| `bgm.section_story` | W2 | integrated | 已接入 `Main.gd` 全局播放，署名见 `docs/ATTRIBUTION.md` |
| `portrait.narrator` | W1 | ready | 已规范为 `256x256`，合成回退图可用 |
| `portrait.narrator_frame` | W1 | ready | 头像外框，已规范为 `256x256` |
| `portrait.narrator_character` | W1 | ready | 头像角色主体，已规范为 `256x256` |
| `bgm.section_battle` | W2 | integrated | 已由 `D:/download/cute_bass.mp3` 转码接入，版本 `bgm-battle-v2026-02-09-01` |
| `bgm.section_boss` | W2 | todo | 路由已就绪，资源到位后自动切换 |
| `bgm.section_result` | W2 | todo | 路由已就绪，资源到位后自动切换 |
| `font.ui_serif_cn` | W2 | integrated | 已接入 `assets/Fonts/ui_serif_cn.otf`，文本主题自动加载生效 |
| `font.ui_sans_cn` | W2 | todo | 可选，待字体文件到位后接入高密度 UI 文案 |

## 素材落地路径速查（不用看 yaml）
| asset_id | 成品路径 |
|---|---|
| `ui.dialog_box` | `assets/UI/dialog_box.png` |
| `ui.dialog_name_plate` | `assets/UI/dialog_name_plate.png` |
| `ui.hud_hp_bar` | `assets/UI/hud_hp_bar.png` |
| `ui.hud_hp_fill` | `assets/UI/hud_hp.png` |
| `ui.hud_guard_physical` | `assets/UI/hud_guard_physical.png` |
| `ui.hud_guard_magic` | `assets/UI/hud_guard_magic.png` |
| `vfx.block_physical_spark` | `assets/VFX/block_physical_spark/` |
| `vfx.block_magic_shield` | `assets/VFX/block_magic_shield/` |
| `sfx.block_physical` | `system/ProceduralSFX.gd`（默认）或 `assets/Audio/SFX/block_physical.ogg`（可选） |
| `sfx.block_magic` | `system/ProceduralSFX.gd`（默认）或 `assets/Audio/SFX/block_magic.ogg`（可选） |
| `sfx.ui_next` | `system/ProceduralSFX.gd`（默认）或 `assets/Audio/SFX/ui_next.ogg`（可选） |
| `bgm.section_story` | `assets/Audio/BGM/section_story.ogg` |
| `bgm.section_battle` | `assets/Audio/BGM/section_battle.ogg` |
| `bgm.section_boss` | `assets/Audio/BGM/section_boss.ogg` |
| `bgm.section_result` | `assets/Audio/BGM/section_result.ogg` |
| `portrait.narrator` | `assets/Story/portrait_narrator_character.png` + `assets/Story/portrait_narrator_frame.png`（主用） |
| `portrait.narrator` | `assets/Story/portrait_narrator.png`（合成回退） |
| `portrait.narrator_frame` | `assets/Story/portrait_narrator_frame.png` |
| `portrait.narrator_character` | `assets/Story/portrait_narrator_character.png` |
| `font.ui_serif_cn` | `assets/Fonts/ui_serif_cn.otf` |
| `font.ui_sans_cn` | `assets/Fonts/ui_sans_cn.ttf`（或 `.otf`） |

## 内部有效像素尺寸标准（用于你处理素材）
说明：这是“素材内容实际占用像素”，不是画布尺寸。

| 类型 | 画布尺寸 | 内部有效像素建议 |
|---|---|---|
| 玩家/敌人主体 | `100x100` | 宽 `14~18`，高 `22~28` |
| 近战动作扩展 | `100x100` | 相对主体外扩 `4~10` |
| 物理箭 | `32x32` | 长 `10~16`，厚 `2~4` |
| 魔法弹核心 | `100x100` 或 `32x32` | 核心 `8~14`，特效外圈 `16~24` |
| 对话头像 | `256x256` | 主体占宽 `65%~80%` |

对齐规则（最关键）：
- 同角色所有帧“脚底基线”保持一致。
- 同角色所有帧“躯干中心”尽量不漂移。
- 箭默认朝右，代码自动镜像。

## 不阻塞规则
- 你先放图，我先接入；缺音频不阻塞当前开发。
- 新素材到位后只替换文件，不改玩法逻辑。
