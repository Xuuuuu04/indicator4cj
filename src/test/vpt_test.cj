package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class VptTest {
    @TestCase
    public func vpt_basic() {
        let input = ReadFromCsvFile<VptData>("src/test/testdata/volume/vpt.csv")
        let inputs = Duplicate(input, 3)
        let closings = Map(inputs[0], { m => m.Close })
        let volumes = Map(inputs[1], { m => Float64(m.Volume) })
        var expected = Map(inputs[2], { m => m.Vpt })

        let vpt = Vpt()
        let actual = RoundDigits(vpt.Compute(closings, volumes), 2)
        expected = Skip(expected, vpt.IdlePeriod())

        match (CheckEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class VptData {
    public var Close: Float64 = 0.0
    public var Volume: Int64 = 0
    public var Vpt: Float64 = 0.0
    public init() {}
}

