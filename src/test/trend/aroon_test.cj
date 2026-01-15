package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class AroonData {
    public var High: Float64 = 0.0
    public var Low: Float64 = 0.0
    public var Up: Float64 = 0.0
    public var Down: Float64 = 0.0

    public init() {}
    public init(High!: Float64, Low!: Float64, Up!: Float64, Down!: Float64) {
        this.High = High
        this.Low = Low
        this.Up = Up
        this.Down = Down
    }
}

@Test
public func test_aroon_basic() {
    let input = ReadFromCsvFile<AroonData>("src/test/testdata/trend/aroon.csv")
    let inputs = Duplicate(input, 4)
    let high = h.Map(inputs[0], { row: AroonData => row.High })
    let low = h.Map(inputs[1], { row: AroonData => row.Low })
    let expectedUp = h.Map(inputs[2], { row: AroonData => row.Up })
    let expectedDown = h.Map(inputs[3], { row: AroonData => row.Down })

    let aroon = Aroon()
    let expectedUpSkipped = h.Skip(expectedUp, aroon.Period - 1)
    let expectedDownSkipped = h.Skip(expectedDown, aroon.Period - 1)

    let (actualUp, actualDown) = aroon.compute(high, low)

    match (h.CheckFloatEquals(actualUp, expectedUpSkipped)) {
        case Some(err) => fail("Up mismatch: " + err.toString())
        case None => ()
    }
    match (h.CheckFloatEquals(actualDown, expectedDownSkipped)) {
        case Some(err) => fail("Down mismatch: " + err.toString())
        case None => ()
    }
}

@Test
public func test_aroon_compare_rust() {
    let testData = ArrayList<AroonData>()
    testData.add(AroonData(High: 82.15, Low: 81.29, Up: 0.0, Down: 0.0))
    testData.add(AroonData(High: 81.89, Low: 80.64, Up: 0.0, Down: 0.0))
    testData.add(AroonData(High: 83.03, Low: 81.31, Up: 0.0, Down: 0.0))
    testData.add(AroonData(High: 83.30, Low: 82.65, Up: 0.0, Down: 0.0))
    testData.add(AroonData(High: 83.85, Low: 83.07, Up: 0.0, Down: 0.0))
    testData.add(AroonData(High: 83.90, Low: 83.11, Up: 20.00, Down: 100.00))
    testData.add(AroonData(High: 83.33, Low: 82.49, Up: 20.00, Down: 80.00))
    testData.add(AroonData(High: 84.30, Low: 82.30, Up: 100.00, Down: 100.00))
    testData.add(AroonData(High: 84.84, Low: 84.15, Up: 80.00, Down: 100.00))
    testData.add(AroonData(High: 85.00, Low: 84.11, Up: 60.00, Down: 100.00))
    testData.add(AroonData(High: 85.90, Low: 84.03, Up: 40.00, Down: 100.00))
    testData.add(AroonData(High: 86.58, Low: 85.39, Up: 20.00, Down: 100.00))
    testData.add(AroonData(High: 86.98, Low: 85.76, Up: 60.00, Down: 100.00))
    testData.add(AroonData(High: 88.00, Low: 87.17, Up: 40.00, Down: 100.00))
    testData.add(AroonData(High: 87.87, Low: 87.01, Up: 20.00, Down: 80.00))

    let inputs = Duplicate(testData.iterator(), 4)
    let high = h.Map(inputs[0], { row: AroonData => row.High })
    let low = h.Map(inputs[1], { row: AroonData => row.Low })
    let expectedUp = h.Map(inputs[2], { row: AroonData => row.Up })
    let expectedDown = h.Map(inputs[3], { row: AroonData => row.Down })

    let aroon = Aroon()
    let expectedUpSkipped = h.Skip(expectedUp, aroon.Period - 1)
    let expectedDownSkipped = h.Skip(expectedDown, aroon.Period - 1)

    let (actualUp, actualDown) = aroon.compute(high, low)

    match (h.CheckFloatEquals(actualUp, expectedUpSkipped)) {
        case Some(err) => fail("Up mismatch (Rust): " + err.toString())
        case None => ()
    }
    match (h.CheckFloatEquals(actualDown, expectedDownSkipped)) {
        case Some(err) => fail("Down mismatch (Rust): " + err.toString())
        case None => ()
    }
}
