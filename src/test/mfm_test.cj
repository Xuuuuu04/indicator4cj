package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class MfmTest {
    @TestCase
    public func mfm_basic() {
        let input = Csv<MfmRow>().readFromFile("src/test/testdata/volume/mfm.csv")
        let inputs = Duplicate(input, 4)
        let highs = Map(inputs[0], { m => m.high })
        let lows = Map(inputs[1], { m => m.low })
        let closes = Map(inputs[2], { m => m.close })
        var expected = Map(inputs[3], { m => m.Mfm })

        let mfm = Mfm()
        let actual = RoundDigits(mfm.compute(highs, lows, closes), 2)
        expected = Skip(expected, mfm.idlePeriod())

        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class MfmRow {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var Mfm: Float64 = 0.0
    public init() {}
}

