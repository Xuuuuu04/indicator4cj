# indicator4cj.helper - 辅助工具包

## 版本
v1.0.0

## 包简介
`helper` 包是 `indicator4cj` 的底层基石，提供了一套针对 `Iterator<T>` 优化的流式计算工具集，以及反射驱动的 CSV 解析和报表构建功能。该包是所有其他指标包的依赖基础。

## 核心功能分类

### 1. 流式数据处理工具

#### 数据转换
- **`map<T>(iter: Iterator<T>, f: (T) -> T): Iterator<T>`** - 对迭代器中的每个元素应用映射函数
- **`filter<T>(iter: Iterator<T>, f: (T) -> Bool): Iterator<T>`** - 过滤迭代器中的元素
- **`duplicate<T>(iter: Iterator<T>, n: Int64): Array<Iterator<T>>`** - 将迭代器复制为多个独立迭代器
- **`mapWithPrevious<TFrom, TTo>(iter, f, previous): Iterator<TTo>`** - 带前一结果的累积映射

#### 数据操作
- **`skip<T>(iter: Iterator<T>, n: Int64): Iterator<T>`** - 跳过前 n 个元素
- **`skip_last<T>(iter: Iterator<T>, n: Int64): Iterator<T>`** - 跳过最后 n 个元素
- **`shift<T>(iter: Iterator<T>, n: Int64): Iterator<T>`** - 移动迭代器位置
- **`head<T>(iter: Iterator<T>, n: Int64): Iterator<T>`** - 取前 n 个元素
- **`window<TElement>(iter, w, f): Iterator<TElement>`** - 滑动窗口聚合

#### 聚合函数
- **`first<T>(iter: Iterator<T>): T`** - 获取第一个元素
- **`last<T>(iter: Iterator<T>): T`** - 获取最后一个元素
- **`highest<T>(iter: Iterator<T>, n: Int64): T`** - 获取 n 周期内最高值
- **`lowest<T>(iter: Iterator<T>, n: Int64): T`** - 获取 n 周期内最低值
- **`max_since<T>(iter: Iterator<T>): Iterator<Float64>`** - 自某点以来的最大值
- **`min_since<T>(iter: Iterator<T>): Iterator<Float64>`** - 自某点以来的最小值
- **`count<T>(iter: Iterator<T>): Int64`** - 统计元素个数

### 2. 数学运算辅助函数

#### 基础运算
- **`add<T>(iter1, iter2): Iterator<Float64>`** - 两个迭代器逐元素相加
- **`subtract<T>(iter1, iter2): Iterator<Float64>`** - 两个迭代器逐元素相减
- **`multiply<T>(iter1, iter2): Iterator<Float64>`** - 两个迭代器逐元素相乘
- **`divide<T>(iter1, iter2): Iterator<Float64>`** - 两个迭代器逐元素相除

#### 标量运算
- **`incrementBy<T>(iter: Iterator<T>, delta: Float64): Iterator<Float64>`** - 所有元素增加指定值
- **`decrementBy<T>(iter: Iterator<T>, delta: Float64): Iterator<Float64>`** - 所有元素减少指定值
- **`multiplyBy<T>(iter: Iterator<T>, factor: Float64): Iterator<Float64>`** - 所有元素乘以指定值
- **`divideBy<T>(iter: Iterator<T>, divisor: Float64): Iterator<Float64>`** - 所有元素除以指定值

#### 高级数学函数
- **`pow<T>(iter: Iterator<T>, exp: Float64): Iterator<Float64>`** - 幂运算
- **`sqrt<T>(iter: Iterator<T>): Iterator<Float64>`** - 平方根
- **`abs<T>(iter: Iterator<T>): Iterator<Float64>`** - 绝对值
- **`sign<T>(iter: Iterator<T>): Iterator<Float64>`** - 符号函数（-1, 0, 1）

#### 数论函数
- **`gcd(a: Int64, b: Int64): Int64`** - 最大公约数
- **`lcm(a: Int64, b: Int64): Int64`** - 最小公倍数

#### 取整函数
- **`roundDigit<T>(iter: Iterator<T>, digit: Int64): Iterator<Float64>`** - 保留到指定小数位（单个）
- **`roundDigits<T>(iter: Iterator<T>, digits: Int64): Iterator<Float64>`** - 保留到指定小数位（批量）

### 3. 变化率计算

- **`change<T>(iter: Iterator<T>, period: Int64): Iterator<Float64>`** - 计算变化量（当前值 - 前一周期值）
- **`change_percent<T>(iter: Iterator<T>, period: Int64): Iterator<Float64>`** - 计算变化百分比
- **`change_ratio<T>(iter: Iterator<T>, period: Int64): Iterator<Float64>`** - 计算变化比率

### 4. 筛选辅助

- **`keepPositives<T>(iter: Iterator<T>): Iterator<Float64>`** - 仅保留正数
- **`keepNegatives<T>(iter: Iterator<T>): Iterator<Float64>`** - 仅保留负数

### 5. 反射与类型转换

- **`setReflectValue(field, instance, raw, format): Unit`** - 根据字符串写入实例变量
- **`getReflectValue(field, instance, format): String`** - 从实例读取变量并转为字符串

**支持类型**：
- 数值类型：Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64, Float16, Float32, Float64
- 布尔类型：Bool
- 字符串：String
- 日期时间：DateTime（支持自定义格式）

### 6. CSV 数据解析

**文件**：`csv.cj`

提供 CSV 文件的反射解析功能，可以将 CSV 数据自动映射到结构体实例。

**主要函数**：
- **`parseCSV<T>(content: String, format: String, skipHeader: Bool): Array<T>`** - 解析 CSV 字符串
- **`parseCSVFile<T>(path: String, format: String, skipHeader: Bool): Array<T>`** - 解析 CSV 文件

**使用示例**：
```cangjie
import indicator4cj.helper.*

struct KLine {
    var timestamp: DateTime
    var open: Float64
    var high: Float64
    var low: Float64
    var close: Float64
    var volume: Float64
}

// 解析 CSV 文件
let data = parseCSVFile<KLine>("data.csv", "yyyy-MM-dd HH:mm:ss", true)
```

### 7. 工具函数

- **`seq(start: Int64, end: Int64): Iterator<Int64>`** - 生成序列
- **`apply<T>(iter: Iterator<T>, f: (T) -> Unit): Unit`** - 对每个元素应用函数（副作用）
- **`drain<T>(iter: Iterator<T>): Unit`** - 消耗整个迭代器
- **`echo<T>(iter: Iterator<T>): Iterator<T>`** - 调试输出每个元素
- **`check<T>(iter: Iterator<T>, pred: (T) -> Bool): Bool`** - 检查是否所有元素满足条件
- **`pipe<T>(source, sink): Unit`** - 将迭代器数据写入目标（回调）
- **`since<T>(iter: Iterator<T>, n: Int64): Iterator<Int64>`** - 计算距第 n 个元素的周期数
- **`buffered<T>(iter: Iterator<T>, n: Int64): Iterator<Array<T>>`** - 缓冲 n 个元素为数组
- **`remove<T>(iter: Iterator<T>, n: Int64): Unit`** - 移除并消耗前 n 个元素

### 8. 特殊容器

- **`Ring<T>(size: Int64)`** - 环形缓冲区
- **`Waitable<T>`** - 可等待的值容器
- **`OrderedSet<T>`** - 有序集合

### 9. JSON 和通道转换

- **`jsonToChan<T>(json: String): Iterator<T>`** - JSON 数组转迭代器
- **`chanToJson<T>(iter: Iterator<T>): String`** - 迭代器转 JSON 数组
- **`chanToSlice<T>(iter: Iterator<T>): Array<T>`** - 迭代器转数组
- **`sliceToChan<T>(arr: Array<T>): Iterator<T>`** - 数组转迭代器
- **`slicesReverse<T>(arr: Array<T>): Array<T>`** - 数组反转

### 10. 时间和日期

- **`daysBetween(start: DateTime, end: DateTime): Int64`** - 计算两个日期之间的天数

### 11. 报告生成

**文件**：
- `report.cj` - 报告生成器
- `numeric_report_column.cj` - 数值型报告列
- `annotation_report_column.cj` - 注解型报告列
- `field.cj` - 字段定义

用于生成结构化的分析报告。

### 12. 常量定义

**文件**：`constants.cj`

定义了所有指标包使用的默认常量：

```cangjie
// 移动平均线默认周期
public const MA_DEFAULT_PERIOD: Int64 = 30

// RSI 默认参数
public const RSI_DEFAULT_PERIOD: Int64 = 14
public const RSI_SCALE_FACTOR: Float64 = 100.0

// MACD 默认参数
public const MACD_DEFAULT_FAST_PERIOD: Int64 = 12
public const MACD_DEFAULT_SLOW_PERIOD: Int64 = 26
public const MACD_DEFAULT_SIGNAL_PERIOD: Int64 = 9
public const MACD_SCALE_FACTOR: Float64 = 1000.0

// 布林带默认参数
public const BOLLINGER_BANDS_DEFAULT_PERIOD: Int64 = 20
public const BOLLINGER_BANDS_MULTIPLIER: Float64 = 2.0

// ATR 默认周期
public const ATR_DEFAULT_PERIOD: Int64 = 14

// 随机振荡器默认参数
public const STOCHASTIC_OSCILLATOR_DEFAULT_K_PERIOD: Int64 = 14
public const STOCHASTIC_OSCILLATOR_DEFAULT_D_PERIOD: Int64 = 3
```

## 使用示例

### 示例 1：基础数据转换

```cangjie
import indicator4cj.helper.*

// 将价格数组转换为迭代器
let prices = [10.0, 11.0, 12.0, 13.0, 14.0]
let iter = prices.iterator()

// 计算涨跌幅（百分比变化）
let changes = change_percent(iter, 1)

// 输出结果
for (c in changes) {
    println(c)  // 输出: None, 10.0, 9.09, 8.33, 7.69
}
```

### 示例 2：滑动窗口计算

```cangjie
import indicator4cj.helper.*
import std.collection.*

// 计算移动平均（使用 window 函数）
let data = [1.0, 2.0, 3.0, 4.0, 5.0]
let iter = data.iterator()

// 使用 3 周期窗口计算平均值
let ma3 = window(iter, 3) { buf, _ =>
    var sum = 0.0
    for (v in buf) {
        sum += v
    }
    sum / Float64(buf.size)
}

for (v in ma3) {
    println(v)  // 输出: 1.0, 1.5, 2.0, 3.0, 4.0
}
```

### 示例 3：链式操作

```cangjie
import indicator4cj.helper.*

// 计算标准化数据（z-score）
let data = [10.0, 12.0, 15.0, 13.0, 11.0]
let iter = data.iterator()

// 链式操作：去均值 -> 标准化
let mean = 12.2  // 假设已知均值
let std = 1.9    // 假设已知标准差

let normalized = iter
    |> { x => incrementBy(x, -mean) }  // 去均值
    |> { x => divideBy(x, std) }       // 标准化

for (v in normalized) {
    println(v)
}
```

### 示例 4：使用反射解析 CSV

```cangjie
import indicator4cj.helper.*
import std.io.*

struct TradeData {
    var date: DateTime
    var symbol: String
    var price: Float64
    var quantity: Int64
}

main() {
    // 从 CSV 文件解析数据
    let trades = parseCSVFile<TradeData>(
        "trades.csv",
        "yyyy-MM-dd",
        true  // 跳过标题行
    )

    // 处理数据
    for (trade in trades) {
        println("${trade.date}: ${trade.symbol} - ${trade.price}")
    }
}
```

## 注意事项

1. **迭代器消费**：所有函数都是基于迭代器的惰性计算，注意迭代器只能消费一次
2. **内存效率**：使用 `duplicate` 会创建多个迭代器，增加内存消耗
3. **数值精度**：浮点运算使用 `Float64` 类型，注意精度问题
4. **空值处理**：函数返回 `Option<T>` 时需要处理 `None` 情况
5. **类型转换**：反射函数会进行严格的类型检查，确保类型匹配

## 依赖关系

- **std.collection** - 集合类型（ArrayList, HashMap 等）
- **std.convert** - 类型转换（Int64.parse, Float64.parse 等）
- **std.math** - 数学函数（pow, sqrt, abs 等）
- **std.reflect** - 反射功能
- **std.time** - 日期时间处理

## 版本历史

### v1.0.0 (2024)
- 初始版本
- 提供完整的辅助函数集
- 支持 CSV 反射解析
- 提供流式数据处理工具
