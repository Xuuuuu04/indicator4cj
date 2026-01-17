package indicator4cj.test

import std.unittest.*
import std.unittest.testmacro.*
import std.core.*
import std.collection.*
import std.convert.*
import indicator4cj.helper.*
import indicator4cj.valuation.*

@Test
class NpvTest {
    @TestCase
    public func npv_basic() {
        let input = Csv<NpvRow>().readFromFile("src/test/testdata/valuation/npv.csv")
        for (row in input) {
            let cashFlows = parseFlows(row.cashFlows)
            let actual = rounddigit(npv(row.rate, cashFlows), 2)
            @Expect(actual, row.npv)
        }
    }

    private func parseFlows(s: String): ArrayList<Float64> {
        let parts = s.split(" ")
        let res = ArrayList<Float64>()
        for (p in parts) { res.add(Float64.parse(p)) }
        return res
    }
}

public class NpvRow {
    public var rate: Float64 = 0.0
    public var cashFlows: String = ""
    public var npv: Float64 = 0.0
    public init() {}
}

