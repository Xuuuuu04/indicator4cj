package indicator4cj.strategy

import std.core.*
// Outcome：初始资金 1，Buy 全仓买入，Sell 全仓卖出，输出相对收益-1..N。
public func outcome(values: Iterator<Float64>, actions: Iterator<Action>): Iterator<Float64> {
    return OutcomeIterator(values, actions)
}

class OutcomeIterator <: Iterator<Float64> {
    private let _values: Iterator<Float64>
    private let _actions: Iterator<Action>
    private var _balance: Float64 = 1.0
    private var _shares: Float64 = 0.0

    public init(values: Iterator<Float64>, actions: Iterator<Action>) {
        this._values = values
        this._actions = actions
    }

    public func next(): Option<Float64> {
        match (_values.next()) {
            case Some(v) =>
                match (_actions.next()) {
                    case Some(a) =>
                        if (_balance > 0.0 && a == Action.BUY) {
                            _shares = _balance / v
                            _balance = 0.0
                        } else if (_shares > 0.0 && a == Action.SELL) {
                            _balance = _shares * v
                            _shares = 0.0
                        }
                        return Some(_balance + _shares * v - 1.0)
                    case None => return None
                }
            case None => return None
        }
    }
}

