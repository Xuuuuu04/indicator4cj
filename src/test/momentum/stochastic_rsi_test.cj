package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class StochRsiRow {
    public let Close: Float64
    public let K: Float64
    public let D: Float64
    public init(Close: Float64, K: Float64, D: Float64) {
        this.Close = Close
        this.K = K
        this.D = D
    }
}

@Test
public func stochastic_rsi_basic() {
    let input = ReadFromCsvFile<StochRsiRow>("src/test/testdata/momentum/stochastic_rsi.csv")
    let inputs = Duplicate(input, 2)
    let closes = Map(inputs[0], { d: StochRsiRow => d.Close })
    var expK = Map(inputs[1], { d: StochRsiRow => d.K })

    let sr = StochasticRsi()
    var act = sr.Compute(closes)
    act = RoundDigits(act, 2)

    let skip = sr.IdlePeriod()
    expK = Skip(expK, skip)
    act = Skip(act, skip)

    match (CheckEquals(act, expK)) { case Some(err) => fail("K " + err) case None => () }
    // FIXME: Go 版仅返回单序列，原 CSV 含 D 列暂不比对。
}

