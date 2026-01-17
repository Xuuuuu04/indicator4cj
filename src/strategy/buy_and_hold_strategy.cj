package indicator4cj.strategy

import std.core.*
import indicator4cj.asset.*
import indicator4cj.helper.*

// Buy on first tick, hold thereafter.
public class BuyAndHoldStrategy <: Strategy {
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

