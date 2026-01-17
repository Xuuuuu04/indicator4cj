package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class FiTest {
    @TestCase
    public func fi_basic() {
        let input = Csv<FiRow>().readFromFile("src/test/testdata/volume/fi.csv")
        let inputs = duplicate(input, 3)
        let closes = map(inputs[0], { m => m.close })
        let volumes = map(inputs[1], { m => Float64(m.volume) })
        var expected = map(inputs[2], { m => m.fi })

        let fi = Fi()
        let actual = roundDigits(fi.compute(closes, volumes), 2)
        expected = skip(expected, fi.idlePeriod())

        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class FiRow {
    public var close: Float64 = 0.0
    public var volume: Int64 = 0
    public var fi: Float64 = 0.0
    public init() {}
}

