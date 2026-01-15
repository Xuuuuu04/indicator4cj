package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class SpecialKRow {
    public let Close: Float64
    public let SpecialK: Float64
    public init(Close: Float64, SpecialK: Float64) {
        this.Close = Close
        this.SpecialK = SpecialK
    }
}

@Test
public func prings_special_k_basic() {
    let input = ReadFromCsvFile<SpecialKRow>("src/test/testdata/momentum/prings_special_k.csv")
    let inputs = Duplicate(input, 2)
    let closes = Map(inputs[0], { d: SpecialKRow => d.Close })
    var expected = Map(inputs[1], { d: SpecialKRow => d.SpecialK })

    let sk = PringsSpecialK()
    var actual = sk.compute(closes)
    actual = RoundDigits(actual, 2)
    expected = Skip(expected, sk.idlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

