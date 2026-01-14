package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class PvoRow {
    public let Volume: Float64
    public let Pvo: Float64
    public init(Volume: Float64, Pvo: Float64) {
        this.Volume = Volume
        this.Pvo = Pvo
    }
}

@Test
public func pvo_basic() {
    let input = ReadFromCsvFile<PvoRow>("src/test/testdata/momentum/pvo.csv")
    let inputs = Duplicate(input, 2)
    let volumes = Map(inputs[0], { d: PvoRow => d.Volume })
    var expected = Map(inputs[1], { d: PvoRow => d.Pvo })

    let pvo = Pvo()
    var actual = pvo.compute(volumes)
    actual = RoundDigits(actual, 2)
    expected = Skip(expected, pvo.IdlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

