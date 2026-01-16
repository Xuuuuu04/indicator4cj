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
    let inputs = duplicate(input, 4)
    let closings = map(inputs[0], { d: BollingerBandsData => d.close })
    let upper = map(inputs[1], { d: BollingerBandsData => d.upper })
    let middle = map(inputs[2], { d: BollingerBandsData => d.middle })
    let lower = map(inputs[3], { d: BollingerBandsData => d.lower })

    let bb = BollingerBands()
    var (actualUpper, actualMiddle, actualLower) = bb.compute(closings)
    actualUpper = roundDigits(actualUpper, 2)
    actualMiddle = roundDigits(actualMiddle, 2)
    actualLower = roundDigits(actualLower, 2)

    let idle = bb.idlePeriod()
    let expUpper = skip(upper, idle)
    let expMiddle = skip(middle, idle)
    let expLower = skip(lower, idle)

    match (checkEquals(actualUpper, expUpper)) {
        case Some(err) => fail("upper " + err)
        case None => ()
    }
    match (checkEquals(actualMiddle, expMiddle)) {
        case Some(err) => fail("middle " + err)
        case None => ()
    }
    match (checkEquals(actualLower, expLower)) {
        case Some(err) => fail("lower " + err)
        case None => ()
    }
}

