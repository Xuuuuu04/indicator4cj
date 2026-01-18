package indicator4cj.test.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class SuperTrendRow {
    public let high: Float64
    public let low: Float64
    public let close: Float64
    public let SuperTrend: Float64
    public init(High: Float64, Low: Float64, Close: Float64, SuperTrend: Float64) {
        this.high = High
        this.low = Low
        this.close = Close
        this.SuperTrend = SuperTrend
    }
}

@Test
public func super_trend_basic() {
    let input = Csv<SuperTrendRow>().readFromFile("src/test/testdata/volatility/super_trend.csv")
    let inputs = duplicate(input, 4)
    let highs = map(inputs[0], { d: SuperTrendRow => d.high })
    let lows = map(inputs[1], { d: SuperTrendRow => d.low })
    let closings = map(inputs[2], { d: SuperTrendRow => d.close })
    var expected = map(inputs[3], { d: SuperTrendRow => d.SuperTrend })

    let st = SuperTrend()
    var actual = roundDigits(st.compute(highs, lows, closings), 2)
    expected = skip(expected, st.idlePeriod())

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

