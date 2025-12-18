package indicator4cj.backtest

import std.core.*
import std.collection.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.helper.*

public const DefaultBacktestWorkers: Int64 = 1
public const DefaultLastDays: Int64 = 365

public class Backtest {
    private let repository: Repository
    private let report: Report
    public var Names: ArrayList<String>
    public var Strategies: ArrayList<Strategy>
    public var Workers: Int64
    public var LastDays: Int64

    public init(repository: Repository, report: Report) {
        this.repository = repository
        this.report = report
        this.Names = ArrayList<String>()
        this.Strategies = ArrayList<Strategy>()
        this.Workers = DefaultBacktestWorkers
        this.LastDays = DefaultLastDays
    }

    public func Run(): Option<Exception> {
        // 资产列表
        if (Names.isEmpty()) {
            let (assets, err) = repository.Assets()
            match (err) { case Some(e) => return Some(e) case None => () }
            Names = assets
        }
        // 策略列表
        if (Strategies.isEmpty()) {
            let arr = ArrayList<Strategy>()
            arr.add(NewBuyAndHoldStrategy())
            Strategies = arr
        }

        match (report.Begin(Names, Strategies)) {
            case Some(e) => return Some(e)
            case None => ()
        }

        for (name in Names) {
            let (snapsIter, err) = repository.Get(name)
            match (err) { case Some(e) => return Some(e) case None => () }

            let snapsList = ChanToSlice(snapsIter)

            match (report.AssetBegin(name, Strategies)) {
                case Some(e) => return Some(e)
                case None => ()
            }

            for (st in Strategies) {
                let dup = Duplicate(snapsList.iterator(), 2)
                let (actions, outcomes) = ComputeWithOutcome(st, dup[0])
                match (report.Write(name, st, dup[1], actions, outcomes)) {
                    case Some(e) => return Some(e)
                    case None => ()
                }
            }

            match (report.AssetEnd(name)) {
                case Some(e) => return Some(e)
                case None => ()
            }
        }

        return report.End()
    }
}

public func NewBacktest(repository: Repository, report: Report): Backtest {
    return Backtest(repository, report)
}


