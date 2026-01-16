package indicator4cj.strategy.trend

import std.core.*
import indicator4cj.asset.*
import indicator4cj.helper.*
import indicator4cj.strategy.*
import indicator4cj.strategy.momentum as m

// 为兼容旧路径，代理到动量包的真实实现。
public class TripleRsiStrategy <: Strategy {
    private let _impl: m.TripleRsiStrategy

    public init() {
        this._impl = m.TripleRsiStrategy()
    }

    public func name(): String { return _impl.name() }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        return _impl.compute(snapshots)
    }

    public func report(snapshots: Iterator<Snapshot>): Report {
        return _impl.report(snapshots)
    }
}


