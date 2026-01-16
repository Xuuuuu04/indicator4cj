package indicator4cj.test.trend

import std.core.*
import std.collection.*
import std.unittest.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.trend.*

class EnvelopeData {
    public var close: Float64 = 0.0
    public var upper: Float64 = 0.0
    public var middle: Float64 = 0.0
    public var lower: Float64 = 0.0
}

@Test
public func test_envelope_sma_basic() {
    let input = Csv<EnvelopeData>().readFromFile("src/test/testdata/trend/envelope_sma.csv")
    let inputs = duplicate(input, 4)
    let closing = h.map(inputs[0], { d: EnvelopeData => d.close })
    let expectedUpper = h.map(inputs[1], { d: EnvelopeData => d.upper })
    let expectedMiddle = h.map(inputs[2], { d: EnvelopeData => d.middle })
    let expectedLower = h.map(inputs[3], { d: EnvelopeData => d.lower })

    let envelope = Envelope()
    let (actualUpperRaw, actualMiddleRaw, actualLowerRaw) = envelope.compute(closing)

    let actualUpper = h.roundDigits(actualUpperRaw, 2)
    let actualMiddle = h.roundDigits(actualMiddleRaw, 2)
    let actualLower = h.roundDigits(actualLowerRaw, 2)

    let expUpperSkipped = h.skip(expectedUpper, envelope.idlePeriod())
    let expMiddleSkipped = h.skip(expectedMiddle, envelope.idlePeriod())
    let expLowerSkipped = h.skip(expectedLower, envelope.idlePeriod())

    match (h.checkFloatEquals(actualUpper, expUpperSkipped)) {
        case Some(err) => fail("Upper: " + err)
        case None => ()
    }
    match (h.checkFloatEquals(actualMiddle, expMiddleSkipped)) {
        case Some(err) => fail("Middle: " + err)
        case None => ()
    }
    match (h.checkFloatEquals(actualLower, expLowerSkipped)) {
        case Some(err) => fail("Lower: " + err)
        case None => ()
    }
}

@Test
public func test_envelope_ema_basic() {
    let input = Csv<EnvelopeData>().readFromFile("src/test/testdata/trend/envelope_ema.csv")
    let inputs = duplicate(input, 4)
    let closing = h.map(inputs[0], { d: EnvelopeData => d.close })
    let expectedUpper = h.map(inputs[1], { d: EnvelopeData => d.upper })
    let expectedMiddle = h.map(inputs[2], { d: EnvelopeData => d.middle })
    let expectedLower = h.map(inputs[3], { d: EnvelopeData => d.lower })

    let envelope = Envelope(Ema(), 20.0)
    let (actualUpperRaw, actualMiddleRaw, actualLowerRaw) = envelope.compute(closing)

    let actualUpper = h.roundDigits(actualUpperRaw, 2)
    let actualMiddle = h.roundDigits(actualMiddleRaw, 2)
    let actualLower = h.roundDigits(actualLowerRaw, 2)

    let expUpperSkipped = h.skip(expectedUpper, envelope.idlePeriod())
    let expMiddleSkipped = h.skip(expectedMiddle, envelope.idlePeriod())
    let expLowerSkipped = h.skip(expectedLower, envelope.idlePeriod())

    match (h.checkFloatEquals(actualUpper, expUpperSkipped)) {
        case Some(err) => fail("Upper: " + err)
        case None => ()
    }
    match (h.checkFloatEquals(actualMiddle, expMiddleSkipped)) {
        case Some(err) => fail("Middle: " + err)
        case None => ()
    }
    match (h.checkFloatEquals(actualLower, expLowerSkipped)) {
        case Some(err) => fail("Lower: " + err)
        case None => ()
    }
}
