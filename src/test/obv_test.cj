package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class ObvTest {
    @TestCase
    public func obv_basic() {
        let input = Csv<ObvData>().readFromFile("src/test/testdata/volume/obv.csv")
        let inputs = Duplicate(input, 3)
        let closings = Map(inputs[0], { m => m.close })
        let volumes = Map(inputs[1], { m => Float64(m.volume) })
        var expected = Map(inputs[2], { m => m.Obv })

        let obv = Obv()
        let actual = RoundDigits(obv.compute(closings, volumes), 2)
        expected = Skip(expected, obv.idlePeriod())

        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class ObvData {
    public var close: Float64 = 0.0
    public var volume: Int64 = 0
    public var Obv: Float64 = 0.0
    public init() {}
}

