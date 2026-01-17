package indicator4cj.strategy.trend

import std.core.*
import indicator4cj.asset.*
import indicator4cj.helper.*
import indicator4cj.strategy.*
import indicator4cj.strategy.momentum as m

/**
 * TripleRsiStrategy 三重RSI策略（兼容代理）
 *
 * 这是一个代理类，用于保持向后兼容性。
 * 实际实现位于 indicator4cj.strategy.momentum.TripleRsiStrategy。
 *
 * 该类将所有方法调用委托给动量包中的真实实现。
 *
 * @see indicator4cj.strategy.momentum.TripleRsiStrategy
 */
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


