package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class ChaikinRow {
    public let high: Float64
    public let low: Float64
    public let close: Float64
    public let volume: Float64
    public let Chaikin: Float64
    public init(High: Float64, Low: Float64, Close: Float64, Volume: Float64, Chaikin: Float64) {
        this.high = High
        this.low = Low
        this.close = Close
        this.volume = Volume
        this.Chaikin = Chaikin
    }
}

@Test
public func chaikin_basic() {
    let input = Csv<ChaikinRow>().readFromFile("src/test/testdata/momentum/chaikin_oscillator.csv")
    let inputs = duplicate(input, 5)
    let highs = map(inputs[0], { d: ChaikinRow => d.high })
    let lows = map(inputs[1], { d: ChaikinRow => d.low })
    let closes = map(inputs[2], { d: ChaikinRow => d.close })
    let volumes = map(inputs[3], { d: ChaikinRow => d.volume })
    var expected = map(inputs[4], { d: ChaikinRow => d.Chaikin })

    let co = ChaikinOscillator()
    var actual = co.compute(highs, lows, closes, volumes)
    actual = roundDigits(actual, 2)
    expected = skip(expected, co.idlePeriod())

    match (checkEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

