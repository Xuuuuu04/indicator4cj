package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class MfiTest {
    @TestCase
    public func mfi_basic() {
        let input = Csv<MfiData>().readFromFile("src/test/testdata/volume/mfi.csv")
        let inputs = duplicate(input, 5)
        let highs = map(inputs[0], { m => m.high })
        let lows = map(inputs[1], { m => m.low })
        let closings = map(inputs[2], { m => m.close })
        let volumes = map(inputs[3], { m => Float64(m.volume) })
        var expected = map(inputs[4], { m => m.mfi })

        let mfi = Mfi()
        let actual = roundDigits(mfi.compute(highs, lows, closings, volumes), 2)
        expected = skip(expected, mfi.idlePeriod())

        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class MfiData {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var volume: Int64 = 0
    public var mfi: Float64 = 0.0
    public init() {}
}

