# BlockKing 设计文档（关卡流程与素材规划）

## 1. 核心卖点
- 主角只能“格挡”，通过节奏、方向与时机把敌人的攻击反制回去。
- 叙事驱动：骑士团与怪物勾结，主角逐步发现真相并反抗。
- 资源复用：使用现有像素素材，通过色相/明度/饱和度微调生成多种敌人变体。

## 2. 美术基调与配色规则（全局）
- **主角（基于 `Knight Templar.aseprite`）**：
  - 盔甲主色：冷白/银蓝（高明度、低饱和）
  - 披风/点缀：青蓝或浅天蓝，强调“正统骑士”
  - 盾面：亮银 + 蓝纹
- **骑士团（低阶人类敌）**：
  - 盔甲主色：铁灰
  - 点缀色：暗红/暗金，显“腐化”
- **亡灵系**：
  - 骨骼：偏黄灰
  - 点缀：病绿/幽蓝
- **兽人系**：
  - 皮肤：橄榄绿/暗褐
  - 点缀：赤铜、铁锈
- **野兽系**：
  - 皮毛：深棕/灰
  - 点缀：猩红眼或战纹
- **施法者**：
  - 服装：深灰/暗紫/墨绿（任选其一作为主色）
  - 魔法光效：青蓝或幽绿（与主角区分）

> 同一素材通过调整色相（±15~30°）、明度（±10~20%）、饱和度（±10~25%）即可形成“不同角色”。

## 3. 玩法补充：物理格挡 vs 魔法格挡
- **物理格挡（短按/轻按）**
  - 面向正确方向、在攻击命中前短窗口内触发。
  - 成功后将近战/投射物弹开，完美格挡可反击回弹伤害。
  - 主要消耗耐力（或守势值），重击会造成更高消耗与硬直。
- **魔法格挡（长按/持续姿态）**
  - 进入“魔法护盾姿态”，可吸收/折射法术。
  - 持续消耗“护盾能量”（独立于耐力），完美格挡才能反射回去。
  - 施法连段会逼迫玩家在“持续护盾”与“时机格挡”间切换。
- **反馈区分**
  - 物理：金属火花、清脆音效、短硬直。
  - 魔法：护盾泛光、能量涟漪、轻微后退。
- **节奏目标**
  - 早期仅物理格挡教学，中期引入混合敌人，后期以多段法术压迫作为终局考验。
- **对称关系与主角识别**
  - 物理/魔法是第一层对称；近战/远程是第二层对称。
  - 主角只区分“物理 vs 魔法”，不区分“近战 vs 远程”；距离只影响站位与时机。
  - 物理格挡覆盖物理近战与物理远程；魔法格挡覆盖魔法近战与魔法远程。

对称矩阵：

| 攻击属性\距离 | 近战 | 远程 |
|---|---|---|
| 物理 | 物理近战 | 物理远程 |
| 魔法 | 魔法近战 | 魔法远程 |

## 4. 关卡流程（主线 6 章）

### 第1章：边境村落·试炼
- **剧情目的**：开场教学，强调“只能格挡”的玩法。
- **怪物配置**
  - 小怪A：`Slime.aseprite`（蓝灰→淡绿，营造低威胁）【物理】
  - 小怪B：`Skeleton.aseprite`（骨白→黄灰，点缀病绿）【物理】
- **Boss**：`Skeleton Archer.aseprite`【物理远程】
  - 调色：弓与护甲偏幽蓝，突出远程压制
- **线索**：掉落“骑士团军械编号”的箭矢。
- **关卡结构（房间/波次/事件表）**

| 房间 | 波次 | 敌人配置 | 事件/目的 |
|---|---|---|---|
| 1 | 1 | Slime x2 | 基础移动与正面物理格挡教学 |
| 2 | 2 | Slime x3 → Skeleton x2 | 反击提示与节奏切换 |
| 3 | 1 | Skeleton x3 | 方向格挡强化 |
| 4 | 1 | Skeleton Archer x1（Boss） | 远程反射教学，掉落箭矢线索 |

### 第2章：旧矿井·失落武库
- **剧情目的**：主角遭伏击，武器遗失，正式进入“纯盾”战斗。
- **怪物配置**
  - 小怪A：`Armored Skeleton.aseprite`（铁锈红 + 黄灰骨）【物理】
  - 小怪B：`Greatsword Skeleton.aseprite`（暗铁灰 + 冰蓝点缀）【物理重击】
- **Boss**：`Armored Axeman.aseprite`【物理重击】
  - 调色：盔甲铁灰→深黑红，斧刃带暗红光
- **线索**：矿井深处出现骑士团补给箱。
- **关卡结构（房间/波次/事件表）**

| 房间 | 波次 | 敌人配置 | 事件/目的 |
|---|---|---|---|
| 1 | 1 | Armored Skeleton x2 | 伏击，触发“武器遗失” |
| 2 | 2 | Armored Skeleton x3 → Greatsword Skeleton x1 | 重击格挡教学 |
| 3 | 2 | Greatsword Skeleton x2 → Armored Skeleton x2 | 狭窄通道，连续格挡 |
| 4 | 1 | Armored Skeleton x3 | 发现补给箱（线索） |
| 5 | 1 | Armored Axeman x1（Boss） | 斧击节奏压迫 |

### 第3章：荒野关隘·兽潮
- **剧情目的**：第一次大规模近战压制，训练连挡反击。
- **怪物配置**
  - 小怪A：`Orc.aseprite`（橄榄绿→暗褐，獠牙偏黄）【物理】
  - 小怪B：`Archer.aseprite`（人类弓手，衣服深灰+暗红）【物理远程】
- **Boss**：`Orc rider.aseprite`【物理冲锋】
  - 调色：坐骑偏深棕，兽人盔甲偏赤铜
- **线索**：兽人掉落刻有骑士团徽记的护甲碎片。
- **关卡结构（房间/波次/事件表）**

| 房间 | 波次 | 敌人配置 | 事件/目的 |
|---|---|---|---|
| 1 | 1 | Orc x3 | 连挡节奏入门 |
| 2 | 2 | Orc x2 + Archer x1 → Orc x2 | 远程反射与近战混合 |
| 3 | 2 | Orc x3 + Archer x2 → Orc x2 | 开阔地群战 |
| 4 | 1 | Orc rider x1（Boss） | 冲锋格挡窗口考验 |

### 第4章：被遗弃的圣堂·谎言
- **剧情目的**：与“人类敌人”首次正面冲突，并引入魔法格挡。
- **怪物配置**
  - 小怪A：`Soldier.aseprite`（铁灰 + 暗红披风）【物理】
  - 小怪B：`Swordsman.aseprite`（铁灰 + 暗金点缀）【物理快攻】
  - 小怪C：`Priest.aseprite`（深灰长袍 + 幽蓝光）【魔法】
- **Boss**：`Knight.aseprite`【物理强对抗】
  - 调色：黑铁盔甲 + 暗红披风（与主角形成强烈反差）
- **线索**：圣堂密室的记录揭示“骑士团伪造怪物威胁”。
- **关卡结构（房间/波次/事件表）**

| 房间 | 波次 | 敌人配置 | 事件/目的 |
|---|---|---|---|
| 1 | 1 | Soldier x2 | 人类敌人初见 |
| 2 | 2 | Soldier x3 → Swordsman x1 | 速度差异适应 |
| 3 | 2 | Swordsman x2 + Soldier x2 → Priest x1 | 第一次魔法格挡教学 |
| 4 | 1 | Soldier x4 | 密室开启，获得线索 |
| 5 | 1 | Knight x1（Boss） | 盾对盾的强对抗 |

### 第5章：月影森林·兽化诅咒
- **剧情目的**：敌人节奏加快，加入连段压迫。
- **怪物配置**
  - 小怪A：`Werewolf.aseprite`（灰黑毛 + 红眼）【物理快攻】
  - 小怪B：`Lancer.aseprite`（人类骑士，盔甲暗蓝灰 + 暗红纹）【物理突刺】
- **Boss**：`Werebear.aseprite`【物理重击】
  - 调色：深棕毛 + 暗绿战纹（强调厚重）
- **线索**：发现骑士团的“兽化实验”记录。
- **关卡结构（房间/波次/事件表）**

| 房间 | 波次 | 敌人配置 | 事件/目的 |
|---|---|---|---|
| 1 | 1 | Werewolf x2 | 快速连击适应 |
| 2 | 2 | Werewolf x3 → Lancer x1 | 长枪突刺格挡 |
| 3 | 2 | Lancer x2 + Werewolf x1 → Werewolf x2 | 方向切换压力 |
| 4 | 1 | Werewolf x3 | 发现“兽化实验”记录 |
| 5 | 1 | Werebear x1（Boss） | 重击与多段压迫 |

### 第6章：王城外环·审判
- **剧情目的**：揭露真相，面对骑士团高层（物理/魔法混合终局）。
- **怪物配置**
  - 小怪A：`Priest.aseprite`（深灰长袍 + 幽蓝光）【魔法】
  - 小怪B：`Elite Orc.aseprite`（赤铜盔甲 + 暗绿皮肤）【物理重击】
- **Boss**：`Wizard.aseprite`【魔法连段】
  - 调色：主袍黑紫，法术光效幽蓝
- **线索**：Boss 释放“真相幻象”，最终指向骑士团指挥官。
- **关卡结构（房间/波次/事件表）**

| 房间 | 波次 | 敌人配置 | 事件/目的 |
|---|---|---|---|
| 1 | 1 | Priest x2 | 反射法术教学（进阶） |
| 2 | 2 | Elite Orc x2 → Priest x1 | 近战与施法混合 |
| 3 | 2 | Elite Orc x3 + Priest x1 → Priest x2 | 组合节奏终局检验 |
| 4 | 1 | Elite Orc x2 | 前厅战，进入审判区域 |
| 5 | 1 | Wizard x1（Boss） | 幻象与终局揭露 |

## 5. 角色与素材分配（避免与主角冲突）
- **主角**：`Knight Templar.aseprite`（只用于主角）
- **骑士团敌人**：`Soldier.aseprite` / `Swordsman.aseprite` / `Knight.aseprite`
- **亡灵系**：`Skeleton.aseprite` / `Armored Skeleton.aseprite` / `Greatsword Skeleton.aseprite`
- **兽人系**：`Orc.aseprite` / `Elite Orc.aseprite` / `Orc rider.aseprite`
- **野兽系**：`Werewolf.aseprite` / `Werebear.aseprite`
- **人类远程**：`Archer.aseprite`
- **施法者**：`Priest.aseprite` / `Wizard.aseprite`

## 6. 色彩微调指引（示例）
- **同一人类骑士敌人**（`Soldier`/`Swordsman`）：
  - 变体A：铁灰 + 暗红披风（骑士团普通兵）
  - 变体B：铁灰 + 暗金纹（精锐护卫）
- **同一亡灵素材**（`Skeleton`）：
  - 变体A：骨黄 + 病绿（低阶）
  - 变体B：骨白 + 幽蓝（弓手/精英）
- **同一兽人素材**（`Orc`）：
  - 变体A：橄榄绿 + 铁锈红（普通）
  - 变体B：暗褐 + 赤铜（精英）

## 7. 叙事节奏与关卡节奏
- 前两章：教学与“失去武器”，强调物理格挡基础。
- 中期两章：揭露真相线索，首次引入魔法格挡。
- 末两章：物理与魔法混合压迫，完成叙事闭环。

---
如果要加支线或挑战关，可复用现有素材并通过极端调色（高对比/反相色）作为“幻境/试炼”主题。



## 8. 现有动作清单（Aseprite 标签）
- 说明：动作来自 .aseprite 的 tag 标签，帧区间为**包含**区间。

- `Archer.aseprite`: Idle, Walk, Attack01, Attack02, Hurt, Death
- `Armored Axeman.aseprite`: Idle, Walk, Attack01, Attack02, Attack03, Hurt, Death
- `Armored Orc.aseprite`: Idle, Walk, Attack01, Attack02, Attack03, Block, Hurt, Death
- `Armored Skeleton.aseprite`: Idle, Walk, Attack01, Attack02, Hurt, Death
- `Elite Orc.aseprite`: Idle, Walk, Attack01, Attack02, Attack03, Hurt, Death
- `Greatsword Skeleton.aseprite`: Idle, Walk, Attack01, Attack02, Attack03, Hurt, Death
- `Knight Templar.aseprite`: Idle, Walk01, Walk02, Attack01, Attack02, Attack03, Block, Hurt, Death
- `Knight.aseprite`: Idle, Walk, Attack01, Attack02, Attack03, Block, Hurt, Death
- `Lancer.aseprite`: Idle, Walk01, Walk02, Attack01, Attack02, Attack03, Hurt, Death
- `Orc rider.aseprite`: Idle, Walk, Attack01, Attack02, Attack03, Block, Hurt, Death
- `Orc.aseprite`: idle, walk, attack01, attack02, hurt, Death
- `Priest.aseprite`: Idle, Walk, Attack_with effect, Attack, Attack_effect, Heal_with effect, Heal, Heal_effect, Hurt, Death
- `Skeleton Archer.aseprite`: Idle, Walk, Attack, Hurt, Death
- `Skeleton.aseprite`: Idle, Walk, Attack01, Attack02, Block, Hurt, Death
- `Slime.aseprite`: Idle, Walk, Attack01, Attack02, Hurt, Death
- `Soldier.aseprite`: Idle, Walk, Attack01, Attack02, Attack03, Hurt, Death
- `Swordsman.aseprite`: Idle, Walk, Attack01, Attack02, Attack3, Hurt, Death
- `Werebear.aseprite`: Idle, Walk, Attack01, Attack02, Attack03, Hurt, Death
- `Werewolf.aseprite`: Idle, Walk, Attack01, Attack02, Hurt, Death
- `Wizard.aseprite`: Idle, Walk, Attack01_with effect, Attack01, Attack01_Effect, attack02_with effect, Attack02, Attack02_Effect, Hurt, DEATH

- **含 Block 动作的素材**：`Armored Orc.aseprite` / `Knight Templar.aseprite` / `Knight.aseprite` / `Orc rider.aseprite` / `Skeleton.aseprite`
- **含魔法/特效动作的素材**：`Priest.aseprite` / `Wizard.aseprite`

> 关卡与敌人设计建议：若需要敌人“举盾/格挡”的表现，请优先选择含 Block 标签的素材；魔法型敌人请使用带 effect 的攻击/治疗标签来区分“物理 vs 魔法格挡”。
