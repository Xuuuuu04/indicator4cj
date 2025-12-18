package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class WmaData {
    public var Close: Float64 = 0.0
    public var Wma3: Float64 = 0.0
    public var Wma5: Float64 = 0.0
}

@Test
public func test_wma_simple() {
    // 1, 2, 3, 4, 5
    // Period 3. Go implementation uses "Inverted" weights (Oldest gets max weight).
    // 1, 2, 3 -> (3*1 + 2*2 + 1*3) / 6 = 10/6 = 1.666...
    
    let input = ArrayList<Float64>([1.0, 2.0, 3.0, 4.0, 5.0])
    let expected = ArrayList<Float64>([10.0/6.0, 16.0/6.0, 22.0/6.0])
    
    let wma = NewWmaWith(3)
    let actual = wma.Compute(input.iterator())
    
    match (h.CheckFloatEquals(actual, expected.iterator())) {
        case Some(err) => fail(err)
        case None => ()
    }
}

@Test
public func test_wma_basic() {
    let input = ReadFromCsvFile<WmaData>("src/test/testdata/trend/wma.csv")
    let inputs = Duplicate(input, 3)
    let closing = Duplicate(h.Map(inputs[0], { row: WmaData => row.Close }), 2)
    let expectedWma3 = h.Map(inputs[1], { row: WmaData => row.Wma3 })
    let expectedWma5 = h.Map(inputs[2], { row: WmaData => row.Wma5 })

    let wma3 = NewWmaWith(3)
    let wma5 = NewWmaWith(5)

    let actualWma3 = h.RoundDigits(wma3.Compute(closing[0]), 3)
    let actualWma5 = h.RoundDigits(wma5.Compute(closing[1]), 3)

    let expWma3Skipped = h.Skip(expectedWma3, wma3.IdlePeriod())
    let expWma5Skipped = h.Skip(expectedWma5, wma5.IdlePeriod())

    match (h.CheckFloatEquals(actualWma3, expWma3Skipped)) {
        case Some(err) => fail("WMA3 mismatch: " + err.toString())
        case None => ()
    }
    match (h.CheckFloatEquals(actualWma5, expWma5Skipped)) {
        case Some(err) => fail("WMA5 mismatch: " + err.toString())
        case None => ()
    }
}
