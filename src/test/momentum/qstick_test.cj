package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class QstickRow {
    public let open: Float64
    public let close: Float64
    public let Qstick: Float64
    public init(Open: Float64, Close: Float64, Qstick: Float64) {
        this.open = Open
        this.close = Close
        this.Qstick = Qstick
    }
}

@Test
public func qstick_basic() {
    let input = Csv<QstickRow>().readFromFile("src/test/testdata/momentum/qstick.csv")
    let inputs = duplicate(input, 3)
    let opens = map(inputs[0], { d: QstickRow => d.open })
    let closes = map(inputs[1], { d: QstickRow => d.close })
    var expected = map(inputs[2], { d: QstickRow => d.Qstick })

    let qs = Qstick(10)
    var actual = qs.compute(opens, closes)
    actual = roundDigits(actual, 2)
    expected = skip(expected, qs.idlePeriod())

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

