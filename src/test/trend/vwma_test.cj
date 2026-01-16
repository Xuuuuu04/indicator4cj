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
    let inputs = duplicate(input, 3)
    let closing = h.map(inputs[0], { d: VwmaData => d.close })
    let volume = h.map(inputs[1], { d: VwmaData => Float64(d.volume) })
    let expected = h.map(inputs[2], { d: VwmaData => d.Vwma })

    let vwma = Vwma()
    let actual = h.roundDigits(vwma.compute(closing, volume), 2)
    let expectedSkipped = h.skip(expected, vwma.idlePeriod())

    match (h.checkFloatEquals(actual, expectedSkipped)) {
        case Some(err) => fail(err)
        case None => ()
    }
}
