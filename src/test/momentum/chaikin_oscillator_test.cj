package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class ChaikinRow {
    public let High: Float64
    public let Low: Float64
    public let Close: Float64
    public let Volume: Float64
    public let Chaikin: Float64
    public init(High: Float64, Low: Float64, Close: Float64, Volume: Float64, Chaikin: Float64) {
        this.High = High
        this.Low = Low
        this.Close = Close
        this.Volume = Volume
        this.Chaikin = Chaikin
    }
}

@Test
public func chaikin_basic() {
    let input = ReadFromCsvFile<ChaikinRow>("src/test/testdata/momentum/chaikin_oscillator.csv")
    let inputs = Duplicate(input, 5)
    let highs = Map(inputs[0], { d: ChaikinRow => d.High })
    let lows = Map(inputs[1], { d: ChaikinRow => d.Low })
    let closes = Map(inputs[2], { d: ChaikinRow => d.Close })
    let volumes = Map(inputs[3], { d: ChaikinRow => d.Volume })
    var expected = Map(inputs[4], { d: ChaikinRow => d.Chaikin })

    let co = ChaikinOscillator()
    var actual = co.compute(highs, lows, closes, volumes)
    actual = RoundDigits(actual, 2)
    expected = Skip(expected, co.IdlePeriod())

    match (CheckEquals(actual, expected)) {
        case Some(err) => fail(err)
        case None => ()
    }
}

