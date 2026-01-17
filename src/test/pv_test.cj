package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import indicator4cj.helper.*
import indicator4cj.valuation.*

@Test
class PvTest {
    @TestCase
    public func pv_basic() {
        let input = Csv<PvRow>().readFromFile("src/test/testdata/valuation/pv.csv")
        for (row in input) {
            let actual = rounddigit(pv(row.FV, row.Rate, row.Years), 2)
            @Expect(actual, row.PV)
        }
    }
}

public class PvRow {
    public var FV: Float64 = 0.0
    public var Rate: Float64 = 0.0
    public var Years: Int64 = 0
    public var PV: Float64 = 0.0
    public init() {}
}

