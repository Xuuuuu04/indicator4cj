package indicator4cj.strategy.trend

import std.core.*
import indicator4cj.asset.*
import indicator4cj.helper.*
import indicator4cj.strategy.*
import indicator4cj.strategy.momentum as m

// 为兼容旧路径，代理到动量包的真实实现。
public class TripleRsiStrategy <: Strategy {
    private let _impl: m.TripleRsiStrategy

    public init() { this._impl = m.TripleRsiStrategy() }

    public func Name(): String { return _impl.Name() }

    public func Compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        return _impl.Compute(snapshots)
    }

    public func Report(snapshots: Iterator<Snapshot>): Report {
        return _impl.Report(snapshots)
    }
}

public func NewTripleRsiStrategy(): TripleRsiStrategy { return TripleRsiStrategy() }


