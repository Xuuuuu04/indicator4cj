package indicator4cj.test

import std.core.*
import indicator4cj.helper.*
import indicator4cj.volatility.*

public class UlcerRow {
    public let Close: Float64
    public let UlcerIndex: Float64
    public init(Close: Float64, UlcerIndex: Float64) {
        this.Close = Close
        this.UlcerIndex = UlcerIndex
    }
}

@Test
public func ulcer_index_basic() {
    let input = ReadFromCsvFile<UlcerRow>("src/test/testdata/volatility/ulcer_index.csv")
    let inputs = Duplicate(input, 2)
    let closings = Map(inputs[0], { d: UlcerRow => d.Close })
    var expected = Map(inputs[1], { d: UlcerRow => d.UlcerIndex })

    let ui = UlcerIndex()
    var actual = ui.compute(closings)
    actual = RoundDigits(actual, 2)

    expected = Skip(expected, ui.idlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

