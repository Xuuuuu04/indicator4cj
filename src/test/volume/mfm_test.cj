package indicator4cj.test.volume

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class MfmTest {
    @TestCase
    public func mfm_basic() {
        let input = Csv<MfmRow>().readFromFile("src/test/testdata/volume/mfm.csv")
        let inputs = duplicate(input, 4)
        let highs = map(inputs[0], { m => m.high })
        let lows = map(inputs[1], { m => m.low })
        let closes = map(inputs[2], { m => m.close })
        var expected = map(inputs[3], { m => m.mfm })

        let mfm = Mfm()
        let actual = roundDigits(mfm.compute(highs, lows, closes), 2)
        expected = skip(expected, mfm.idlePeriod())

        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class MfmRow {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var mfm: Float64 = 0.0
    public init() {}
}

