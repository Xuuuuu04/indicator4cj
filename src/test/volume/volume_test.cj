package indicator4cj.test.volume

import std.core.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.volume.*

private class AdRow {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var volume: Float64 = 0.0
    public var ad: Float64 = 0.0
    public init() {}
}

@Test
public func ad_basic() {
    let input = Csv<AdRow>().readFromFile("src/test/testdata/volume/ad.csv")
    let inputs = duplicate(input, 5)
    let highs = h.map(inputs[0], { r: AdRow => r.high })
    let lows = h.map(inputs[1], { r: AdRow => r.low })
    let closes = h.map(inputs[2], { r: AdRow => r.close })
    let volumes = h.map(inputs[3], { r: AdRow => r.volume })
    let ad = Ad()
    let expected = h.roundDigits(h.skip(h.map(inputs[4], { r: AdRow => r.ad }), ad.idlePeriod()), 2)
    let actual = h.roundDigits(ad.compute(highs, lows, closes, volumes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}

private class CmfRow {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var volume: Float64 = 0.0
    public var cmf: Float64 = 0.0
    public init() {}
}

@Test
public func cmf_basic() {
    let input = Csv<CmfRow>().readFromFile("src/test/testdata/volume/cmf.csv")
    let inputs = duplicate(input, 5)
    let highs = h.map(inputs[0], { r: CmfRow => r.high })
    let lows = h.map(inputs[1], { r: CmfRow => r.low })
    let closes = h.map(inputs[2], { r: CmfRow => r.close })
    let volumes = h.map(inputs[3], { r: CmfRow => r.volume })
    let cmf = Cmf()
    let expected = h.roundDigits(h.skip(h.map(inputs[4], { r: CmfRow => r.cmf }), cmf.idlePeriod()), 2)
    let actual = h.roundDigits(cmf.compute(highs, lows, closes, volumes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}

private class EmvRow {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var volume: Float64 = 0.0
    public var emv: Float64 = 0.0
    public init() {}
}

@Test
public func emv_basic() {
    let input = Csv<EmvRow>().readFromFile("src/test/testdata/volume/emv.csv")
    let inputs = duplicate(input, 4)
    let highs = h.map(inputs[0], { r: EmvRow => r.high })
    let lows = h.map(inputs[1], { r: EmvRow => r.low })
    let volumes = h.map(inputs[2], { r: EmvRow => r.volume })
    let emv = Emv()
    let expected = h.roundDigits(h.skip(h.map(inputs[3], { r: EmvRow => r.emv }), emv.idlePeriod()), 2)
    let actual = h.roundDigits(emv.compute(highs, lows, volumes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}

private class FiRow {
    public var close: Float64 = 0.0
    public var volume: Float64 = 0.0
    public var fi: Float64 = 0.0
    public init() {}
}

@Test
public func fi_basic() {
    let input = Csv<FiRow>().readFromFile("src/test/testdata/volume/fi.csv")
    let inputs = duplicate(input, 3)
    let closes = h.map(inputs[0], { r: FiRow => r.close })
    let volumes = h.map(inputs[1], { r: FiRow => r.volume })
    let fi = Fi()
    let expected = h.roundDigits(h.skip(h.map(inputs[2], { r: FiRow => r.fi }), fi.idlePeriod()), 2)
    let actual = h.roundDigits(fi.compute(closes, volumes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}

private class MfiRow {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var volume: Float64 = 0.0
    public var mfi: Float64 = 0.0
    public init() {}
}

@Test
public func mfi_basic() {
    let input = Csv<MfiRow>().readFromFile("src/test/testdata/volume/mfi.csv")
    let inputs = duplicate(input, 5)
    let highs = h.map(inputs[0], { r: MfiRow => r.high })
    let lows = h.map(inputs[1], { r: MfiRow => r.low })
    let closes = h.map(inputs[2], { r: MfiRow => r.close })
    let volumes = h.map(inputs[3], { r: MfiRow => r.volume })
    let mfi = Mfi()
    let expected = h.roundDigits(h.skip(h.map(inputs[4], { r: MfiRow => r.mfi }), mfi.idlePeriod()), 2)
    let actual = h.roundDigits(mfi.compute(highs, lows, closes, volumes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}

private class MfmRow {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var mfm: Float64 = 0.0
    public init() {}
}

@Test
public func mfm_basic() {
    let input = Csv<MfmRow>().readFromFile("src/test/testdata/volume/mfm.csv")
    let inputs = duplicate(input, 4)
    let highs = h.map(inputs[0], { r: MfmRow => r.high })
    let lows = h.map(inputs[1], { r: MfmRow => r.low })
    let closes = h.map(inputs[2], { r: MfmRow => r.close })
    let mfm = Mfm()
    let expected = h.roundDigits(h.skip(h.map(inputs[3], { r: MfmRow => r.mfm }), mfm.idlePeriod()), 2)
    let actual = h.roundDigits(mfm.compute(highs, lows, closes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}

private class MfvRow {
    public var high: Float64 = 0.0
    public var low: Float64 = 0.0
    public var close: Float64 = 0.0
    public var volume: Float64 = 0.0
    public var mfv: Float64 = 0.0
    public init() {}
}

@Test
public func mfv_basic() {
    let input = Csv<MfvRow>().readFromFile("src/test/testdata/volume/mfv.csv")
    let inputs = duplicate(input, 5)
    let highs = h.map(inputs[0], { r: MfvRow => r.high })
    let lows = h.map(inputs[1], { r: MfvRow => r.low })
    let closes = h.map(inputs[2], { r: MfvRow => r.close })
    let volumes = h.map(inputs[3], { r: MfvRow => r.volume })
    let mfv = Mfv()
    let expected = h.roundDigits(h.skip(h.map(inputs[4], { r: MfvRow => r.mfv }), mfv.idlePeriod()), 2)
    let actual = h.roundDigits(mfv.compute(highs, lows, closes, volumes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}

private class NviRow {
    public var close: Float64 = 0.0
    public var volume: Float64 = 0.0
    public var nvi: Float64 = 0.0
    public init() {}
}

@Test
public func nvi_basic() {
    let input = Csv<NviRow>().readFromFile("src/test/testdata/volume/nvi.csv")
    let inputs = duplicate(input, 3)
    let closes = h.map(inputs[0], { r: NviRow => r.close })
    let volumes = h.map(inputs[1], { r: NviRow => r.volume })
    let nvi = Nvi()
    let expected = h.roundDigits(h.skip(h.map(inputs[2], { r: NviRow => r.nvi }), nvi.idlePeriod()), 2)
    let actual = h.roundDigits(nvi.compute(closes, volumes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}

private class ObvRow {
    public var close: Float64 = 0.0
    public var volume: Float64 = 0.0
    public var obv: Float64 = 0.0
    public init() {}
}

@Test
public func obv_basic() {
    let input = Csv<ObvRow>().readFromFile("src/test/testdata/volume/obv.csv")
    let inputs = duplicate(input, 3)
    let closes = h.map(inputs[0], { r: ObvRow => r.close })
    let volumes = h.map(inputs[1], { r: ObvRow => r.volume })
    let obv = Obv()
    let expected = h.roundDigits(h.skip(h.map(inputs[2], { r: ObvRow => r.obv }), obv.idlePeriod()), 2)
    let actual = h.roundDigits(obv.compute(closes, volumes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}

private class VptRow {
    public var close: Float64 = 0.0
    public var volume: Float64 = 0.0
    public var vpt: Float64 = 0.0
    public init() {}
}

@Test
public func vpt_basic() {
    let input = Csv<VptRow>().readFromFile("src/test/testdata/volume/vpt.csv")
    let inputs = duplicate(input, 3)
    let closes = h.map(inputs[0], { r: VptRow => r.close })
    let volumes = h.map(inputs[1], { r: VptRow => r.volume })
    let vpt = Vpt()
    let expected = h.roundDigits(h.skip(h.map(inputs[2], { r: VptRow => r.vpt }), vpt.idlePeriod()), 2)
    let actual = h.roundDigits(vpt.compute(closes, volumes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}

private class VwapRow {
    public var close: Float64 = 0.0
    public var volume: Float64 = 0.0
    public var vwap: Float64 = 0.0
    public init() {}
}

@Test
public func vwap_basic() {
    let input = Csv<VwapRow>().readFromFile("src/test/testdata/volume/vwap.csv")
    let inputs = duplicate(input, 3)
    let closes = h.map(inputs[0], { r: VwapRow => r.close })
    let volumes = h.map(inputs[1], { r: VwapRow => r.volume })
    let vwap = Vwap()
    let expected = h.roundDigits(h.skip(h.map(inputs[2], { r: VwapRow => r.vwap }), vwap.idlePeriod()), 2)
    let actual = h.roundDigits(vwap.compute(closes, volumes), 2)
    match (checkEquals(actual, expected)) { case Some(err) => fail(err) case None => () }
}
