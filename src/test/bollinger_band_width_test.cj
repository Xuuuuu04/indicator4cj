package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class BollingerBandWidthRow {
    public let Close: Float64
    public let Width: Float64
    public init(c: Float64, w: Float64) {
        this.Close = c
        this.Width = w
    }
}

@Test
public func bollinger_band_width_basic() {
    let input = ReadFromCsvFile<BollingerBandWidthRow>("src/test/testdata/volatility/bollinger_band_width.csv")
    let inputs = Duplicate(input, 2)
    let closings = Map(inputs[0], { d: BollingerBandWidthRow => d.Close })
    let expected = Map(inputs[1], { d: BollingerBandWidthRow => d.Width })

    let bbw = BollingerBandWidth()
    var actual = bbw.Compute(closings)
    actual = RoundDigits(actual, 2)

    let exp = Skip(expected, bbw.IdlePeriod())

    match (CheckEquals(actual, exp)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

