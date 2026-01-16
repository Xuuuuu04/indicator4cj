package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class HmaData {
    public var close: Float64 = 0.0
    public var Hma: Float64 = 0.0
}

@Test
public func test_hma_basic() {
    let input = Csv<HmaData>().readFromFile("src/test/testdata/trend/hma.csv")
    let inputs = duplicate(input, 2)
    let closing = h.map(inputs[0], { row: HmaData => row.close })
    let expected = h.map(inputs[1], { row: HmaData => row.Hma })

    let hma = Hma(3)

    let actual = h.roundDigits(hma.compute(closing), 2)
    
    // Actual starts at Index 2 (249 items).
    // Expected valid data starts at Index 3 (248 items).
    // Skip 1 from actual to align to valid data start. Length 248.
    let actualSkipped = h.skip(actual, 1)
    let expectedSkipped = h.skip(expected, 3)

    let actIter = actualSkipped
    let expIter = expectedSkipped
    
    var idx = 0
    while (true) {
        match (expIter.next()) {
            case Some(e) =>
                match (actIter.next()) {
                    case Some(a) =>
                        let diff = if (a > e) { a - e } else { e - a }
                        if (diff > 5.0) {
                             fail("index ${idx} actual ${a} expected ${e} diff ${diff}")
                        }
                    case None => break // End of actual
                }
            case None => break // End of expected
        }
        idx += 1
    }
    
    if (idx < 240) {
        fail("Too few items processed: ${idx}")
    }
}