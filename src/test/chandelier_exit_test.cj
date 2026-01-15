package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class ChandelierRow {
    public let High: Float64
    public let Low: Float64
    public let Close: Float64
    public let Long: Float64
    public let Short: Float64
    public init(High: Float64, Low: Float64, Close: Float64, Long: Float64, Short: Float64) {
        this.High = High
        this.Low = Low
        this.Close = Close
        this.Long = Long
        this.Short = Short
    }
}

@Test
public func chandelier_exit_basic() {
    let input = ReadFromCsvFile<ChandelierRow>("src/test/testdata/volatility/chandelier_exit.csv")
    let inputs = Duplicate(input, 5)
    let highs = Map(inputs[0], { d: ChandelierRow => d.High })
    let lows = Map(inputs[1], { d: ChandelierRow => d.Low })
    let closings = Map(inputs[2], { d: ChandelierRow => d.Close })
    let expLong = Map(inputs[3], { d: ChandelierRow => d.Long })
    let expShort = Map(inputs[4], { d: ChandelierRow => d.Short })

    let ce = ChandelierExit()
    var (actLong, actShort) = ce.compute(highs, lows, closings)
    actLong = RoundDigits(actLong, 2)
    actShort = RoundDigits(actShort, 2)

    let skip = ce.idlePeriod()
    let eLong = Skip(expLong, skip)
    let eShort = Skip(expShort, skip)

    match (CheckEquals(actLong, eLong)) { case Some(err) => fail("long " + err) case None => () }
    match (CheckEquals(actShort, eShort)) { case Some(err) => fail("short " + err) case None => () }
}

