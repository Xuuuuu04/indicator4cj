package indicator4cj.test.volatility

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class UlcerRow {
    public let close: Float64
    public let UlcerIndex: Float64
    public init(Close: Float64, UlcerIndex: Float64) {
        this.close = Close
        this.UlcerIndex = UlcerIndex
    }
}

@Test
public func ulcer_index_basic() {
    let input = Csv<UlcerRow>().readFromFile("src/test/testdata/volatility/ulcer_index.csv")
    let inputs = duplicate(input, 2)
    let closings = map(inputs[0], { d: UlcerRow => d.close })
    var expected = map(inputs[1], { d: UlcerRow => d.UlcerIndex })

    let ui = UlcerIndex()
    var actual = ui.compute(closings)
    actual = roundDigits(actual, 2)

    expected = skip(expected, ui.idlePeriod())

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

