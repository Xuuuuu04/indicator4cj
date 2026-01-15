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
    private var repository: Repository
    private var report: Report
    public var names: ArrayList<String> = ArrayList<String>()
    public var strategies: ArrayList<Strategy> = ArrayList<Strategy>()
    private var workers: Int64 = DefaultBacktestWorkers
    private var lastDays: Int64 = DefaultLastDays

    // 构造函数
    public init(repository: Repository, report: Report) {
        this.repository = repository
        this.report = report
    }

    // run 执行回测
    public func run(): Unit {
        // 资产列表
        if (names.isEmpty()) {
            names = repository.assets()
        }
        // 策略列表
        if (strategies.isEmpty()) {
            strategies.add(BuyAndHoldStrategy())
        }

        try {
            report.begin(names, strategies)
        } catch (e: Exception) {
            throw e
        }

        for (name in names) {
            let snapsIter = repository.get(name)
            let snapsList = ChanToSlice(snapsIter)

            try {
                report.assetBegin(name, strategies)
            } catch (e: Exception) {
                throw e
            }

            for (st in strategies) {
                let dup = Duplicate(snapsList.iterator(), 2)
                let (actions, outcomes) = computeWithOutcome(st, dup[0])
                try {
                    report.write(name, st, dup[1], actions, outcomes)
                } catch (e: Exception) {
                    throw e
                }
            }

            try {
                report.assetEnd(name)
            } catch (e: Exception) {
                throw e
            }
        }

        try {
            report.end()
        } catch (e: Exception) {
            throw e
        }
    }
}


