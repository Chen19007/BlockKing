# BlockKing 引用 instancing_starter 通用能力计划（最小集）

## 目标
- 复用 instancing_starter 的“关卡流程/Section 切换/重生点/传送点/基础相机限制”通用能力。
- Player 只保留：移动、跳跃、物理格挡、魔法格挡（不引入战斗/技能/数值系统）。
- 先搭起可跑通的关卡骨架，再逐步接入设计文档中的敌人/波次。

## 能力清单与来源映射
| 能力 | instancing_starter 参考 | 目标实现 | 处理方式 |
|---|---|---|---|
| 主流程（加载/卸载 Section） | `Main.gd`, `Main.tscn` | BlockKing 主流程 | 复用结构，删减存档/过场/复杂信号 |
| 关卡流程配置 | `system/GameFlowConfig.gd` | BlockKing 的关卡配置 | 复用 API 形态，简化为 stage/section 列表 |
| Section 基类 | `stages/*/Section.gd` | BlockKing Section 脚本 | 复用 respawn/camera 限制逻辑 |
| 传送点 | `buildings/Transport.gd/.tscn` | Section 末端传送 | 复用信号模式，保持触发切换 |
| 重生点 | `buildings/Checkpoint.gd/.tscn` | Player 生成点 | 复用生成流程，去掉无关逻辑 |
| NodeReady 同步 | `system/NodeReadyManager.gd` | 生成顺序管理 | 视需要保留（简化版亦可） |
| 相机范围 | Section + Player | 基础相机限制 | 可选（先做简版） |

## 最小集保留与删减
- **保留**：Main 关卡切换、GameFlowConfig、Section/Transport/Checkpoint。
- **删减**：存档系统（`SaveSystem`）、难度系统、Cutscene、敌人系统、复杂 Player 状态机。

## 实施步骤（计划表）
| 步骤 | 目标 | 参考/来源 | 输出 |
|---|---|---|---|
| 1 | 搭建 BlockKing 主流程骨架 | `Main.gd`, `Main.tscn` | 新 `Main.gd` + `Main.tscn`（可加载/切换 Section） |
| 2 | 迁移关卡配置结构 | `system/GameFlowConfig.gd` | `system/GameFlowConfig.gd`（仅 stage/section） |
| 3 | 建立 Section 基类 | `stages/*/Section.gd` | `stages/stage1/Section.gd`（respawn + camera） |
| 4 | 加入 Transport/Checkpoint | `buildings/Transport.*`, `buildings/Checkpoint.*` | `buildings/Transport.tscn`, `buildings/Checkpoint.tscn` |
| 5 | 实现最小 Player | `player/player.gd`, `Player.tscn` | `player/Player.gd`（移动/跳跃/物理格挡/魔法格挡） |
| 6 | 跑通最小关卡 | `stages/stage1/section1_1.tscn` | 简单平台 + Checkpoint + Transport |
| 7 | 对接设计文档节奏 | `DESIGN.md` | 关卡布置（按房间/波次扩展） |

## 需要从 instancing_starter 拿的具体文件
- `Main.gd`, `Main.tscn`
- `system/GameFlowConfig.gd`
- `system/NodeReadyManager.gd`（如需）
- `stages/*/Section.gd`
- `buildings/Transport.gd`, `buildings/Transport.tscn`
- `buildings/Checkpoint.gd`, `buildings/Checkpoint.tscn`

## 关键适配点
- **Player 生成**：保留 “Main → Checkpoint.spawn_player() → Section/Player” 的链路，但删去存档/血量逻辑。
- **关卡切换**：保留 `Transport` 发信号给 `Main` 的模式，简化 `switch_section()`。
- **物理/魔法格挡**：Player 只判断攻击类型，不区分近战/远程。

## 风险与验证
- 关卡切换是否正确释放旧 Section、清理 Player。
- 传送点是否在最后一个 Section 正确触发结束逻辑（或进入下一章）。
- Player 生成与输入是否在每次切换后正常工作。

## 素材缺口与补齐清单（当前最小集）
### 已有
- 角色帧已导出：`assets/<sprite>/<tag>/<frame>.png`

### 缺口（需要占位或补齐）
- 场景/地形：tileset、平台、背景层
- 交互可视化：Checkpoint/Transport 的标识
- UI：血量 + 物理/魔法护盾、提示文本、暂停菜单
- VFX：物理格挡火花、魔法护盾泛光、受击/死亡
- SFX：格挡（金属/魔法）、跳跃/落地、受击
- 投射物/法术：基础远程/魔法视觉

### 补齐策略
- 第一阶段：用占位（ColorRect/Sprite/instancing_starter 资产）先跑通流程
- 第二阶段：按 DESIGN.md 替换为正式素材（物理 vs 魔法配色）
- 第三阶段：强化反馈（VFX+SFX）优先格挡/反射/受击

## 总体推进顺序（含素材）
1) 主流程 + Section 切换骨架
2) 最小 Player（移动/跳跃/物理格挡/魔法格挡）
3) 关卡骨架（Checkpoint + Transport + 简单平台）
4) UI/反馈占位
5) 替换正式素材与特效
6) 按 DESIGN.md 填充敌人与波次

