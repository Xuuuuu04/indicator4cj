package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class PpoRow {
    public let close: Float64
    public let Ppo: Float64
    public init(Close: Float64, Ppo: Float64) {
        this.close = Close
        this.Ppo = Ppo
    }
}

@Test
public func ppo_basic() {
    let input = Csv<PpoRow>().readFromFile("src/test/testdata/momentum/ppo.csv")
    let inputs = duplicate(input, 2)
    let closes = map(inputs[0], { d: PpoRow => d.close })
    var expected = map(inputs[1], { d: PpoRow => d.Ppo })

    let ppo = Ppo()
    var actual = ppo.compute(closes)
    actual = roundDigits(actual, 2)
    expected = skip(expected, ppo.idlePeriod())

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

