package indicator4cj.backtest

import std.core.*
import std.collection.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.helper.*

public class DataStrategyResult {
    public let Asset: String
    public let StrategyInst: Strategy
    public let Outcome: Float64
    public let ActionVal: Action
    public let Transactions: ArrayList<Action>

    public init(asset: String, strategyInst: Strategy, outcome: Float64, action: Action, transactions: ArrayList<Action>) {
        this.Asset = asset
        this.StrategyInst = strategyInst
        this.Outcome = outcome
        this.ActionVal = action
        this.Transactions = transactions
    }
}

// 数据报告，供程序访问。
public class DataReport <: Report {
    public let Results = HashMap<String, ArrayList<DataStrategyResult>>()

    public func Begin(assetNames: ArrayList<String>, strategies: ArrayList<Strategy>): Option<Exception> {
        _ = strategies.size // 标记已使用以消除告警
        for (n in assetNames) { Results.add(n, ArrayList<DataStrategyResult>()) }
        return None
    }

    public func AssetBegin(name: String, strategies: ArrayList<Strategy>): Option<Exception> {
        _ = strategies.size // 标记已使用以消除告警
        if (!Results.contains(name)) {
            Results.add(name, ArrayList<DataStrategyResult>())
        }
        return None
    }

    public func Write(assetName: String, currentStrategy: Strategy, snapshots: Iterator<Snapshot>, actions: Iterator<Action>, outcomes: Iterator<Float64>): Option<Exception> {
        // 耗尽 snapshots，避免资源泄漏。
        Drain(snapshots)

        let actionsDup = Duplicate(actions, 2)
        let lastOutcomeIter = Last(outcomes, 1)
        let lastActionIter = Last(actionsDup[0], 1)
        let transactionsList = ChanToSlice(actionsDup[1])

        match (lastOutcomeIter.next()) {
            case Some(outcome) =>
                match (lastActionIter.next()) {
                    case Some(action) =>
                        let res = DataStrategyResult(assetName, currentStrategy, outcome, action, transactionsList)
                        Results[assetName].add(res)
                    case None => ()
                }
            case None => ()
        }
        return None
    }

    public func AssetEnd(name: String): Option<Exception> { _ = name.isEmpty(); return None }

    public func End(): Option<Exception> { return None }
}

public func NewDataReport(): DataReport { return DataReport() }

