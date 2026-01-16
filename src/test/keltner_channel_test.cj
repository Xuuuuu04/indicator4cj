package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class KeltnerRow {
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
public func keltner_channel_basic() {
    let input = Csv<KeltnerRow>().readFromFile("src/test/testdata/volatility/keltner_channel.csv")
    let inputs = duplicate(input, 6)
    let highs = map(inputs[0], { d: KeltnerRow => d.high })
    let lows = map(inputs[1], { d: KeltnerRow => d.low })
    let closings = map(inputs[2], { d: KeltnerRow => d.close })
    let expUpper = map(inputs[3], { d: KeltnerRow => d.upper })
    let expMiddle = map(inputs[4], { d: KeltnerRow => d.middle })
    let expLower = map(inputs[5], { d: KeltnerRow => d.lower })

    let kc = KeltnerChannel()
    var (actUpper, actMiddle, actLower) = kc.compute(highs, lows, closings)
    actUpper = roundDigits(actUpper, 2)
    actMiddle = roundDigits(actMiddle, 2)
    actLower = roundDigits(actLower, 2)

    let skipCount = kc.idlePeriod()
    let eUpper = skip(expUpper, skipCount)
    let eMiddle = skip(expMiddle, skipCount)
    let eLower = skip(expLower, skipCount)

    match (checkEquals(actUpper, eUpper)) { case Some(err) => fail("upper " + err) case None => () }
    match (checkEquals(actMiddle, eMiddle)) { case Some(err) => fail("middle " + err) case None => () }
    match (checkEquals(actLower, eLower)) { case Some(err) => fail("lower " + err) case None => () }
}

