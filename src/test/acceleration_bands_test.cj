package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class AccelRow {
    public let High: Float64
    public let Low: Float64
    public let Close: Float64
    public let Upper: Float64
    public let Middle: Float64
    public let Lower: Float64
    public init(High: Float64, Low: Float64, Close: Float64, Upper: Float64, Middle: Float64, Lower: Float64) {
        this.High = High
        this.Low = Low
        this.Close = Close
        this.Upper = Upper
        this.Middle = Middle
        this.Lower = Lower
    }
}

@Test
public func acceleration_bands_basic() {
    let input = ReadFromCsvFile<AccelRow>("src/test/testdata/volatility/acceleration_bands.csv")
    let inputs = Duplicate(input, 6)
    let highs = Map(inputs[0], { d: AccelRow => d.High })
    let lows = Map(inputs[1], { d: AccelRow => d.Low })
    let closings = Map(inputs[2], { d: AccelRow => d.Close })
    let expUpper = Map(inputs[3], { d: AccelRow => d.Upper })
    let expMiddle = Map(inputs[4], { d: AccelRow => d.Middle })
    let expLower = Map(inputs[5], { d: AccelRow => d.Lower })

    let ab = AccelerationBands()
    var (actUpper, actMiddle, actLower) = ab.Compute(highs, lows, closings)
    actUpper = RoundDigits(actUpper, 2)
    actMiddle = RoundDigits(actMiddle, 2)
    actLower = RoundDigits(actLower, 2)

    let skip = ab.IdlePeriod()
    let eUpper = Skip(expUpper, skip)
    let eMiddle = Skip(expMiddle, skip)
    let eLower = Skip(expLower, skip)

    match (CheckEquals(actUpper, eUpper)) { case Some(err) => fail("upper " + err) case None => () }
    match (CheckEquals(actMiddle, eMiddle)) { case Some(err) => fail("middle " + err) case None => () }
    match (CheckEquals(actLower, eLower)) { case Some(err) => fail("lower " + err) case None => () }
}

