package indicator4cj.test.valuation

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.valuation.*

@Test
class FvTest {
    @TestCase
    public func fv_basic() {
        let input = Csv<FvRow>().readFromFile("src/test/testdata/valuation/fv.csv")
        for (row in input) {
            let actual = rounddigit(fv(row.pv, row.rate, row.years), 2)
            expectEqual("actual", "row.fv", actual, row.fv)
        }
    }
}

public class FvRow {
    public var pv: Float64 = 0.0
    public var rate: Float64 = 0.0
    public var years: Int64 = 0
    public var fv: Float64 = 0.0
    public init() {}
}
