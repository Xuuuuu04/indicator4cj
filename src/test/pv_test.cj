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
            let actual = rounddigit(pv(row.fv, row.rate, row.years), 2)
            @Expect(actual, row.pv)
        }
    }
}

public class PvRow {
    public var fv: Float64 = 0.0
    public var rate: Float64 = 0.0
    public var years: Int64 = 0
    public var pv: Float64 = 0.0
    public init() {}
}

