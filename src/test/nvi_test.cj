package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class NviTest {
    @TestCase
    public func nvi_basic() {
        let input = ReadFromCsvFile<NviData>("src/test/testdata/volume/nvi.csv")
        let inputs = Duplicate(input, 3)
        let closings = Map(inputs[0], { m => m.Close })
        let volumes = Map(inputs[1], { m => Float64(m.Volume) })
        var expected = Map(inputs[2], { m => m.Nvi })

        let nvi = Nvi()
        let actual = RoundDigits(nvi.compute(closings, volumes), 2)
        expected = Skip(expected, nvi.idlePeriod())

        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class NviData {
    public var Close: Float64 = 0.0
    public var Volume: Int64 = 0
    public var Nvi: Float64 = 0.0
    public init() {}
}

