package indicator4cj.test.volatility

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
    let inputs = duplicate(input, 4)
    let closings = map(inputs[0], { d: DonchianRow => d.close })
    let expUpper = map(inputs[1], { d: DonchianRow => d.upper })
    let expMiddle = map(inputs[2], { d: DonchianRow => d.middle })
    let expLower = map(inputs[3], { d: DonchianRow => d.lower })

    let dc = DonchianChannel()
    var (actUpper, actMiddle, actLower) = dc.compute(closings)
    actUpper = roundDigits(actUpper, 2)
    actMiddle = roundDigits(actMiddle, 2)
    actLower = roundDigits(actLower, 2)

    let skipCount = dc.idlePeriod()
    let eUpper = skip(expUpper, skipCount)
    let eMiddle = skip(expMiddle, skipCount)
    let eLower = skip(expLower, skipCount)

    match (checkEquals(actUpper, eUpper)) { case Some(err) => fail("upper " + err) case None => () }
    match (checkEquals(actMiddle, eMiddle)) { case Some(err) => fail("middle " + err) case None => () }
    match (checkEquals(actLower, eLower)) { case Some(err) => fail("lower " + err) case None => () }
}

