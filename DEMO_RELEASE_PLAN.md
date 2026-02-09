# BlockKing 可发行 Demo 计划表（Section 内剧情版）

更新时间：2026-02-09

## 1. 目标定义（本次 Demo）

### 1.1 Demo 发行目标
- 在 15~30 分钟内完整体验核心循环：移动/跳跃/攻击/物理格挡/魔法格挡。
- 完成 1 个章节（多个 Section）且剧情在 Section 内触发，不走独立过场系统。
- 满足 Steam Demo 与商店素材最小要求（胶囊图、截图、库素材等）。

### 1.2 成功标准（验收）
- 玩家可从主菜单进入 Demo，并顺序通关至少 3 个剧情 Section（含 1 个 Boss Section）。
- 每个 Section 都有明确剧情触发点（进场、战后、离场），可跳过、可回放日志。
- 具备基础 UI、音效、VFX、失败/重生反馈。
- 可导出可分发构建（Web/Windows 至少一种）并完成一轮手动验收。

---

## 2. 当前现状（基于仓库事实）

### 2.1 已有能力
- 关卡流：`Main.gd` + `GameFlowConfig.gd` 已支持 Section 加载/切换与重生。
- 当前关卡流配置：`stage0` 下 `section0_tutorial`，`stage1` 下 `section1_1`、`section1_2`（`system/GameFlowConfig.gd`）。
- 玩家已具备：移动、跳跃、攻击、物理格挡、魔法格挡（`player/Player.gd`）。
- 已有敌人与投射物链路，且 HitBox/HurtBox 已支持方向参数传递。

### 2.2 资源现状
- 资源文件主要是 `.png/.import`（图片资源完整度高）。
- 具体资源接入状态以 `docs/integration_board.md` 为准。
- 具体实现进展与回归记录以 `PROGRESS.md` 为准。
- 版权/署名信息以 `docs/ATTRIBUTION.md` 为准（唯一来源）。

### 2.3 管理现状（本次刷新）
- 已建立长期协作跟踪基线：`DEMO_RELEASE_PLAN.md`（计划）、`PROGRESS.md`（进度）、`docs/integration_board.md`（素材接入）。
- 素材版权/署名信息统一维护在 `docs/ATTRIBUTION.md`（唯一来源），其他文档仅保留引用。
- 后续默认按周更新“完成项/阻塞项/下一步”，避免只写实现不做管理。

---

## 3. 建议采购素材清单（按优先级）

说明：以下是“为了能发行 Demo”的最小采购集，不是全量美术终稿。

### 3.1 P0（必须先买）
| 类别 | 建议规格 | 用途 | 当前状态 |
|---|---|---|---|
| 环境 Tileset + Decor | 1 套统一风格（地表/地下/建筑至少 3 主题） | 做出可读关卡与章节区分 | 缺 |
| UI 套件（像素风） | HP/护盾条、按钮、面板、对话框、图标 | 主HUD、剧情对话、暂停菜单 | 缺 |
| SFX 包 | 攻击/格挡/受击/脚步/跳跃/UI 点击/环境 | 提升打击感与反馈 | 部分替代（短 SFX 代码生成） |
| VFX 包（像素） | 火花、护盾、命中、消散、魔法轨迹 | 区分物理/魔法战斗反馈 | 缺 |
| 字体授权 | 中文可商用像素字体至少 1 套 | UI 与剧情文本统一可读性 | 待确认 |

### 3.2 P1（建议尽快）
| 类别 | 建议规格 | 用途 | 当前状态 |
|---|---|---|---|
| BGM 包 | 战斗/探索/Boss/结算最少 4 首可循环 | 章节氛围与节奏控制 | 缺 |
| 章节插图/关键视觉 | 2~4 张（开场/转折/Boss） | 商店图与章节转场强化 | 缺 |
| 商店素材模板 | Steam 胶囊图模板 PSD/PNG | 加快商店图制作 | 缺 |

### 3.3 P2（可后置）
| 类别 | 建议规格 | 用途 | 当前状态 |
|---|---|---|---|
| 角色语音包 | 受击/吼声/提示短语 | 增强角色个性 | 可后置 |
| 额外怪物包 | 新敌人与变体动作 | 延长 Demo 重玩性 | 可后置 |

---

## 4. 还需实现的功能（从“可玩”到“可发行”）

### 4.1 核心功能（必须）
1. 主菜单与流程控制  
   - 新游戏、继续（可选）、设置、退出。
2. UI/HUD  
   - 血量、格挡状态（物理/魔法）、章节目标提示、失败提示。
3. 敌人与波次编排工具化  
   - Section 内波次触发器（进入区域触发、清怪开门）。
4. Section 内剧情系统（本计划重点）  
   - 对话触发、条件门控、可跳过、日志记录。
5. 关卡收尾与 Demo 结算  
   - 通关页、再来一次、引导 Wishlist/关注（平台允许范围内）。

### 4.2 发行支持（必须）
1. 构建流水  
   - 至少 1 个稳定发布目标（Windows 或 Web）。
2. QA 回归清单  
   - 战斗、重生、Section 切换、剧情触发、输入设备。
3. 商店物料生产  
   - 胶囊图、截图、Logo、短描述、标签、预告片（可选但强烈建议）。

---

## 5. Section 内剧情实现方案（替代“过场剧情”）

## 5.1 架构设计
- `StoryTrigger`（场景节点）  
  - 进入区域触发/清怪触发/交互触发。
- `StoryEventRunner`（Autoload）  
  - 负责串行播放事件、暂停玩家输入、恢复控制权。
- `StoryData`（JSON/Resource）  
  - 每个 Section 的剧情步骤数据化，避免硬编码。
- `DialogueUI`（CanvasLayer）  
  - 打字机、头像、名字、跳过、快进、历史记录。

### 5.2 数据结构（建议）
每个 Section 对应一组事件：
- `on_enter`：进场短对白（2~4句）。
- `on_wave_clear`：清怪后推进剧情。
- `on_exit`：离开前收束，设置下一 Section 目标。

示例字段：
- `id`, `speaker`, `text`, `portrait`, `sfx`, `wait_input`, `auto_next`, `set_flag`, `require_flag`。

### 5.3 关键规则
- 剧情可跳过，但关键状态变化不可跳过（例如开门、给钥匙、改目标）。
- 同一触发器只触发一次（除非显式配置可重复）。
- 战斗中默认不弹剧情；可使用“清怪后触发”避免打断节奏。

---

## 6. 8 周实现排期（可直接执行）

| 周次 | 目标 | 主要产出 | 验收点 |
|---|---|---|---|
| W1 | 锁定 Demo 范围 + 采购 P0 | 素材采购清单、章节范围冻结 | 范围不再扩张 |
| W2 | UI/HUD 骨架 + 主菜单 | 可用菜单与基础HUD | 可从菜单进入并玩到结束 |
| W3 | Story 系统基础 | `StoryTrigger` + `StoryEventRunner` + `DialogueUI` | Section 进场对白可触发 |
| W4 | 波次与剧情联动 | 清怪触发剧情、门控推进 | 三类触发（进场/清怪/离场）跑通 |
| W5 | 关卡内容填充 | 至少 3 个剧情 Section | 15~30 分钟可通关 |
| W6 | 反馈强化 | SFX/VFX 接入与调优 | 打击感与可读性达标 |
| W7 | 发行准备 | 商店素材、文案、截图、构建脚本 | 可提交审核包 |
| W8 | QA 与打磨 | 缺陷修复、性能与输入回归 | 发布候选版本冻结 |

---

## 7. 商店与发行物料清单（Steam 方向）

基于 Steamworks 官方图形资产文档，至少准备：
- Store Capsules：Header / Small / Main / Vertical
- Screenshots：16:9，至少 1920x1080
- Library Assets：Library Capsule / Hero / Logo / Header
- Community/Client Icons

建议额外准备：
- 30~60 秒 Gameplay Trailer（可后置，但对转化通常有帮助）。

---

## 8. 执行顺序建议（你下一步就做这个）

1. 先买 P0：`环境Tileset + UI + SFX + VFX + 字体`。  
2. 同步启动 Section 内剧情系统（W3），不要等到关卡做完再补。  
3. 先做 1 章完整闭环，再复制模板扩展到后续章节。  
4. 每周固定一次“从主菜单打到结算页”的全流程回归。  

---

## 9. 依据来源

### 仓库内依据（读取时间：2026-02-08）
- `system/GameFlowConfig.gd`
- `Main.gd`
- `PROGRESS.md`
- `DESIGN.md`
- `PLAN.md`
- 资源扫描结果：`assets` 目录扩展名统计（主要为 `.png/.import`）

### 官方文档依据（访问时间：2026-02-08）
- Steamworks Graphical Assets Overview: https://partner.steamgames.com/doc/store/assets
- Steamworks Graphical Asset Rules: https://partner.steamgames.com/doc/store/assets/rules?language=english
- Steamworks Applications（Demo 类型说明）: https://partner.steamgames.com/doc/store/application

> 说明：关于“需要采购哪些素材”的部分，属于在仓库现状与官方发行物料约束下的实施推断，不是对具体商店商品的推荐。
