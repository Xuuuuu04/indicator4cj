package indicator4cj.test.volume

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.volume.*

@Test
class VptTest {
    @TestCase
    public func vpt_basic() {
        let input = Csv<VptData>().readFromFile("src/test/testdata/volume/vpt.csv")
        let inputs = duplicate(input, 3)
        let closings = map(inputs[0], { m => m.close })
        let volumes = map(inputs[1], { m => Float64(m.volume) })
        var expected = map(inputs[2], { m => m.vpt })

        let vpt = Vpt()
        let actual = roundDigits(vpt.compute(closings, volumes), 2)
        expected = skip(expected, vpt.idlePeriod())

        match (checkEquals(actual, expected)) {
            case Some(err) => @Fail(err)
            case None => ()
        }
    }
}

public class VptData {
    public var close: Float64 = 0.0
    public var volume: Int64 = 0
    public var vpt: Float64 = 0.0
    public init() {}
}

