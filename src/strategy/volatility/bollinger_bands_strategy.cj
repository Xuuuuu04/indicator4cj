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
    public let Indicator: BollingerBands

    public init() { this.Indicator = BollingerBands() }

    public func Name(): String { return "Bollinger Bands Strategy" }

    public func Compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        let closings = Duplicate(SnapshotsAsClosings(snapshots), 2)
        let (uppers, _, lowers) = Indicator.Compute(closings[0])
        closings[1] = Skip(closings[1], Indicator.IdlePeriod())

        let actions = Operate3(uppers, lowers, closings[1], { up: Float64, low: Float64, close: Float64 =>
            if (close > up) { return Action.Sell }
            if (low > close) { return Action.Buy }
            return Action.Hold
        })

        return Shift(actions, Indicator.IdlePeriod(), Action.Hold)
    }

    public func Report(c: Iterator<Snapshot>): Report {
        let snaps = Duplicate(c, 3)
        let dates = SnapshotsAsDates(snaps[0])
        let closings = Duplicate(SnapshotsAsClosings(snaps[1]), 2)

        var (uppers, middles, lowers) = Indicator.Compute(closings[0])
        uppers = Shift(uppers, Indicator.IdlePeriod(), 0.0)
        middles = Shift(middles, Indicator.IdlePeriod(), 0.0)
        lowers = Shift(lowers, Indicator.IdlePeriod(), 0.0)

        let (actions, outcomesRaw) = ComputeWithOutcome(this, snaps[2])
        let annotations = ActionsToAnnotations(actions)
        let outcomes = MultiplyBy(outcomesRaw, 100.0)

        let report = NewReport(Name(), dates)
        report.AddChart()
        report.AddColumn(NewNumericReportColumn("Close", closings[1]))
        report.AddColumn(NewNumericReportColumn("Upper", uppers))
        report.AddColumn(NewNumericReportColumn("Middle", middles))
        report.AddColumn(NewNumericReportColumn("Lower", lowers))
        report.AddColumn(NewAnnotationReportColumn(annotations))
        report.AddColumn(NewNumericReportColumn("Outcome", outcomes), ArrayList<Int64>([1]))
        return report
    }
}

public func NewBollingerBandsStrategy(): BollingerBandsStrategy { return BollingerBandsStrategy() }


