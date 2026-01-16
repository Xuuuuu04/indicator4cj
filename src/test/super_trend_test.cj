package indicator4cj.test

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
    let inputs = Duplicate(input, 4)
    let highs = Map(inputs[0], { d: SuperTrendRow => d.high })
    let lows = Map(inputs[1], { d: SuperTrendRow => d.low })
    let closings = Map(inputs[2], { d: SuperTrendRow => d.close })
    var expected = Map(inputs[3], { d: SuperTrendRow => d.SuperTrend })

    let st = SuperTrend()
    var actual = RoundDigits(st.compute(highs, lows, closings), 2)
    expected = Skip(expected, st.idlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

