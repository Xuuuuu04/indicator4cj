<div align="center">
<h1>indicator4cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.4-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/domain-Finance/Analysis-brightgreen" style="display: inline-block;" />
</p>

## 介绍

**indicator4cj** 是一个基于仓颉（Cangjie）语言实现的**金融技术分析与回测组件库**。本项目由原 Go 语言知名金融库 [cinar/indicator](https://github.com/cinar/indicator) (v2) 完整迁移而来，旨在为仓颉生态提供高性能、类型安全且易于扩展的技术指标计算与策略开发工具。

目前已实现的功能包括：
- **175+ 技术指标**：涵盖趋势、动量、波动率及成交量分析。
- **流式计算引擎**：基于 `Iterator<T>` 的惰性计算模型，支持超大规模数据。
- **完整回测框架**：支持多资产并行回测、比例佣金及止损装饰器。
- **自动化报表**：可生成内存数据报告及静态 HTML 可视化报告。
- **数据摄取层**：支持 CSV 反射解析、Tiingo 实时数据源及内存仓储。

**参考与依赖:**
- 本项目参考了 [cinar/indicator](https://github.com/cinar/indicator) 的实现。
- 本项目遵循 1:1 数据对标原则，所有指标均通过与 Go 原版的精度验证。

## 项目架构

### 源码目录

```shell
.
├── README.md           # 项目主文档
├── cjpm.toml           # 项目配置
├── doc/                # 深入设计与 API 文档
│   ├── design.md       # 设计哲学与架构深度解析
│   └── feature_api.md  # 详尽的 API 接口参考
└── src/                # 源码目录
    ├── asset/          # 资产管理与数据源 (Tiingo, CSV, SQL)
    ├── backtest/       # 回测核心引擎与报表生成
    ├── helper/         # 流式计算工具、CSV 反射解析、数学辅助
    ├── momentum/       # 动量指标 (RSI, Stochastic, etc.)
    ├── strategy/       # 交易策略实现 (包含复合与装饰器策略)
    ├── trend/          # 趋势指标 (SMA, EMA, MACD, etc.)
    ├── valuation/      # 估值计算 (PV, FV, NPV)
    ├── volatility/     # 波动率指标 (ATR, Bollinger, etc.)
    ├── volume/         # 成交量指标 (OBV, VWAP, etc.)
    └── test/           # 单元测试与 1:1 对标测试数据
```

### 接口说明

主要类和函数接口说明如下，详见 [API](./doc/feature_api.md)

#### 核心指标 API (以 SMA 为例)

```cangjie
/** 简单移动平均线 (SMA) 类
 *
 * 计算给定周期内的算术平均值
 */
public class Sma {
    public var period: Int64 // 计算周期

    /** 计算函数
     * @param c 输入数值流 (迭代器)
     * @return SMA 结果流
     */
    public func compute(c: Iterator<Float64>): Iterator<Float64>

    /** 获取预热期
     * @return 返回 period - 1
     */
    public func idlePeriod(): Int64
}
```

#### 策略接口 API

```cangjie
/** Strategy 接口 - 交易策略容器
 *
 * 定义了策略的执行行为与报表生成
 */
public interface Strategy {
    func name(): String                                     // 策略名称
    func compute(snapshots: Iterator<Snapshot>): Iterator<Action> // 生成买卖动作流
    func report(snapshots: Iterator<Snapshot>): Report      // 生成策略详细报表
}
```

#### 资产仓储 API

```cangjie
/** Repository 接口 - 数据源抽象
 *
 * 用于统一管理不同来源的历史行情数据
 */
public interface Repository {
    func assets(): (ArrayList<String>, Option<Exception>)   // 获取资产列表
    func get(name: String): (Iterator<Snapshot>, Option<Exception>) // 获取资产全部快照
    func lastDate(name: String): (Option<DateTime>, Option<Exception>) // 获取最后更新日期
}
```

#### 核心枚举与常量

```cangjie
// 交易动作枚举
public enum Action {
    Buy     // 买入信号 (1)
    Sell    // 卖出信号 (-1)
    Hold    // 持仓/观望 (0)
}

// 默认周期常量 (示例)
public const DefaultRocPeriod: Int64 = 9
public const DefaultMacdPeriod1: Int64 = 12
```

## 使用说明

### 编译构建

```shell
cjpm update
cjpm build
```

### 运行测试

项目提供了完整的单元测试套件（240个测试用例），覆盖所有核心功能。

#### 使用测试脚本（推荐）

```shell
# Windows
test.bat

# Linux/Unix/macOS
./test.sh
```

#### 直接运行测试

如果需要直接运行 `cjpm test`，请先设置环境变量以避免终端宽度检测问题：

```shell
# Windows (CMD)
set COLUMNS=120
set TERM=xterm-256color
cjpm test

# Linux/Unix/macOS
export COLUMNS=120
export TERM=xterm-256color
cjpm test
```

> **注意**：如果遇到 `IllegalArgumentException: negative totalWidth` 异常，请参考 [测试故障排除指南](./TEST_TROUBLESHOOTING.md) 获取详细解决方案。

#### 测试覆盖范围

- **测试套件**: 12个
- **测试用例**: 240个
- **测试通过率**: 100%
- **测试模块**:
  - 核心指标测试（趋势、动量、波动率、成交量）
  - 策略测试（动量、趋势、复合、装饰器）
  - 回测引擎测试
  - 资产管理测试

详细的测试覆盖率报告请参考 [TEST_COVERAGE_REPORT.md](./TEST_COVERAGE_REPORT.md)。

### 功能示例

#### 技术指标计算示例

本示例展示了如何使用 `Sma` 指标处理一个简单的数值序列。

```cangjie
import indicator4cj.trend.*
import std.collection.*

main() {
    let data = ArrayList<Float64>([10.0, 12.0, 14.0, 16.0, 18.0]).iterator()
    let sma = Sma(period: 3)
    let result = sma.compute(data)
    
    println("SMA (Period 3) 结果:")
    while (true) {
        match (result.next()) {
            case Some(v) => println("${v}") // 输出前两项为 NaN，第三项起为均值
            case None => break
        }
    }
}
```

#### 策略回测执行示例

本示例展示了如何对 BRK.B 资产运行一个 RSI 动量策略，并生成回测报告。

```cangjie
import indicator4cj.asset.*
import indicator4cj.strategy.momentum.*
import indicator4cj.backtest.*

main() {
    // 1. 初始化内存仓储并加载数据
    let repo = InMemoryRepository()
    let snaps = ReadFromCsvFile<Snapshot>("testdata/brk-b.csv")
    repo.Append("BRK.B", snaps)

    // 2. 配置回测参数
    let strategies = ArrayList<Strategy>([NewRsiStrategy()])
    let bt = Backtest(repo, strategies, ReportFactory("html"))
    
    // 3. 运行回测
    match (bt.run()) {
        case Some(e) => println("回测失败: ${e.message}")
        case None => println("回测完成，报告已生成至 html_output 目录")
    }
}
```

## 约束与限制

- **数据库驱动限制**：
  - 目前 `SQLRepository` 仅定义了标准接口，未内置 MySQL/SQLite 的二进制驱动。
  - 建议使用 `mysql-driver-cj` 等第三方仓颉库进行对接。
- **并发性能限制**：
  - 本项目采用同步迭代器（Pull 模式）实现，暂未利用多核协程进行指标内部的并行计算。
  - 大规模参数扫描建议在 `Backtest` 层级进行资产维度的并行调度。
- **数据格式要求**：
  - CSV 数据加载依赖反射，DTO 字段名需与 CSV 表头严格匹配（忽略大小写）。

## 开源协议
本项目基于 [Apache License 2.0](./LICENSE) 开源协议。

## 参与贡献

本项目 committer：[@mumu_xsy](https://gitcode.com/mumu_xsy)
监督人：[@zhangyin_gitcode](https://gitcode.com/zhangyin_gitcode) (HUAWEI Developer Advocate).
