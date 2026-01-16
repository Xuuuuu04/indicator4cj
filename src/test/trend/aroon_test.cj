package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class AroonData {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var Up: Float64 = 0.0
    public var Down: Float64 = 0.0

    public init() {}
    public init(High!: Float64, Low!: Float64, Up!: Float64, Down!: Float64) {
        this.high = High
        this.low = Low
        this.Up = Up
        this.Down = Down
    }
}

@Test
public func test_aroon_basic() {
    let input = Csv<AroonData>().readFromFile("src/test/testdata/trend/aroon.csv")
    let inputs = duplicate(input, 4)
    let high = h.map(inputs[0], { row: AroonData => row.high })
    let low = h.map(inputs[1], { row: AroonData => row.low })
    let expectedUp = h.map(inputs[2], { row: AroonData => row.Up })
    let expectedDown = h.map(inputs[3], { row: AroonData => row.Down })

    let aroon = Aroon()
    let expectedUpSkipped = h.skip(expectedUp, aroon.period - 1)
    let expectedDownSkipped = h.skip(expectedDown, aroon.period - 1)

    let (actualUp, actualDown) = aroon.compute(high, low)

    match (h.checkFloatEquals(actualUp, expectedUpSkipped)) {
        case Some(err) => fail("Up mismatch: " + err.toString())
        case None => ()
    }
    match (h.checkFloatEquals(actualDown, expectedDownSkipped)) {
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

    let inputs = duplicate(testData.iterator(), 4)
    let high = h.map(inputs[0], { row: AroonData => row.high })
    let low = h.map(inputs[1], { row: AroonData => row.low })
    let expectedUp = h.map(inputs[2], { row: AroonData => row.Up })
    let expectedDown = h.map(inputs[3], { row: AroonData => row.Down })

    let aroon = Aroon()
    let expectedUpSkipped = h.skip(expectedUp, aroon.period - 1)
    let expectedDownSkipped = h.skip(expectedDown, aroon.period - 1)

    let (actualUp, actualDown) = aroon.compute(high, low)

    match (h.checkFloatEquals(actualUp, expectedUpSkipped)) {
        case Some(err) => fail("Up mismatch (Rust): " + err.toString())
        case None => ()
    }
    match (h.checkFloatEquals(actualDown, expectedDownSkipped)) {
        case Some(err) => fail("Down mismatch (Rust): " + err.toString())
        case None => ()
    }
}
