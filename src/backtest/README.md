# Package backtest

`backtest` 包提供了一个功能完备的策略回测框架，用于验证交易策略在历史数据上的表现。

## 核心功能

### 1. Backtest (回测引擎)

回测引擎是执行策略回测的核心组件，支持多资产、多策略的并行回测。

#### 工作流程

```
准备阶段 → 报告开始 → 逐资产回测 → 报告结束
   ↓           ↓           ↓           ↓
加载数据   begin()    执行策略    end()
初始化策略              计算收益    生成报告
```

#### 核心配置

```cangjie
public class Backtest {
    // 输入配置
    public var _repository: Repository         // 数据仓储
    public var _report: Report                 // 报告生成器
    public var _workers: Int64 = 1             // 并发工作线程数
    public var _lastDays: Int64 = 365          // 回测天数（默认1年）

    // 待回测资产和策略
    public var names: ArrayList<String>        // 资产名称列表
    public var strategies: ArrayList<Strategy> // 策略列表

    // 执行回测
    public func run(): Option<Exception>
}
```

#### 常量定义

- `DefaultBacktestWorkers = 1`：默认单线程模式
- `DefaultLastDays = 365`：默认回测最近1年数据

### 2. Report (报告接口)

报告生成器接口，用于定义回测结果的输出格式。

#### 接口定义

```cangjie
public interface Report {
    func begin(assets: ArrayList<String>, strategies: ArrayList<Strategy>): Unit
    func write(asset: String, strategy: String, result: Result): Unit
    func end(): Unit
}
```

#### 实现类

##### DataReport (数据报告)

- **输出格式**：内存数据结构
- **用途**：程序化访问回测结果
- **优势**：便于进一步分析和处理

```cangjie
public class DataReport <: Report {
    // 结果存储在内存中
    // 可通过 API 访问详细统计数据
}
```

##### HtmlReport (HTML 报告)

- **输出格式**：静态 HTML 网页
- **用途**：可视化展示回测结果
- **特性**：
  - 无需外部依赖（单文件 HTML）
  - 包含图表和统计指标
  - 支持多资产、多策略对比

```cangjie
public class HtmlReport <: Report {
    public init(outputDir: String)  // 输出目录
}
```

### 3. Result (回测结果)

包含策略执行的详细统计信息。

```cangjie
public class Result {
    public var asset: String                // 资产名称
    public var strategy: String             // 策略名称
    public var actions: ArrayList<Action>   // 交易动作序列
    public var outcomes: ArrayList<Float64> // 收益率序列

    // 统计指标
    public var count: Int64                 // 交易次数
    public var grossProfit: Float64         // 总收益
    public var grossLoss: Float64           // 总亏损
    public var netProfit: Float64           // 净收益
    public var maxDrawdown: Float64         // 最大回撤
    public var maxDrawdownPercent: Float64  // 最大回撤百分比
    public var annualizedReturn: Float64    // 年化收益率
    public var sharpeRatio: Float64         // 夏普比率
}
```

## 使用示例

### 基础回测

```cangjie
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.backtest.*
import std.collection.*

main() {
    // 1. 准备数据
    let repo = InMemoryRepository()
    let snaps = loadFromCsv<Snapshot>("testdata/AAPL.csv")
    repo.append("AAPL", snaps)

    // 2. 配置回测
    let strategies = ArrayList<Strategy>()
    strategies.add(BuyAndHoldStrategy())

    let backtest = Backtest(repo, strategies)
    backtest.names.add("AAPL")

    // 3. 执行回测
    match (backtest.run()) {
        case Some(e) => println("回测失败: ${e.message}")
        case None => println("回测成功")
    }
}
```

### 多策略回测

```cangjie
// 同时测试多个策略
let strategies = ArrayList<Strategy>()
strategies.add(BuyAndHoldStrategy())
strategies.add(RsiStrategy())
strategies.add(MacdStrategy())

let backtest = Backtest(repo, strategies)
backtest.names.addAll(["AAPL", "MSFT", "GOOGL"])

backtest.run()
```

### 自定义报告

```cangjie
// 生成 HTML 报告
let htmlReport = HtmlReport("output/reports")
let backtest = Backtest(repo, strategies, htmlReport)
backtest.run()
```

## 回测指标说明

### 收益指标

| 指标 | 说明 | 计算方式 |
|------|------|---------|
| Gross Profit | 总收益 | 所有盈利交易的收益总和 |
| Gross Loss | 总亏损 | 所有亏损交易的亏损总和 |
| Net Profit | 净收益 | 总收益 - 总亏损 |
| Annualized Return | 年化收益率 | (最终收益 / 初始资金)^(365/持有天数) - 1 |

### 风险指标

| 指标 | 说明 | 计算方式 |
|------|------|---------|
| Max Drawdown | 最大回撤 | 历史最高点到最低点的最大跌幅 |
| Max Drawdown % | 最大回撤百分比 | 最大回撤 / 历史最高资产 |
| Sharpe Ratio | 夏普比率 | 年化收益率 / 年化波动率 |

### 交易统计

| 指标 | 说明 |
|------|------|
| Count | 交易次数（买入+卖出） |
| Buy & Hold | 买入持有基准策略 |

## 特性说明

### 1. 多资产支持

回测引擎可以同时对多个资产进行回测：

```cangjie
backtest.names.addAll(["AAPL", "MSFT", "GOOGL", "TSLA"])
```

### 2. 并发执行

通过设置 `workers` 参数可以调整并发级别：

```cangjie
backtest.workers = 4  // 4个线程并发回测
```

### 3. 增量回测

通过设置 `lastDays` 可以只回测最近 N 天的数据：

```cangjie
backtest.lastDays = 30  // 只回测最近30天
```

### 4. 报告自定义

通过实现 `Report` 接口可以自定义报告格式：

```cangjie
public class CustomReport <: Report {
    public func begin(...) { /* 自定义逻辑 */ }
    public func write(...) { /* 自定义逻辑 */ }
    public func end() { /* 自定义逻辑 */ }
}
```

## 注意事项

1. **数据完整性**：确保 Repository 中的数据是完整的，缺失数据可能导致回测结果不准确
2. **交易成本**：当前版本支持比例佣金，固定佣金需要自定义策略实现
3. **滑点模拟**：默认未考虑滑点，实际交易可能存在价格偏差
4. **前瞻性偏差**：避免在策略中使用未来数据（如使用当天的收盘价做决策）
5. **过度拟合**：回测表现好的策略不一定在实盘中表现好，需要注意样本外测试

## 性能优化建议

1. **批量回测**：一次性回测多个策略，避免重复加载数据
2. **内存管理**：大规模数据回测时，适当调整 JVM 内存
3. **并发控制**：根据 CPU 核心数调整 workers 参数
4. **数据缓存**：使用 InMemoryRepository 缓存常用数据
