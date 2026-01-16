package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class BollingerBandWidthRow {
    public let close: Float64
    public let Width: Float64
    public init(c: Float64, w: Float64) {
        this.close = c
        this.Width = w
    }
}

@Test
public func bollinger_band_width_basic() {
    let input = Csv<BollingerBandWidthRow>().readFromFile("src/test/testdata/volatility/bollinger_band_width.csv")
    let inputs = duplicate(input, 2)
    let closings = map(inputs[0], { d: BollingerBandWidthRow => d.close })
    let expected = map(inputs[1], { d: BollingerBandWidthRow => d.Width })

    let bbw = BollingerBandWidth()
    var actual = bbw.compute(closings)
    actual = roundDigits(actual, 2)

    let exp = skip(expected, bbw.idlePeriod())

    match (checkEquals(actual, exp)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

