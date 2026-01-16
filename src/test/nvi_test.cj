package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class NviTest {
    @TestCase
    public func nvi_basic() {
        let input = Csv<NviData>().readFromFile("src/test/testdata/volume/nvi.csv")
        let inputs = duplicate(input, 3)
        let closings = map(inputs[0], { m => m.close })
        let volumes = map(inputs[1], { m => Float64(m.volume) })
        var expected = map(inputs[2], { m => m.Nvi })

        let nvi = Nvi()
        let actual = roundDigits(nvi.compute(closings, volumes), 2)
        expected = skip(expected, nvi.idlePeriod())

        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class NviData {
    public var close: Float64 = 0.0
    public var volume: Int64 = 0
    public var Nvi: Float64 = 0.0
    public init() {}
}

