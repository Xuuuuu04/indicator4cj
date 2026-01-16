package indicator4cj.test

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
            let actual = RoundDigit(fv(row.PV, row.Rate, row.Years), 2)
            @Expect(actual, row.FV)
        }
    }
}

public class FvRow {
    public var PV: Float64 = 0.0
    public var Rate: Float64 = 0.0
    public var Years: Int64 = 0
    public var FV: Float64 = 0.0
    public init() {}
}

