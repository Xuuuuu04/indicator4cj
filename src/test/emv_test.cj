package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class EmvTest {
    @TestCase
    public func emv_basic() {
        let input = ReadFromCsvFile<EmvRow>("src/test/testdata/volume/emv.csv")
        let inputs = Duplicate(input, 4)
        let highs = Map(inputs[0], { m => m.High })
        let lows = Map(inputs[1], { m => m.Low })
        let volumes = Map(inputs[2], { m => Float64(m.Volume) })
        var expected = Map(inputs[3], { m => m.Emv })

        let emv = Emv()
        let actual = RoundDigits(emv.compute(highs, lows, volumes), 2)
        expected = Skip(expected, emv.IdlePeriod())

        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class EmvRow {
    public var High: Float64 = 0.0
    public var Low: Float64 = 0.0
    public var Volume: Int64 = 0
    public var Emv: Float64 = 0.0
    public init() {}
}

