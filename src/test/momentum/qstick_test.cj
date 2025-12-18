package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class QstickRow {
    public let Open: Float64
    public let Close: Float64
    public let Qstick: Float64
    public init(Open: Float64, Close: Float64, Qstick: Float64) {
        this.Open = Open
        this.Close = Close
        this.Qstick = Qstick
    }
}

@Test
public func qstick_basic() {
    let input = ReadFromCsvFile<QstickRow>("src/test/testdata/momentum/qstick.csv")
    let inputs = Duplicate(input, 3)
    let opens = Map(inputs[0], { d: QstickRow => d.Open })
    let closes = Map(inputs[1], { d: QstickRow => d.Close })
    var expected = Map(inputs[2], { d: QstickRow => d.Qstick })

    let qs = Qstick(10)
    var actual = qs.Compute(opens, closes)
    actual = RoundDigits(actual, 2)
    expected = Skip(expected, qs.IdlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

