package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class EmvTest {
    @TestCase
    public func emv_basic() {
        let input = Csv<EmvRow>().readFromFile("src/test/testdata/volume/emv.csv")
        let inputs = duplicate(input, 4)
        let highs = map(inputs[0], { m => m.high })
        let lows = map(inputs[1], { m => m.low })
        let volumes = map(inputs[2], { m => Float64(m.volume) })
        var expected = map(inputs[3], { m => m.Emv })

        let emv = Emv()
        let actual = roundDigits(emv.compute(highs, lows, volumes), 2)
        expected = skip(expected, emv.idlePeriod())

        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class EmvRow {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var volume: Int64 = 0
    public var Emv: Float64 = 0.0
    public init() {}
}

