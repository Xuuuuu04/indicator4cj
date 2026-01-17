package indicator4cj.strategy

import std.core.*
import indicator4cj.asset.*
import indicator4cj.helper.*

/**
 * BuyAndHoldStrategy 买入并持有策略
 *
 * 最简单的交易策略：在第一个tick时全仓买入，之后一直持有。
 *
 * 这是一个基准策略，用于评估其他策略的表现。
 * 如果其他策略无法跑赢买入并持有策略，说明该策略没有实际价值。
 */
public class BuyAndHoldStrategy <: Strategy {
    // 是否为首次执行（首次执行时产生买入信号）
    private var _first: Bool = true

    public func name(): String { return "BuyAndHold" }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        return BuyAndHoldIterator(snapshots)
    }

    public func report(snapshots: Iterator<Snapshot>): Report {
        let dates = snapshotsAsDates(snapshots)
        return Report(name(), dates)
    }
}

class BuyAndHoldIterator <: Iterator<Action> {
    private let _source: Iterator<Snapshot>
    private var _isFirst: Bool = true

    public init(source: Iterator<Snapshot>) {
        this._source = source
    }

    public func next(): Option<Action> {
        match (_source.next()) {
            case Some(_) =>
                if (_isFirst) {
                    _isFirst = false
                    return Some(Action.BUY)
                }
                return Some(Action.HOLD)
            case None => return None
        }
    }
}

