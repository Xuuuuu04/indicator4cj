package indicator4cj.strategy

import std.core.*
// Outcome：初始资金 1，Buy 全仓买入，Sell 全仓卖出，输出相对收益-1..N。
public func Outcome(values: Iterator<Float64>, actions: Iterator<Action>): Iterator<Float64> {
    return OutcomeIterator(values, actions)
}

class OutcomeIterator <: Iterator<Float64> {
    private let values: Iterator<Float64>
    private let actions: Iterator<Action>
    private var balance: Float64 = 1.0
    private var shares: Float64 = 0.0

    public init(values: Iterator<Float64>, actions: Iterator<Action>) {
        this.values = values
        this.actions = actions
    }

    public func next(): Option<Float64> {
        match (values.next()) {
            case Some(v) =>
                match (actions.next()) {
                    case Some(a) =>
                        if (balance > 0.0 && a == Action.Buy) {
                            shares = balance / v
                            balance = 0.0
                        } else if (shares > 0.0 && a == Action.Sell) {
                            balance = shares * v
                            shares = 0.0
                        }
                        return Some(balance + shares * v - 1.0)
                    case None => return None
                }
            case None => return None
        }
    }
}

