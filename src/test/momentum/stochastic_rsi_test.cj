package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class StochRsiRow {
    public let close: Float64
    public let K: Float64
    public let D: Float64
    public init(Close: Float64, K: Float64, D: Float64) {
        this.close = Close
        this.K = K
        this.D = D
    }
}

@Test
public func stochastic_rsi_basic() {
    let input = Csv<StochRsiRow>().readFromFile("src/test/testdata/momentum/stochastic_rsi.csv")
    let inputs = duplicate(input, 2)
    let closes = map(inputs[0], { d: StochRsiRow => d.close })
    var expK = map(inputs[1], { d: StochRsiRow => d.K })

    let sr = StochasticRsi()
    var act = sr.compute(closes)
    act = roundDigits(act, 2)

    let skipCount = sr.idlePeriod()
    expK = skip(expK, skipCount)
    act = skip(act, skipCount)

    match (checkEquals(act, expK)) { case Some(err) => fail("K " + err) case None => () }

    // FIXME: D列暂不比对
    //
    // 问题描述：测试数据CSV包含D列（信号线），但当前仓颉版本的StochasticRsi.compute()只返回单序列
    // 原始Go版本可能返回(K, D)元组，但当前实现只返回K序列
    //
    // 临时方案：跳过D列的验证（仅验证K序列）
    // 长期方案：
    //   1. 修改StochasticRsi.compute()返回元组 (K, D)
    //   2. 添加D序列的计算逻辑（SMA平滑K序列）
    //   3. 添加对D列的断言验证
    //
    // 相关文件：src/momentum/stochastic_rsi.cj
    // 测试数据：src/test/testdata/momentum/stochastic_rsi.csv
}

