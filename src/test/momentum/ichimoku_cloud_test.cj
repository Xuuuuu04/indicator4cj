package indicator4cj.test.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.momentum.*

public class IchimokuRow {
    public let High: Float64
    public let Low: Float64
    public let Close: Float64
    public let Tenkan: Float64
    public let Kijun: Float64
    public let SenkouA: Float64
    public let SenkouB: Float64
    public let Chikou: Float64
    public init(High: Float64, Low: Float64, Close: Float64, Tenkan: Float64, Kijun: Float64, SenkouA: Float64, SenkouB: Float64, Chikou: Float64) {
        this.High = High
        this.Low = Low
        this.Close = Close
        this.Tenkan = Tenkan
        this.Kijun = Kijun
        this.SenkouA = SenkouA
        this.SenkouB = SenkouB
        this.Chikou = Chikou
    }
}

@Test
public func ichimoku_cloud_basic() {
    let input = ReadFromCsvFile<IchimokuRow>("src/test/testdata/momentum/ichimoku_cloud.csv")
    let inputs = Duplicate(input, 8)
    let highs = Map(inputs[0], { d: IchimokuRow => d.High })
    let lows = Map(inputs[1], { d: IchimokuRow => d.Low })
    let closes = Map(inputs[2], { d: IchimokuRow => d.Close })
    var expTenkan = Map(inputs[3], { d: IchimokuRow => d.Tenkan })
    var expKijun = Map(inputs[4], { d: IchimokuRow => d.Kijun })
    var expA = Map(inputs[5], { d: IchimokuRow => d.SenkouA })
    var expB = Map(inputs[6], { d: IchimokuRow => d.SenkouB })
    var expChikou = Map(inputs[7], { d: IchimokuRow => d.Chikou })

    let ichimoku = IchimokuCloud()
    var (actTenkan, actKijun, actA, actB, actChikou) = ichimoku.Compute(highs, lows, closes)
    actTenkan = RoundDigits(actTenkan, 2)
    actKijun = RoundDigits(actKijun, 2)
    actA = RoundDigits(actA, 2)
    actB = RoundDigits(actB, 2)
    actChikou = RoundDigits(actChikou, 2)

    let skip = ichimoku.IdlePeriod()
    expTenkan = Skip(expTenkan, skip)
    expKijun = Skip(expKijun, skip)
    expA = Skip(expA, skip)
    expB = Skip(expB, skip)
    expChikou = Skip(expChikou, skip)

    match (CheckEquals(actTenkan, expTenkan)) { case Some(err) => fail("Tenkan " + err) case None => () }
    match (CheckEquals(actKijun, expKijun)) { case Some(err) => fail("Kijun " + err) case None => () }
    match (CheckEquals(actA, expA)) { case Some(err) => fail("SenkouA " + err) case None => () }
    match (CheckEquals(actB, expB)) { case Some(err) => fail("SenkouB " + err) case None => () }
    match (CheckEquals(actChikou, expChikou)) { case Some(err) => fail("Chikou " + err) case None => () }
}

