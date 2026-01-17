package indicator4cj.strategy.volatility

import std.core.*
import std.collection.*
import indicator4cj.helper.*
import indicator4cj.helper as h
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.volatility.*

// Bollinger Bands：收盘高于上轨卖，低于下轨买。
public class BollingerBandsStrategy <: Strategy {
    // 指标
    public let Indicator: BollingerBands

    public init() {
        this.Indicator = BollingerBands()
    }

    public func name(): String { return "Bollinger Bands Strategy" }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = duplicate(snapshotsAsClosings(snapshots), 2)
        let (uppers, _, lowers) = Indicator.compute(closings[0])
        closings[1] = skip(closings[1], Indicator.idlePeriod())

        let actions = operate3(uppers, lowers, closings[1], { up: Float64, low: Float64, close: Float64 =>
            if (close > up) { return Action.SELL }
            if (low > close) { return Action.BUY }
            return Action.HOLD
        })

        return shift(actions, Indicator.idlePeriod(), Action.HOLD)
    }

    public func report(c: Iterator<Snapshot>): Report {
        let snaps = duplicate(c, 3)
        let dates = snapshotsAsDates(snaps[0])
        let closings = duplicate(snapshotsAsClosings(snaps[1]), 2)

        var (uppers, middles, lowers) = Indicator.compute(closings[0])
        uppers = shift(uppers, Indicator.idlePeriod(), 0.0)
        middles = shift(middles, Indicator.idlePeriod(), 0.0)
        lowers = shift(lowers, Indicator.idlePeriod(), 0.0)

        let (actions, outcomesRaw) = computeWithOutcome(this, snaps[2])
        let annotations = actionsToAnnotations(actions)
        let outcomes = multiplyBy(outcomesRaw, 100.0)

        let report = Report(name(), dates)
        report.addChart()
        report.addColumn(NumericReportColumn("Close", closings[1]))
        report.addColumn(NumericReportColumn("Upper", uppers))
        report.addColumn(NumericReportColumn("Middle", middles))
        report.addColumn(NumericReportColumn("Lower", lowers))
        report.addColumn(AnnotationReportColumn(annotations))
        report.addColumn(NumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}



