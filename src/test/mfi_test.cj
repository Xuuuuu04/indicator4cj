package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class MfiTest {
    @TestCase
    public func mfi_basic() {
        let input = ReadFromCsvFile<MfiData>("src/test/testdata/volume/mfi.csv")
        let inputs = Duplicate(input, 5)
        let highs = Map(inputs[0], { m => m.High })
        let lows = Map(inputs[1], { m => m.Low })
        let closings = Map(inputs[2], { m => m.Close })
        let volumes = Map(inputs[3], { m => Float64(m.Volume) })
        var expected = Map(inputs[4], { m => m.Mfi })

        let mfi = Mfi()
        let actual = RoundDigits(mfi.Compute(highs, lows, closings, volumes), 2)
        expected = Skip(expected, mfi.IdlePeriod())

        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class MfiData {
    public var High: Float64 = 0.0
    public var Low: Float64 = 0.0
    public var Close: Float64 = 0.0
    public var Volume: Int64 = 0
    public var Mfi: Float64 = 0.0
    public init() {}
}

