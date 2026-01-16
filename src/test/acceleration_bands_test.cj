package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class AccelRow {
    public let high: Float64
    public let low: Float64
    public let close: Float64
    public let upper: Float64
    public let middle: Float64
    public let lower: Float64
    public init(High: Float64, Low: Float64, Close: Float64, Upper: Float64, Middle: Float64, Lower: Float64) {
        this.high = High
        this.low = Low
        this.close = Close
        this.upper = Upper
        this.middle = Middle
        this.lower = Lower
    }
}

@Test
public func acceleration_bands_basic() {
    let input = Csv<AccelRow>().readFromFile("src/test/testdata/volatility/acceleration_bands.csv")
    let inputs = Duplicate(input, 6)
    let highs = Map(inputs[0], { d: AccelRow => d.high })
    let lows = Map(inputs[1], { d: AccelRow => d.low })
    let closings = Map(inputs[2], { d: AccelRow => d.close })
    let expUpper = Map(inputs[3], { d: AccelRow => d.upper })
    let expMiddle = Map(inputs[4], { d: AccelRow => d.middle })
    let expLower = Map(inputs[5], { d: AccelRow => d.lower })

    let ab = AccelerationBands()
    var (actUpper, actMiddle, actLower) = ab.compute(highs, lows, closings)
    actUpper = RoundDigits(actUpper, 2)
    actMiddle = RoundDigits(actMiddle, 2)
    actLower = RoundDigits(actLower, 2)

    let skip = ab.idlePeriod()
    let eUpper = Skip(expUpper, skip)
    let eMiddle = Skip(expMiddle, skip)
    let eLower = Skip(expLower, skip)

    match (CheckEquals(actUpper, eUpper)) { case Some(err) => fail("upper " + err) case None => () }
    match (CheckEquals(actMiddle, eMiddle)) { case Some(err) => fail("middle " + err) case None => () }
    match (CheckEquals(actLower, eLower)) { case Some(err) => fail("lower " + err) case None => () }
}

