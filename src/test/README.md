# indicator4cj.test - 测试包

## 版本
v1.0.0

## 包简介
`test` 包负责 `indicator4cj` 库的全量自动化测试与验证，确保迁移后的仓颉实现与原版 Go 实现（cinar/indicator v2）在逻辑和数值上严格对齐。

## 测试体系结构

### 1. 单元测试 (Unit Tests)

针对每个指标、算子和策略的边界情况进行验证。

**测试范围**：
- 空输入处理
- 单元素处理
- 极值测试
- 边界条件
- 异常处理

**文件命名规范**：`{feature}_test.cj`

**示例**：
```
src/test/
├── trend/
│   ├── sma_test.cj
│   ├── ema_test.cj
│   └── macd_test.cj
├── momentum/
│   ├── rsi_test.cj
│   └── stochastic_oscillator_test.cj
└── strategy/
    ├── macd_strategy_test.cj
    └── rsi_strategy_test.cj
```

---

### 2. 1:1 对标验证 (Parity Tests)

**机制**：从 Go 参考实现中导出特定参数下的指标计算结果（CSV），作为"真值"。

**流程**：
1. Go 实现计算指标结果，导出为 CSV
2. 仓颉实现加载相同的原始数据
3. 计算后使用 `CheckEquals` 与真值进行逐行对比
4. 对于浮点数计算，使用 `1e-8` 的 epsilon 容差

**示例测试数据结构**：
```cangjie
class IndicatorResult {
    var timestamp: DateTime
    var sma: Float64
    var ema: Float64
    var rsi: Float64
}

// 加载真值数据
let expected = parseCSVFile<IndicatorResult>("testdata/trend/sma_expected.csv", "yyyy-MM-dd", true)

// 计算仓颉实现结果
let actual = computeIndicator("testdata/trend/input.csv")

// 逐行对比
for (i in 0..expected.size) {
    checkEquals(expected[i].sma, actual[i], 1e-8)
}
```

---

### 3. 鲁棒性测试 (Robustness Tests)

验证系统在非正常输入下的行为。

**测试场景**：
- Period <= 0
- 迭代器提前关闭
- 空数据集
- 极端数值（NaN, Infinity）
- 超大数据量

**示例**：
```cangjie
@Test
class RobustnessTests {
    @TestCase
    public func testZeroPeriod() {
        let sma = Sma()
        try {
            sma.period = 0
            sma.compute([1.0, 2.0].iterator())
            assert(false, "应该抛出异常")
        } catch (_: Exception) {
            // 预期行为
        }
    }

    @TestCase
    public func testEmptyInput() {
        let sma = Sma(5)
        let result = sma.compute([].iterator())
        assert(!result.hasNext(), "空输入应无输出")
    }
}
```

---

## 测试数据管理

所有测试依赖的 CSV 数据均统一存放在 `src/test/testdata` 目录下，按模块分类：

```
src/test/testdata/
├── trend/           # 趋势指标真值
│   ├── sma_expected.csv
│   ├── ema_expected.csv
│   └── macd_expected.csv
├── momentum/        # 动量指标真值
│   ├── rsi_expected.csv
│   └── stochastic_expected.csv
├── strategy/        # 策略信号真值
│   ├── macd_strategy_signals.csv
│   └── rsi_strategy_signals.csv
└── asset/           # 标准历史行情样本
    ├── daily_prices.csv
    └── minute_prices.csv
```

---

## 测试分类

### 按模块分类

1. **trend** - 趋势指标测试
   - 移动平均线系列
   - MACD, APO, TRIX 等
   - 通道指标

2. **momentum** - 动量指标测试
   - RSI 系列
   - 随机振荡器
   - Williams %R 等

3. **volatility** - 波动率指标测试
   - 布林带系列
   - ATR
   - Keltner Channel 等

4. **volume** - 成交量指标测试
   - OBV, AD
   - MFI, CMF
   - VWAP 等

5. **strategy** - 交易策略测试
   - 单一策略测试
   - 组合策略测试
   - 策略回测

6. **asset** - 资产管理测试
   - Repository 测试
   - 数据加载测试
   - SQL 存储测试

7. **backtest** - 回测引擎测试
   - 回测框架测试
   - 报告生成测试
   - 性能指标测试

---

## 运行测试

### 运行所有测试

```bash
cjpm test
```

### 运行特定测试

```bash
# 运行趋势指标测试
cjpm test --filter trend

# 运行单个测试文件
cjpm test src/test/trend/sma_test.cj
```

### 查看测试覆盖率

```bash
cjpm test --coverage
```

---

## 测试编写规范

### 1. 测试类命名

```cangjie
@Test
class SmaTests {
    @TestCase
    public func testCompute() { ... }

    @TestCase
    public func testIdlePeriod() { ... }
}
```

### 2. 断言使用

```cangjie
// 相等性断言
@Expect(actual, expected)

// 异常断言
@ExpectThrows[Exception]({
    sma.period = -1
})

// 近似相等（浮点数）
assert(Math.abs(actual - expected) < 1e-8)
```

### 3. 测试数据准备

```cangjie
func prepareTestData(): Array<Float64> {
    return [1.0, 2.0, 3.0, 4.0, 5.0]
}

func loadExpectedData(filename: String): Array<Float64> {
    return parseCSVFile<TestResult>(filename, "yyyy-MM-dd", true)
        .map { r => r.value }
}
```

---

## 注意事项

### 1. 反射限制

测试中使用的 DTO（如 `Result`, `Snapshot`）必须使用 `class` 而非 `struct`，以支持 `helper.Csv` 的反射填充。

**❌ 错误**：
```cangjie
struct TestResult {
    var value: Float64
}
```

**✅ 正确**：
```cangjie
class TestResult {
    var value: Float64
}
```

### 2. 环境依赖

部分 `tiingo` 相关测试需要网络连接，若环境不具备条件，相关测试用例将报错或跳过。

**解决方案**：
```cangjie
@Test
class ExternalDataTests {
    @TestCase
    public func testTiingoData() {
        if (!hasNetworkConnection()) {
            return  // 跳过测试
        }
        // 测试代码
    }
}
```

### 3. 测试隔离

每个测试用例应该独立，不依赖其他测试的执行顺序或结果。

**❌ 错误**：
```cangjie
class SharedStateTests {
    static var counter = 0

    @TestCase
    public func test1() {
        counter++
    }

    @TestCase
    public func test2() {
        // 依赖 test1 的结果
        assert(counter == 1)
    }
}
```

**✅ 正确**：
```cangjie
class IsolatedTests {
    @TestCase
    public func test1() {
        var counter = 0
        counter++
        assert(counter == 1)
    }

    @TestCase
    public func test2() {
        var counter = 0
        counter++
        assert(counter == 1)
    }
}
```

---

## 性能测试

对于性能敏感的指标，需要编写性能测试：

```cangjie
@Test
class PerformanceTests {
    @TestCase
    public func testLargeDataset() {
        let data = generateTestData(1000000)  // 100万数据点
        let start = DateTime.now()

        let sma = Sma(20)
        let result = sma.compute(data.iterator())

        let duration = DateTime.now() - start
        assert(duration.toMilliseconds() < 1000, "应在1秒内完成")
    }
}
```

---

## 持续集成

测试脚本应集成到 CI/CD 流程中：

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install CJPM
        run: curl -sSL https://get.cjpm.dev | sh
      - name: Run Tests
        run: cjpm test
      - name: Upload Coverage
        run: cjpm test --coverage --coverage-output=coverage.xml
```

---

## 版本历史

### v1.0.0 (2024)
- 初始测试框架
- 全量单元测试覆盖
- 1:1 对标验证
- 鲁棒性测试
- 性能基准测试

---

## 贡献指南

添加新测试时，请遵循以下规范：

1. **文件命名**：使用 `_test.cj` 后缀
2. **测试组织**：按功能模块分组
3. **数据管理**：测试数据放在 `testdata/` 目录
4. **文档完善**：添加清晰的测试说明
5. **覆盖率**：确保新代码有对应的测试用例

---

## 常见问题

### Q: 测试失败如何调试？
A: 使用 `echo` 函数输出中间结果，或使用调试器单步执行。

### Q: 如何处理浮点数精度？
A: 使用 `1e-8` 作为容差，避免严格相等比较。

### Q: 测试数据如何生成？
A: 从 Go 实现导出，或使用已知正确结果的公开数据集。
