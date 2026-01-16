package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class PvoRow {
    public let volume: Float64
    public let Pvo: Float64
    public init(Volume: Float64, Pvo: Float64) {
        this.volume = Volume
        this.Pvo = Pvo
    }
}

@Test
public func pvo_basic() {
    let input = Csv<PvoRow>().readFromFile("src/test/testdata/momentum/pvo.csv")
    let inputs = duplicate(input, 2)
    let volumes = map(inputs[0], { d: PvoRow => d.volume })
    var expected = map(inputs[1], { d: PvoRow => d.Pvo })

    let pvo = Pvo()
    var actual = pvo.compute(volumes)
    actual = roundDigits(actual, 2)
    expected = skip(expected, pvo.idlePeriod())

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

