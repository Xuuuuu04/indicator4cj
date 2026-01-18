<div align="center">
<h1>indicator4cj</h1>
<strong>仓颉（Cangjie）金融技术分析与回测库</strong>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.4-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/domain-Finance/Analysis-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/license-Apache%202.0-blue" style="display: inline-block;" />
</p>

## 介绍

**indicator4cj** 是一个基于仓颉（Cangjie）语言实现的**金融技术分析与回测组件库**。本项目由原 Go 语言知名金融库 [cinar/indicator](https://github.com/cinar/indicator) (v2) 完整迁移而来，旨在为仓颉生态提供高性能、类型安全且易于扩展的技术指标计算与策略开发工具。

### 核心特性

- **📊 70+ 技术指标**：涵盖趋势（33个）、动量（12个）、波动率（12个）、成交量（11个）及估值分析
- **⚡ 流式计算引擎**：基于 `Iterator<T>` 的惰性计算模型，支持超大规模数据处理
- **🎯 完整回测框架**：支持多资产并行回测、比例佣金及止损装饰器
- **📈 自动化报表**：可生成内存数据报告及静态 HTML 可视化报告
- **💾 数据摄取层**：支持 CSV 反射解析、文件系统仓储及内存仓储
- **🧪 完善测试覆盖**：171个测试文件，203个源文件，100%测试通过率

**参考与依赖:**
- 本项目参考了 [cinar/indicator](https://github.com/cinar/indicator) 的实现
- 本项目遵循 1:1 数据对标原则，所有指标均通过与 Go 原版的精度验证

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
    ├── asset/          # 资产管理与数据源 (CSV, 文件系统, 内存仓储)
    ├── backtest/       # 回测核心引擎与报表生成
    ├── helper/         # 流式计算工具、CSV 反射解析、数学辅助
    ├── momentum/       # 动量指标 (RSI, Stochastic, etc.)
    ├── strategy/       # 交易策略实现 (包含复合与装饰器策略)
    │   ├── compound/   # 复合策略 (MACD+RSI等)
    │   ├── decorator/  # 装饰器策略 (止损、反向、无损)
    │   ├── momentum/   # 动量策略
    │   ├── trend/      # 趋势策略
    │   └── volume/     # 成交量策略
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
     * @param values 输入数值流 (迭代器)
     * @return SMA 结果流
     */
    public func compute(values: Iterator<Float64>): Iterator<Float64>

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
    func assets(): ArrayList<String>                        // 获取资产列表
    func get(name: String): Option<Iterator<Snapshot>>      // 获取资产全部快照
    func getSince(name: String, date: DateTime): Iterator<Snapshot> // 获取指定日期后的快照
    func lastDate(name: String): Option<DateTime>           // 获取最后更新日期
    func append(name: String, snapshots: Iterator<Snapshot>): Unit // 追加快照数据
}
```

#### 核心枚举与常量

```cangjie
// 交易动作枚举
public enum Action <: ToString & Equatable<Action> {
    | BUY    // 买入信号
    | SELL   // 卖出信号
    | HOLD   // 持仓/观望
}

// 默认周期常量
public const RSI_DEFAULT_PERIOD: Int64 = 14
public const MACD_DEFAULT_FAST_PERIOD: Int64 = 12
public const MACD_DEFAULT_SLOW_PERIOD: Int64 = 26
public const MACD_DEFAULT_SIGNAL_PERIOD: Int64 = 9
```

## 使用说明

### 编译构建

```shell
cjpm build
```
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
            case Some(v) => println("${v}")
            case None => break
        }
    }
}
```

#### 策略回测执行示例

本示例展示了如何使用内存仓储和买入持有策略进行回测。

```cangjie
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.backtest.*
import std.collection.*

main() {
    // 1. 初始化内存仓储并加载数据
    let repo = InMemoryRepository()
    let snaps = loadFromCsv<Snapshot>("testdata/brk-b.csv")
    repo.append("BRK.B", snaps)

    // 2. 配置回测参数
    let strategies = ArrayList<Strategy>()
    strategies.add(BuyAndHoldStrategy())

    let bt = Backtest(repo, strategies)
    bt.names.add("BRK.B")

    // 3. 运行回测
    bt.run()
}
```

## 技术指标清单

### 趋势指标 (33个)
- **移动平均线**: SMA, EMA, WMA, HMA, TEMA, DEMA, TRIMA, KAMA, SMMA, RMA, VWMA
- **趋势跟踪**: MACD, APO, ROC, TRIX, CCI, AROON, KDJ, TSI
- **通道指标**: Bollinger Bands, Envelope, Donchian Channel (volatility), Keltner Channel (volatility)
- **其他**: DPO, Mass Index, MLR, MLS, Moving Sum, Moving Max, Moving Min, Typical Price, Weighted Close, BOP

### 动量指标 (12个)
- RSI, Stochastic Oscillator, Stochastic RSI, Williams %R
- Awesome Oscillator, Chaikin Oscillator, PPO, PVO
- Qstick, Ichimoku Cloud, Pring's Special K, Momentum

### 波动率指标 (12个)
- ATR, Bollinger Bands, Bollinger Band Width, %B, Keltner Channel
- Donchian Channel, SuperTrend, Acceleration Bands
- Chandelier Exit, Ulcer Index, Moving Std Dev, Price Oscillator

### 成交量指标 (11个)
- OBV, MFI, NVI, VWAP, AD (Accumulation/Distribution)
- CMF, EMV, FI (Force Index), MFM, MFV, VPT

### 估值指标
- Present Value (PV), Future Value (FV), Net Present Value (NPV)

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
监督人：[@zhangyin_gitcode](https://gitcode.com/zhangyin_gitcode) (HUAWEI Developer Advocate)
