package indicator4cj.strategy

import std.core.*
import indicator4cj.asset.*
import indicator4cj.helper.*

// Buy on first tick, hold thereafter.
public class BuyAndHoldStrategy <: Strategy {
    private var first: Bool = true

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
    private let source: Iterator<Snapshot>
    private var isFirst: Bool = true

    public init(source: Iterator<Snapshot>) {
        this.source = source
    }

    public func next(): Option<Action> {
        match (source.next()) {
            case Some(_) =>
                if (isFirst) {
                    isFirst = false
                    return Some(Action.Buy)
                }
                return Some(Action.Hold)
            case None => return None
        }
    }
}

