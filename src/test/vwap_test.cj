package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class VwapTest {
    @TestCase
    public func vwap_basic() {
        let input = Csv<VwapData>().readFromFile("src/test/testdata/volume/vwap.csv")
        let inputs = duplicate(input, 3)
        let closings = map(inputs[0], { m => m.close })
        let volumes = map(inputs[1], { m => Float64(m.volume) })
        var expected = map(inputs[2], { m => m.Vwap })

        let vwap = Vwap()
        let actual = roundDigits(vwap.compute(closings, volumes), 2)
        expected = skip(expected, vwap.idlePeriod())

        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class VwapData {
    public var close: Float64 = 0.0
    public var volume: Int64 = 0
    public var Vwap: Float64 = 0.0
    public init() {}
}

