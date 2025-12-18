package indicator4cj.backtest

import indicator4cj.asset.*
import indicator4cj.strategy.*
import std.collection.*

// 回测报告接口。
public interface Report {
    func Begin(assetNames: ArrayList<String>, strategies: ArrayList<Strategy>): Option<Exception>
    func AssetBegin(name: String, strategies: ArrayList<Strategy>): Option<Exception>
    func Write(assetName: String, currentStrategy: Strategy, snapshots: Iterator<Snapshot>, actions: Iterator<Action>, outcomes: Iterator<Float64>): Option<Exception>
    func AssetEnd(name: String): Option<Exception>
    func End(): Option<Exception>
}


