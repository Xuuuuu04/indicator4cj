package indicator4cj.strategy.trend

import std.core.*
import indicator4cj.asset.*
import indicator4cj.helper.*
import indicator4cj.strategy.*
import indicator4cj.strategy.momentum as m

// 为兼容旧路径，代理到动量包的真实实现。
public class TripleRsiStrategy <: Strategy {
    private let impl: m.TripleRsiStrategy

    public init() { this.impl = m.TripleRsiStrategy() }

    public func name(): String { return impl.name() }

    public func compute(snapshots: Iterator<Snapshot>): Iterator<Action> {
        return impl.compute(snapshots)
    }

    public func report(snapshots: Iterator<Snapshot>): Report {
        return impl.report(snapshots)
    }
}


