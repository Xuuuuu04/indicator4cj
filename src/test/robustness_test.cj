package indicator4cj.test

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.trend.*
import indicator4cj.momentum.*
import indicator4cj.volatility.*

@Test
public func test_empty_input_robustness() {
    // 测试常见指标对空输入的处理
    let empty_floats1 = ArrayList<Float64>().iterator()
    let empty_floats2 = ArrayList<Float64>().iterator()
    let empty_floats3 = ArrayList<Float64>().iterator()

    // Trend
    let ema = Ema(14).Compute(empty_floats1)
    if (ema.next().isSome()) { fail("EMA should be empty for empty input") }

    let sma = Sma(14).Compute(empty_floats2)
    if (sma.next().isSome()) { fail("SMA should be empty for empty input") }

    // Momentum
    let rsi = Rsi(14).Compute(empty_floats3)
    if (rsi.next().isSome()) { fail("RSI should be empty for empty input") }

    // Volatility (ATR requires 3 inputs)
    let h = ArrayList<Float64>().iterator()
    let l = ArrayList<Float64>().iterator()
    let c = ArrayList<Float64>().iterator()
    let atr = Atr(14).Compute(h, l, c)
    if (atr.next().isSome()) { fail("ATR should be empty for empty input") }
}

@Test
public func test_single_element_input_robustness() {
    let single_float = ArrayList<Float64>([100.0]).iterator()
    
    // EMA(14) 对单元素输入不应崩溃
    let ema = Ema(14).Compute(single_float)
    while (ema.next().isSome()) { } // consume
}

@Test
public func test_period_one_robustness() {
    let data = ArrayList<Float64>([10.0, 20.0, 30.0]).iterator()
    // SMA(1) 应该等于原始数据
    let sma1 = Sma(1).Compute(data)
    if (sma1.next().getOrThrow() != 10.0) { fail("SMA(1) fail at index 0") }
    if (sma1.next().getOrThrow() != 20.0) { fail("SMA(1) fail at index 1") }
    if (sma1.next().getOrThrow() != 30.0) { fail("SMA(1) fail at index 2") }
}

@Test
public func test_large_data_performance() {
    let count = 100000
    let large_data = ArrayList<Float64>()
    for (i in 0..count) {
        large_data.add(Float64(i))
    }
    
    let source = large_data.iterator()
    let ema = Ema(14).Compute(source)
    
    var processed = 0
    while (ema.next().isSome()) {
        processed += 1
    }
    // EMA(14) 会消耗 14 个点输出第 1 个，之后每输入 1 个输出 1 个。
    // 总输出数应该是 count - 14 + 1 = count - 13
    if (processed == 0 && count > 14) { fail("Processed 0, large data computation failed") }
}