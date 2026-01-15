package indicator4cj.backtest

import indicator4cj.asset.*
import indicator4cj.strategy.*
import std.collection.*

// Report 回测报告接口，定义回测报告生成的方法
public interface Report {
    // begin 开始生成报告
    func begin(assetNames: ArrayList<String>, strategies: ArrayList<Strategy>): Unit

    // assetBegin 开始单个资产的报告
    func assetBegin(name: String, strategies: ArrayList<Strategy>): Unit

    // write 写入策略执行结果
    func write(assetName: String, currentStrategy: Strategy, snapshots: Iterator<Snapshot>, actions: Iterator<Action>, outcomes: Iterator<Float64>): Unit

    // assetEnd 结束单个资产的报告
    func assetEnd(name: String): Unit

    // end 结束报告生成
    func end(): Unit
}


