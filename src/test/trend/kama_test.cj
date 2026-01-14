package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class KamaData {
    public var Close: Float64 = 0.0
    public var Kama: Float64 = 0.0
}

@Test
public func test_kama_basic() {
    let input = ReadFromCsvFile<KamaData>("src/test/testdata/trend/kama.csv")
    let inputs = Duplicate(input, 2)
    let closing = h.Map(inputs[0], { row: KamaData => row.Close })
    let expected = h.Map(inputs[1], { row: KamaData => row.Kama })

    let kama = Kama()
    let actual = h.RoundDigits(kama.compute(closing), 2)
    
    // Actual stream: Seed (p9), K(p10), K(p11)...
    // Seed = 109.24. K(p10) = 109.24. K(p11) = 109.22.
    // Expected stream (CSV): starts with 0s. 
    // Row 12 (Index 10) is 109.24. Row 13 (Index 11) is 109.22.
    // So Expected (valid) starts with 109.24, 109.22...
    // To match, we skip 10 from expected (0..9 are zero).
    // And skip 1 from actual (Seed).
    
    let actualSkipped = h.Skip(actual, 1)
    let expectedSkipped = h.Skip(expected, 10)

    let actIter = actualSkipped
    let expIter = expectedSkipped
    var idx = 0
    while (true) {
        match (expIter.next()) {
            case Some(e) =>
                match (actIter.next()) {
                    case Some(a) =>
                        let diff = if (a > e) { a - e } else { e - a }
                        if (diff > 0.00001) {
                             fail("index ${idx} actual ${a} expected ${e} diff ${diff}")
                        }
                    case None => fail("actual ended early")
                }
            case None => break
        }
        idx += 1
    }
}
