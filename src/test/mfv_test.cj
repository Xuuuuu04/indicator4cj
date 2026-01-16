package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class MfvTest {
    @TestCase
    public func mfv_basic() {
        let input = Csv<MfvRow>().readFromFile("src/test/testdata/volume/mfv.csv")
        let inputs = Duplicate(input, 5)
        let highs = Map(inputs[0], { m => m.high })
        let lows = Map(inputs[1], { m => m.low })
        let closes = Map(inputs[2], { m => m.close })
        let volumes = Map(inputs[3], { m => Float64(m.volume) })
        var expected = Map(inputs[4], { m => m.Mfv })

        let mfv = Mfv()
        let actual = RoundDigits(mfv.compute(highs, lows, closes, volumes), 2)
        expected = Skip(expected, mfv.idlePeriod())

        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class MfvRow {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var volume: Int64 = 0
    public var Mfv: Float64 = 0.0
    public init() {}
}

