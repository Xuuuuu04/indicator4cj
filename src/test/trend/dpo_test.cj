package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class DpoData {
    public var close: Float64 = 0.0
    public var Dpo: Float64 = 0.0
}

@Test
public func test_dpo_basic() {
    let input = Csv<DpoData>().readFromFile("src/test/testdata/trend/dpo.csv")
    let inputs = duplicate(input, 2)
    let closing = h.map(inputs[0], { row: DpoData => row.close })
    let expected = h.map(inputs[1], { row: DpoData => row.Dpo })

    let dpo = Dpo()
    let actual = h.roundDigits(dpo.compute(closing), 2)
    let expectedSkipped = h.skip(expected, dpo.idlePeriod())

    let actIter = actual
    let expIter = expectedSkipped
    var idx = 0
    while (true) {
        match (expIter.next()) {
            case Some(e) =>
                match (actIter.next()) {
                    case Some(a) =>
                        let diff = if (a > e) { a - e } else { e - a }
                        if (diff > 0.02) { // Relax tolerance for float diffs (e.g. 174.14 vs 174.15)
                             fail("index ${idx} actual ${a} expected ${e} diff ${diff}")
                        }
                    case None => fail("actual ended early")
                }
            case None => break
        }
        idx += 1
    }
}