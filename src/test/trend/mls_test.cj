package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class MlsData {
    public var X: Float64 = 0.0
    public var Y: Float64 = 0.0
    public var M: Float64 = 0.0
    public var B: Float64 = 0.0
}

@Test
public func test_mls_basic() {
    let input = Csv<MlsData>().readFromFile("src/test/testdata/trend/mls.csv")
    let inputs = Duplicate(input, 4)
    let x = h.Map(inputs[0], { d: MlsData => d.X })
    let y = h.Map(inputs[1], { d: MlsData => d.Y })
    let expectedM = h.Map(inputs[2], { d: MlsData => d.M })
    let expectedB = h.Map(inputs[3], { d: MlsData => d.B })

    let mls = Mls(5)
    let (actualMraw, actualBRaw) = mls.compute(x, y)
    
    let actualM = h.RoundDigits(actualMraw, 2)
    let actualB = h.RoundDigits(actualBRaw, 2)

    let expMSkipped = h.Skip(expectedM, mls.idlePeriod())
    let expBSkipped = h.Skip(expectedB, mls.idlePeriod())

    match (h.CheckFloatEquals(actualM, expMSkipped)) {
        case Some(err) => fail("M: " + err)
        case None => ()
    }
    match (h.CheckFloatEquals(actualB, expBSkipped)) {
        case Some(err) => fail("B: " + err)
        case None => ()
    }
}
