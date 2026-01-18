# indicator4cj.valuation - 估值计算包

## 版本
v1.0.0

## 包简介
`valuation` 包提供了基础的金融估值计算工具，用于资金的时间价值计算、投资决策分析和金融产品估值。这些函数是金融量化分析的基础工具。

## 核心功能列表

### 1. PV (Present Value) - 现值计算
**文件**：`pv.cj`

**计算公式**：PV = FV / (1 + r)ⁿ

**参数**：
- `fv` (Float64) - 未来值（Future Value）
- `rate` (Float64) - 利率或折现率
- `years` (Int64) - 年数

**用途**：
- 计算未来现金流在今天的价值
- 比较不同投资机会
- 债券估值

**示例**：
```cangjie
import indicator4cj.valuation.*

// 计算 10000 元在 5 年后、年利率 5% 的情况下的现值
let pv = pv(fv = 10000.0, rate = 0.05, years = 5)
// 结果约为 7835.26 元
```

**原理**：
- 时间价值：今天的 1 元比明天的 1 元更有价值
- 风险补偿：未来的不确定性需要折现
- 机会成本：资金可以用于其他投资

---

### 2. FV (Future Value) - 终值计算
**文件**：`fv.cj`

**计算公式**：FV = PV × (1 + r)ⁿ

**参数**：
- `pv` (Float64) - 现值（Present Value）
- `rate` (Float64) - 利率或收益率
- `years` (Int64) - 年数

**用途**：
- 计算投资的未来价值
- 退休规划
- 教育储蓄规划

**示例**：
```cangjie
import indicator4cj.valuation.*

// 计算 10000 元在年利率 5% 的情况下，5 年后的价值
let fv = fv(pv = 10000.0, rate = 0.05, years = 5)
// 结果约为 12762.82 元
```

**应用场景**：
- 复利计算
- 投资回报预测
- 贷款还款计算

---

### 3. NPV (Net Present Value) - 净现值计算
**文件**：`npv.cj`

**计算公式**：NPV = Σ[Ct / (1 + r)ᵗ] - C₀

其中：
- Ct = 第 t 期的现金流
- r = 折现率
- C₀ = 初始投资

**参数**：
- `rate` (Float64) - 折现率
- `cashflows` - 现金流数组（第一期为负数，表示初始投资）

**用途**：
- 评估投资项目
- 资本预算决策
- 比较不同投资机会

**决策准则**：
- NPV > 0：项目值得投资
- NPV = 0：项目盈亏平衡
- NPV < 0：项目不值得投资

**示例**：
```cangjie
import indicator4cj.valuation.*

// 评估一个投资项目
// 初始投资 10000 元
// 第1年收益 3000 元
// 第2年收益 4000 元
// 第3年收益 5000 元
// 折现率 10%
let cashflows = [-10000.0, 3000.0, 4000.0, 5000.0]
let npv = npv(rate = 0.10, cashflows)

if (npv > 0) {
    println("项目值得投资，NPV = ${npv}")
} else {
    println("项目不值得投资，NPV = ${npv}")
}
```

---

## 使用示例

### 示例 1：投资回报计算

```cangjie
import indicator4cj.valuation.*

// 计算不同投资期限的回报
let principal = 10000.0  // 本金
let rate = 0.05         // 年利率 5%

for (year in [1, 3, 5, 10]) {
    let futureValue = fv(pv = principal, rate = rate, years = year)
    println("${year} 年后：${futureValue} 元")
}

// 输出：
// 1 年后：10500.0 元
// 3 年后：11576.25 元
// 5 年后：12762.82 元
// 10 年后：16288.95 元
```

### 示例 2：投资项目比较

```cangjie
import indicator4cj.valuation.*

// 比较两个投资项目
let rate = 0.10  // 折现率 10%

// 项目 A：初始投资 10000，3 年回报分别为 4000, 5000, 6000
let cashflowsA = [-10000.0, 4000.0, 5000.0, 6000.0]
let npvA = npv(rate, cashflowsA)

// 项目 B：初始投资 10000，3 年回报分别为 3000, 6000, 7000
let cashflowsB = [-10000.0, 3000.0, 6000.0, 7000.0]
let npvB = npv(rate, cashflowsB)

println("项目 A 的 NPV：${npvA}")
println("项目 B 的 NPV：${npvB}")

if (npvA > npvB) {
    println("选择项目 A")
} else {
    println("选择项目 B")
}
```

### 示例 3：债券估值

```cangjie
import indicator4cj.valuation.*

// 评估债券价值
// 面值 1000 元，票面利率 5%，期限 3 年，市场利率 6%
let faceValue = 1000.0
let couponRate = 0.05
let marketRate = 0.06
let years = 3

// 计算每年的利息现值
var totalPV = 0.0
let annualCoupon = faceValue * couponRate

for (year in 1..=years) {
    let couponPV = pv(fv = annualCoupon, rate = marketRate, years = year)
    totalPV += couponPV
}

// 加上本金的现值
let principalPV = pv(fv = faceValue, rate = marketRate, years = years)
totalPV += principalPV

println("债券的理论价格：${totalPV}")
```

### 示例 4：退休规划

```cangjie
import indicator4cj.valuation.*

// 计算退休储蓄目标
let currentAge = 30
let retirementAge = 60
let yearsToRetirement = retirementAge - currentAge

let monthlyExpense = 5000.0  // 期望每月支出 5000 元
let expectedReturn = 0.07    // 预期年化收益率 7%
let retirementYears = 25     // 预期退休后生活 25 年

// 计算退休时需要的总金额
// 简化计算：不考虑通胀，假设每年支出固定
let totalNeeded = monthlyExpense * 12 * retirementYears
let pvAtRetirement = pv(fv = totalNeeded, rate = expectedReturn, years = retirementYears)

println("退休时需要：${pvAtRetirement}")

// 计算每年需要储蓄多少
let annualSaving = pvAtRetirement / fv(pv = 1.0, rate = expectedReturn, years = yearsToRetirement)
println("每年需要储蓄：${annualSaving}")
println("每月需要储蓄：${annualSaving / 12}")
```

### 示例 5：贷款计算

```cangjie
import indicator4cj.valuation.*

// 计算贷款的真实成本
let loanAmount = 100000.0  // 贷款 10 万
let loanYears = 20         // 贷款期限 20 年
let annualRate = 0.05      // 年利率 5%

// 计算总还款额（简单复利）
let totalRepayment = fv(pv = loanAmount, rate = annualRate, years = loanYears)

let interest = totalRepayment - loanAmount
println("贷款金额：${loanAmount}")
println("总还款额：${totalRepayment}")
println("总利息：${interest}")
println("利息占比：${interest / loanAmount * 100}%")
```

## 注意事项

1. **利率单位**：所有利率函数使用小数形式（如 5% = 0.05）
2. **时间单位**：默认以年为单位，其他周期需要转换
3. **现金流符号**：NPV 计算中，流出为负，流入为正
4. **复利频率**：当前实现假设每年复利一次
5. **精度问题**：浮点数计算可能存在精度误差

## 典型应用场景

1. **投资决策**：使用 NPV 评估项目可行性
2. **财务规划**：使用 FV 计算投资回报
3. **资产估值**：使用 PV 计算资产现值
4. **贷款比较**：计算不同贷款方案的真实成本
5. **退休规划**：计算退休储蓄目标

## 金融公式原理

### 货币时间价值

货币时间价值是金融学的核心概念，基于以下原理：

1. **时间偏好**：人们偏好当前消费而非未来消费
2. **投资机会**：资金可以投资获得回报
3. **通货膨胀**：货币购买力随时间下降
4. **风险补偿**：未来现金流具有不确定性

### 复利效应

复利是"利滚利"的过程，公式为：
```
FV = PV × (1 + r)ⁿ
```

其中 n 越大，复利效应越显著。

### 折现原理

折现是复利的逆运算，将未来现金流折算为现值：
```
PV = FV / (1 + r)ⁿ
```

## 依赖关系

- **std.math** - 数学函数（pow 等）

## 版本历史

### v1.0.0 (2024)
- 初始版本
- 实现基础估值函数
- 支持 PV、FV、NPV 计算
- 提供完整的使用示例
