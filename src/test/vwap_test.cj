package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class VwapTest {
    @TestCase
    public func vwap_basic() {
        let input = ReadFromCsvFile<VwapData>("src/test/testdata/volume/vwap.csv")
        let inputs = Duplicate(input, 3)
        let closings = Map(inputs[0], { m => m.Close })
        let volumes = Map(inputs[1], { m => Float64(m.Volume) })
        var expected = Map(inputs[2], { m => m.Vwap })

        let vwap = Vwap()
        let actual = RoundDigits(vwap.compute(closings, volumes), 2)
        expected = Skip(expected, vwap.idlePeriod())

        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class VwapData {
    public var Close: Float64 = 0.0
    public var Volume: Int64 = 0
    public var Vwap: Float64 = 0.0
    public init() {}
}

