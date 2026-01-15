package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class AwesomeRow {
    public let High: Float64
    public let Low: Float64
    public let Awesome: Float64
    public init(High: Float64, Low: Float64, Awesome: Float64) {
        this.High = High
        this.Low = Low
        this.Awesome = Awesome
    }
}

@Test
public func awesome_basic() {
    let input = ReadFromCsvFile<AwesomeRow>("src/test/testdata/momentum/awesome_oscillator.csv")
    let inputs = Duplicate(input, 3)
    let highs = Map(inputs[0], { d: AwesomeRow => d.High })
    let lows = Map(inputs[1], { d: AwesomeRow => d.Low })
    var expected = Map(inputs[2], { d: AwesomeRow => d.Awesome })

    let ao = AwesomeOscillator()
    var actual = ao.compute(highs, lows)
    actual = RoundDigits(actual, 2)
    expected = Skip(expected, ao.idlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

