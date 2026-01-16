package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class IchimokuRow {
    public let high: Float64
    public let low: Float64
    public let close: Float64
    public let Tenkan: Float64
    public let Kijun: Float64
    public let SenkouA: Float64
    public let SenkouB: Float64
    public let Chikou: Float64
    public init(High: Float64, Low: Float64, Close: Float64, Tenkan: Float64, Kijun: Float64, SenkouA: Float64, SenkouB: Float64, Chikou: Float64) {
        this.high = High
        this.low = Low
        this.close = Close
        this.Tenkan = Tenkan
        this.Kijun = Kijun
        this.SenkouA = SenkouA
        this.SenkouB = SenkouB
        this.Chikou = Chikou
    }
}

@Test
public func ichimoku_cloud_basic() {
    let input = Csv<IchimokuRow>().readFromFile("src/test/testdata/momentum/ichimoku_cloud.csv")
    let inputs = duplicate(input, 8)
    let highs = map(inputs[0], { d: IchimokuRow => d.high })
    let lows = map(inputs[1], { d: IchimokuRow => d.low })
    let closes = map(inputs[2], { d: IchimokuRow => d.close })
    var expTenkan = map(inputs[3], { d: IchimokuRow => d.Tenkan })
    var expKijun = map(inputs[4], { d: IchimokuRow => d.Kijun })
    var expA = map(inputs[5], { d: IchimokuRow => d.SenkouA })
    var expB = map(inputs[6], { d: IchimokuRow => d.SenkouB })
    var expChikou = map(inputs[7], { d: IchimokuRow => d.Chikou })

    let ichimoku = IchimokuCloud()
    var (actTenkan, actKijun, actA, actB, actChikou) = ichimoku.compute(highs, lows, closes)
    actTenkan = roundDigits(actTenkan, 2)
    actKijun = roundDigits(actKijun, 2)
    actA = roundDigits(actA, 2)
    actB = roundDigits(actB, 2)
    actChikou = roundDigits(actChikou, 2)

    let skipCount = ichimoku.idlePeriod()
    expTenkan = skip(expTenkan, skipCount)
    expKijun = skip(expKijun, skipCount)
    expA = skip(expA, skipCount)
    expB = skip(expB, skipCount)
    expChikou = skip(expChikou, skipCount)

    match (checkEquals(actTenkan, expTenkan)) { case Some(err) => fail("Tenkan " + err) case None => () }
    match (checkEquals(actKijun, expKijun)) { case Some(err) => fail("Kijun " + err) case None => () }
    match (checkEquals(actA, expA)) { case Some(err) => fail("SenkouA " + err) case None => () }
    match (checkEquals(actB, expB)) { case Some(err) => fail("SenkouB " + err) case None => () }
    match (checkEquals(actChikou, expChikou)) { case Some(err) => fail("Chikou " + err) case None => () }
}

