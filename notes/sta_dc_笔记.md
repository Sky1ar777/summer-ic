# STA 静态时序分析 + DC 综合入门 — 理论笔记

> 2026/6/10 · Week3 · 面试必考

---

## 第一部分：逻辑综合基础

### 1.1 综合（Synthesis）是什么？

```
RTL代码 (Verilog)
    ↓  read_verilog
    ↓  elaborate（解析）
    ↓  compile（映射到标准单元库）
门级网表 (Netlist)  ← 由 AND、OR、DFF 等基本单元组成
```

综合工具读 Verilog，输出**由标准单元库里的基本单元组成的网表**。

### 1.2 综合的三要素

```
综合 = 面积(Area) + 速度(Timing) + 功耗(Power) 的权衡
                       ↕
                  不可能三角：优化一个，另外两个变差
```

| 目标 | 做法 | 代价 |
|------|------|------|
| 更快 | 用大驱动单元、并行化 | 面积大、功耗高 |
| 更小 | 资源共享、用小驱动单元 | 速度慢 |
| 更低功耗 | 门控时钟、低电压单元 | 面积/速度受影响 |

### 1.3 标准单元库

综合工具没法凭空产生逻辑——它需要**标准单元库**作为"积木"：

```
标准单元库包含：
  AND2_X1   — 2输入与门，小驱动
  AND2_X4   — 2输入与门，大驱动（面积大，速度快）
  DFF_X1    — D触发器，小驱动
  INV_X1    — 反相器
  ...
  每个单元都带有：面积、延迟、功耗等参数
```

---

## 第二部分：时序分析基础

### 2.1 时序路径

一个数字芯片里，所有路径都可以归为 4 类：

```
① 输入引脚 → D触发器（Input to FF）
② D触发器 → D触发器（FF to FF）← 最常见
③ D触发器 → 输出引脚（FF to Output）
④ 输入引脚 → 输出引脚（Input to Output）
```

### 2.2 建立时间（Setup Time）

**定义**：数据在时钟沿来之前，必须稳定的最短时间。

```
clk  ▁▁▁▁▁▁▁▁▁▔▔▔▔▔▔▔▔▔▔
                     ↑ 时钟沿
D    ▔▔▔▔▔▔▔▔▁▁▁▁▁▁▁▁▁▁
             ↑
         建立时间窗口（数据必须在此时之前稳定）
```

**建立时间约束公式（最核心）：**

```
Tclk ≥ Tck2q + Tcomb + Tsu - Tskew
```

| 符号 | 含义 |
|------|------|
| Tclk | 时钟周期 |
| Tck2q | 触发器的时钟到输出延迟 |
| Tcomb | 组合逻辑延迟 |
| Tsu | 建立时间 |
| Tskew | 时钟偏斜（可正可负） |

**建立时间违例 = 组合逻辑太长 → 降频或流水线**

### 2.3 保持时间（Hold Time）

**定义**：数据在时钟沿之后，必须稳定的最短时间。

```
clk  ▁▁▁▁▁▁▁▁▁▔▔▔▔▔▔▔▔▔▔
                     ↑ 时钟沿
D    ▔▔▔▔▔▔▔▔▁▁▁▁▁▁▁▁▁▁
                       ↑
                   保持时间窗口（数据在此之后才能变）
```

**保持时间约束公式：**

```
Tck2q + Tcomb > Thold + Tskew
```

**保持时间违例 = 数据跑太快 → 加缓冲器（延迟）**

### 2.4 Setup vs Hold 对比

| | 建立时间（Setup） | 保持时间（Hold） |
|--|-----------------|-----------------|
| 违例原因 | 数据**到太晚** | 数据**跑太快** |
| 修复方法 | 降频/流水线/优化组合逻辑 | 加缓冲器/增大负载 |
| 与频率关系 | 直接相关（频率越高越容易违例） | 与频率无关 |
| 温度影响 | 高温更容易违例 | 低温更容易违例 |

---

## 第三部分：时序约束 SDC

### 3.1 什么是 SDC

SDC（Synopsys Design Constraints）是告诉综合工具**时序要求**的脚本语言。

### 3.2 最常用的 SDC 命令

```tcl
# 定义时钟
create_clock -name sysclk -period 10 [get_ports clk]
#                   周期10ns = 100MHz

# 生成时钟（分频后的时钟）
create_generated_clock -name clk_div -divide_by 2 \
    -source [get_ports clk] [get_pins u_div/clk_out]

# 输入延迟
set_input_delay -clock sysclk -max 5 [get_ports data_in]

# 输出延迟
set_output_delay -clock sysclk -max 6 [get_ports data_out]

# 伪路径（跨时钟域路径，不用检查时序）
set_false_path -from [get_clocks clkA] -to [get_clocks clkB]

# 多周期路径
set_multicycle_path -setup 2 -from [get_pins u_div/count_reg]
```

### 3.3 以 uart_tx 为例的 SDC

```tcl
create_clock -name sysclk -period 20 [get_ports clk]  # 50MHz
set_input_delay -clock sysclk -max 10 [get_ports data_in]
set_input_delay -clock sysclk -max 8  [get_ports tx_start]
set_output_delay -clock sysclk -max 10 [get_ports tx]
```

---

## 第四部分：DC 综合流程

### 4.1 完整 DC 脚本

```tcl
# 1. 设置库路径
set target_library  "gsclib045.lib"
set link_library    "* $target_library"
set synthetic_library "dw_foundation.sldb"

# 2. 读入RTL
analyze -format verilog {counter.v clk_divider.v}
elaborate counter
current_design counter

# 3. 施加约束
create_clock -name clk -period 20 [get_ports clk]
set_input_delay 5 -clock clk [all_inputs]
set_output_delay 5 -clock clk [all_outputs]

# 4. 综合
compile -map_effort medium

# 5. 生成报告
report_timing > reports/timing.rpt
report_area   > reports/area.rpt
report_power  > reports/power.rpt

# 6. 输出网表
write -format verilog -hierarchy -output output/counter_synth.v
write_sdc output/counter_sdc.sdc
```

### 4.2 DC 综合后的输出

```
counter_synth.v    — 门级网表（全是AND/OR/DFF）
counter_sdc.sdc    — 输出约束
timing.rpt         — 时序报告
area.rpt           — 面积报告
```

---

## 第五部分：STA 常见面试题

### Q1: Setup 违例怎么修？
```
① 降频（最简单但性能下降）
② 流水线（切分组合逻辑）
③ 优化组合逻辑（减少级数）
④ 减少时钟偏斜
```

### Q2: Hold 违例怎么修？
```
① 加缓冲器（增加组合逻辑延迟）
② 增大负载
③ 不能用降频（Hold和频率无关！）
```

### Q3: 为什么 Hold 违例在低速下也会出现？
```
保持时间检查的是：下一个时钟沿之前，数据不能太快变化。
跟时钟周期长短无关。
```

### Q4: 什么是 OCV（On-Chip Variation）？
```
芯片不同位置，工艺偏差不同 → 同一单元延迟不同
OCV = Derate 系数（比如 1.1）来模拟最差情况
```

### Q5: 什么是 CRPR（Clock Reconvergence Pessimism Removal）？
```
分叉的时钟路径最后汇合到同一个点，一部分延迟被共享了
CRPR 去掉这部分"悲观"估算
```

---

## 总结

| 概念 | 一句话 |
|------|--------|
| 综合 | RTL → 门级网表 |
| 建立时间 | 数据来的不能太晚 |
| 保持时间 | 数据变的不能太快 |
| SDC | 告诉工具你的时序要求 |
| Setup违例 | 降频或流水线 |
| Hold违例 | 加缓冲器 |
| OCV | 芯片内工艺偏差 |
| CRPR | 去掉悲观估算 |

---

> **开学实操预告**：到时候我会帮你写完整的 DC 脚本和 SDC 约束，用你写的 uart_tx 或 counter 做综合练习。
