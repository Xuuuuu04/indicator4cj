package indicator4cj.strategy

import std.core.*
import std.collection.*

public enum Action <: ToString & Equatable<Action> {
    | Buy
    | Sell
    | Hold

    public func toString(): String {
        match (this) {
            case Action.Buy => return "Buy"
            case Action.Sell => return "Sell"
            case Action.Hold => return "Hold"
        }
    }

    public operator func ==(right: Action): Bool {
        match (this) {
            case Action.Buy =>
                match (right) { case Action.Buy => return true case _ => return false }
            case Action.Sell =>
                match (right) { case Action.Sell => return true case _ => return false }
            case Action.Hold =>
                match (right) { case Action.Hold => return true case _ => return false }
        }
    }

    public operator func !=(right: Action): Bool {
        return !(this == right)
    }
}

// 返回 "B"/"S"/"" 注解。
public func Annotation(a: Action): String {
    match (a) {
        case Action.Buy => return "B"
        case Action.Sell => return "S"
        case Action.Hold => return ""
    }
}

// 将 Action 迭代器转注解迭代器（一次性消费）。
public func actionsToAnnotations(ac: Iterator<Action>): Iterator<String> {
    let norm = normalizeActions(ac)
    let res = ArrayList<String>()
    while (true) {
        match (norm.next()) {
            case Some(a) => res.add(Annotation(a))
            case None => break
        }
    }
    return res.iterator()
}

// 归一化：消除连续重复的非 Hold，保持 Hold/Buy/Hold/Sell 顺序。
public func normalizeActions(ac: Iterator<Action>): Iterator<Action> {
    var last = Action.Sell
    let res = ArrayList<Action>()
    while (true) {
        match (ac.next()) {
            case Some(a) =>
                if (a != Action.Hold && a != last) {
                    last = a
                    res.add(a)
                } else {
                    res.add(Action.Hold)
                }
            case None => break
        }
    }
    return res.iterator()
}

// 反归一化：填充 Hold 为上一个非 Hold。
public func denormalizeActions(ac: Iterator<Action>): Iterator<Action> {
    var last = Action.Hold
    let res = ArrayList<Action>()
    while (true) {
        match (ac.next()) {
            case Some(a) =>
                if (a != Action.Hold && a != last) {
                    last = a
                }
                res.add(last)
            case None => break
        }
    }
    return res.iterator()
}

public func actionFromInt(v: Int64): Action {
    if (v == 1) { return Action.Buy }
    if (v == -1) { return Action.Sell }
    return Action.Hold
}

// 统计多个 Action 迭代器当前值，返回 (buy, hold, sell, ok)
public func countActions(acs: ArrayList<Iterator<Action>>): (Int64, Int64, Int64, Bool) {
    var buy: Int64 = 0
    var hold: Int64 = 0
    var sell: Int64 = 0
    for (ac in acs) {
        match (ac.next()) {
            case Some(a) =>
                match (a) {
                    case Action.Buy => buy += 1
                    case Action.Sell => sell += 1
                    case Action.Hold => hold += 1
                }
            case None => return (0, 0, 0, false)
        }
    }
    return (buy, hold, sell, true)
}

// 统计交易次数（非 Hold）。
public func countTransactions(ac: Iterator<Action>): Iterator<Int64> {
    var tx: Int64 = 0
    let res = ArrayList<Int64>()
    while (true) {
        match (ac.next()) {
            case Some(a) =>
                if (a != Action.Hold) { tx += 1 }
                res.add(tx)
            case None => break
        }
    }
    return res.iterator()
}

