package indicator4cj.backtest

import std.core.*
import std.collection.*
import indicator4cj.asset.*
import indicator4cj.strategy.*
import indicator4cj.helper.*

public const DefaultBacktestWorkers: Int64 = 1
public const DefaultLastDays: Int64 = 365

// Backtest 回测引擎，执行策略回测并生成报告
public class Backtest {
    private var _repository: Repository
    private var _report: Report
    private var _names: ArrayList<String> = ArrayList<String>()
    private var _strategies: ArrayList<Strategy> = ArrayList<Strategy>()
    private var _workers: Int64 = DefaultBacktestWorkers
    private var _lastDays: Int64 = DefaultLastDays

    // 构造函数
    public init(repository: Repository, report: Report) {
        this._repository = repository
        this._report = report
    }

    // run 执行回测
    public func run(): Unit {
        // 资产列表
        if (_names.isEmpty()) {
            _names = _repository.assets()
        }
        // 策略列表
        if (_strategies.isEmpty()) {
            _strategies.add(BuyAndHoldStrategy())
        }

        match (_report.begin(_names, _strategies)) {
            case Some(e) => throw e
            case None => ()
        }

        for (name in _names) {
            let snapsIter = _repository.get(name)
            let snapsList = ChanToSlice(snapsIter)

            match (_report.assetBegin(name, _strategies)) {
                case Some(e) => throw e
                case None => ()
            }

            for (st in _strategies) {
                let dup = Duplicate(snapsList.iterator(), 2)
                let (actions, outcomes) = ComputeWithOutcome(st, dup[0])
                match (_report.write(name, st, dup[1], actions, outcomes)) {
                    case Some(e) => throw e
                    case None => ()
                }
            }

            match (_report.assetEnd(name)) {
                case Some(e) => throw e
                case None => ()
            }
        }

        match (_report.end()) {
            case Some(e) => throw e
            case None => ()
        }
    }
}


