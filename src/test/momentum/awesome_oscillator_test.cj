package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class AwesomeRow {
    public let high: Float64
    public let low: Float64
    public let Awesome: Float64
    public init(High: Float64, Low: Float64, Awesome: Float64) {
        this.high = High
        this.low = Low
        this.Awesome = Awesome
    }
}

@Test
public func awesome_basic() {
    let input = Csv<AwesomeRow>().readFromFile("src/test/testdata/momentum/awesome_oscillator.csv")
    let inputs = duplicate(input, 3)
    let highs = map(inputs[0], { d: AwesomeRow => d.high })
    let lows = map(inputs[1], { d: AwesomeRow => d.low })
    var expected = map(inputs[2], { d: AwesomeRow => d.Awesome })

    let ao = AwesomeOscillator()
    var actual = ao.compute(highs, lows)
    actual = roundDigits(actual, 2)
    expected = skip(expected, ao.idlePeriod())

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

