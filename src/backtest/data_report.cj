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

// DataReport 数据报告实现，将回测结果存储在内存中供程序访问
public class DataReport <: Report {
    public var _results = HashMap<String, ArrayList<DataStrategyResult>>()

    public func DataReport() {}

    public func begin(assetNames: ArrayList<String>, strategies: ArrayList<Strategy>): Unit {
        _ = strategies.size // 标记已使用以消除告警
        for (n in assetNames) { _results.add(n, ArrayList<DataStrategyResult>()) }
    }

    public func assetBegin(name: String, strategies: ArrayList<Strategy>): Unit {
        _ = strategies.size // 标记已使用以消除告警
        if (!_results.contains(name)) {
            _results.add(name, ArrayList<DataStrategyResult>())
        }
    }

    public func write(assetName: String, currentStrategy: Strategy, snapshots: Iterator<Snapshot>, actions: Iterator<Action>, outcomes: Iterator<Float64>): Unit {
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
                        _results[assetName].add(res)
                    case None => ()
                }
            case None => ()
        }
    }

    public func assetEnd(name: String): Unit { _ = name.isEmpty() }

    public func end(): Unit {}
}

