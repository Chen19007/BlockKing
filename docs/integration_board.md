# BlockKing 协作集成看板

更新时间：2026-02-09  
协作方式：你负责素材采购与处理，我负责代码接入与验证。

## 当前协作约定（2026-02-09 起）
- 短 SFX（点击/挥砍/命中/跳跃/落地）默认用代码生成，不再阻塞素材采购。
- BGM 与长音频继续走外部资源文件并按资产位接入。

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
| `portrait.narrator` | W1 | todo | 旁白头像 |

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
| `portrait.narrator` | `assets/Story/portrait_narrator.png` |

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
