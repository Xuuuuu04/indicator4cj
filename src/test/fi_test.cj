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
        let inputs = Duplicate(input, 3)
        let closes = Map(inputs[0], { m => m.close })
        let volumes = Map(inputs[1], { m => Float64(m.volume) })
        var expected = Map(inputs[2], { m => m.Fi })

        let fi = Fi()
        let actual = RoundDigits(fi.compute(closes, volumes), 2)
        expected = Skip(expected, fi.idlePeriod())

        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class FiRow {
    public var close: Float64 = 0.0
    public var volume: Int64 = 0
    public var Fi: Float64 = 0.0
    public init() {}
}

