package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class BollingerBandsData {
    public let close: Float64
    public let upper: Float64
    public let middle: Float64
    public let lower: Float64
    public init(c: Float64, u: Float64, m: Float64, l: Float64) {
        this.close = c
        this.upper = u
        this.middle = m
        this.lower = l
    }
}

@Test
public func bollinger_bands_basic() {
    let input = Csv<BollingerBandsData>().readFromFile("src/test/testdata/volatility/bollinger_bands.csv")
    let inputs = Duplicate(input, 4)
    let closings = Map(inputs[0], { d: BollingerBandsData => d.close })
    let upper = Map(inputs[1], { d: BollingerBandsData => d.upper })
    let middle = Map(inputs[2], { d: BollingerBandsData => d.middle })
    let lower = Map(inputs[3], { d: BollingerBandsData => d.lower })

    let bb = BollingerBands()
    var (actualUpper, actualMiddle, actualLower) = bb.compute(closings)
    actualUpper = RoundDigits(actualUpper, 2)
    actualMiddle = RoundDigits(actualMiddle, 2)
    actualLower = RoundDigits(actualLower, 2)

    let idle = bb.idlePeriod()
    let expUpper = Skip(upper, idle)
    let expMiddle = Skip(middle, idle)
    let expLower = Skip(lower, idle)

    match (CheckEquals(actualUpper, expUpper)) {
        case Some(err) => fail("upper " + err)
        case None => ()
    }
    match (CheckEquals(actualMiddle, expMiddle)) {
        case Some(err) => fail("middle " + err)
        case None => ()
    }
    match (CheckEquals(actualLower, expLower)) {
        case Some(err) => fail("lower " + err)
        case None => ()
    }
}

