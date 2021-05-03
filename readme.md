### ECS框架
先了解数据驱动编程的思想，ECS是什么。

### 基本的单位
一个战斗系统的最基本单元就是一个单位，我们可以利用Lua表的特性创建一个纯数据表来表示一个单位的信息。

在`battle_meta.lua`中，我们定义了角色的基础信息

在`battle_entity.lua`中，我们定义了一个创建单位数据表的方法

当我们创建出这个角色时，他是游离的，并没有实际的意义，所以我们需要构建一个环境来赋予他实际的意义。

在`battle_context.lua`中，我们定义了如何构建一个环境。

### 基本的单位行为
通常我们会使用FSM状态机去维护一个单位的行为逻辑。但在ECS中，system已经做到了类似的功能，所以本质上我们只需要将相应的行为component添加到entity中就可以让对应的行为system操作他。

此外，我们还需要一个规划器，根据单位的状态来决定为entity动态添加行为。

#### 规划器
创建一个通用的规划器需要：

- flags状态标识符
- actions行为表
- priority优先级对比函数

而一个行为需要：

- value价值
- cost消耗
- precondition前置条件
- priority优先级

我们可以在`ai.lua`中看到如何构建一个自动战斗的AI

* Planner是一个简单的规划AI模型，更复杂的可以参考GOAP。

### 伤害
伤害处理是需要根据游戏类型来定义的，通常情况下会有以下流程

- 额外攻击力
- 伤害输出调整
- 伤害格挡
- 伤害输入调整
- 末端处理

