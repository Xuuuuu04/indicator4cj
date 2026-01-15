package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class VwmaData {
    public var close: Float64 = 0.0
    public var volume: Int64 = 0
    public var Vwma: Float64 = 0.0
}

@Test
public func test_vwma_basic() {
    let input = Csv<VwmaData>().readFromFile("src/test/testdata/trend/vwma.csv")
    let inputs = Duplicate(input, 3)
    let closing = h.Map(inputs[0], { d: VwmaData => d.close })
    let volume = h.Map(inputs[1], { d: VwmaData => Float64(d.volume) })
    let expected = h.Map(inputs[2], { d: VwmaData => d.Vwma })

    let vwma = Vwma()
    let actual = h.RoundDigits(vwma.compute(closing, volume), 2)
    let expectedSkipped = h.Skip(expected, vwma.idlePeriod())

    match (h.CheckFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
