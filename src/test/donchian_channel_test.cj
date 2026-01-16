package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class DonchianRow {
    public let close: Float64
    public let upper: Float64
    public let middle: Float64
    public let lower: Float64
    public init(Close: Float64, Upper: Float64, Middle: Float64, Lower: Float64) {
        this.close = Close
        this.upper = Upper
        this.middle = Middle
        this.lower = Lower
    }
}

@Test
public func donchian_channel_basic() {
    let input = Csv<DonchianRow>().readFromFile("src/test/testdata/volatility/donchian_channel.csv")
    let inputs = Duplicate(input, 4)
    let closings = Map(inputs[0], { d: DonchianRow => d.close })
    let expUpper = Map(inputs[1], { d: DonchianRow => d.upper })
    let expMiddle = Map(inputs[2], { d: DonchianRow => d.middle })
    let expLower = Map(inputs[3], { d: DonchianRow => d.lower })

    let dc = DonchianChannel()
    var (actUpper, actMiddle, actLower) = dc.compute(closings)
    actUpper = RoundDigits(actUpper, 2)
    actMiddle = RoundDigits(actMiddle, 2)
    actLower = RoundDigits(actLower, 2)

    let skip = dc.idlePeriod()
    let eUpper = Skip(expUpper, skip)
    let eMiddle = Skip(expMiddle, skip)
    let eLower = Skip(expLower, skip)

    match (CheckEquals(actUpper, eUpper)) { case Some(err) => fail("upper " + err) case None => () }
    match (CheckEquals(actMiddle, eMiddle)) { case Some(err) => fail("middle " + err) case None => () }
    match (CheckEquals(actLower, eLower)) { case Some(err) => fail("lower " + err) case None => () }
}

