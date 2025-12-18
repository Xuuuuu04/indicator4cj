package indicator4cj.strategy

import std.core.*
import indicator4cj.asset.*
import indicator4cj.helper.*

// Buy on first tick, hold thereafter.
public class BuyAndHoldStrategy <: Strategy {
    private var first: Bool = true

    public func Name(): String { return "BuyAndHold" }

    public func Compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        return BuyAndHoldIterator(snapshots)
    }

    public func Report(snapshots: Iterator<Snapshot>): Report {
        let dates = SnapshotsAsDates(snapshots)
        return NewReport(Name(), dates)
    }
}

public func NewBuyAndHoldStrategy(): BuyAndHoldStrategy {
    return BuyAndHoldStrategy()
}

class BuyAndHoldIterator <: Iterator<Action> {
    private let source: Iterator<Snapshot>
    private var _first: Bool = true

    public init(source: Iterator<Snapshot>) {
        this.source = source
    }

    public func next(): Option<Action> {
        match (source.next()) {
            case Some(_) =>
                if (_first) {
                    _first = false
                    return Some(Action.Buy)
                }
                return Some(Action.Hold)
            case None => return None
        }
    }
}

