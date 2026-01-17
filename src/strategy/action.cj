package indicator4cj.strategy

import std.core.*
import std.collection.*

/**
 * DEFAULT_ACTION 默认交易动作
 *
 * 用于表示"已平仓"或"观望"状态，默认为 SELL（卖出）。
 * 在归一化动作序列时作为初始值。
 */
public const DEFAULT_ACTION: Action = Action.SELL

/**
 * Action 表示交易动作
 * - BUY: 买入信号
 * - SELL: 卖出信号
 * - HOLD: 持有/观望信号
 */
public enum Action <: ToString & Equatable<Action> {
    | BUY
    | SELL
    | HOLD

    public func toString(): String {
        match (this) {
            case Action.BUY => return "BUY"
            case Action.SELL => return "SELL"
            case Action.HOLD => return "HOLD"
        }
    }

    public operator func ==(right: Action): Bool {
        match (this) {
            case Action.BUY =>
                match (right) { case Action.BUY => return true case _ => return false }
            case Action.SELL =>
                match (right) { case Action.SELL => return true case _ => return false }
            case Action.HOLD =>
                match (right) { case Action.HOLD => return true case _ => return false }
        }
    }

    public operator func !=(right: Action): Bool {
        return !(this == right)
    }
}

/**
 * annotation 将 Action 转换为注解字符串
 * @param a 交易动作
 * @return "B"(买入)/"S"(卖出)/""(持有)
 */
public func annotation(a: Action): String {
    match (a) {
        case Action.BUY => return "B"
        case Action.SELL => return "S"
        case Action.HOLD => return ""
    }
}

/**
 * actionsToAnnotations 将 Action 迭代器转换为注解迭代器（一次性消费）
 * @param ac Action 迭代器
 * @return 注解字符串迭代器
 */
public func actionsToAnnotations(ac: Iterator<Action>): Iterator<String> {
    let norm = normalizeActions(ac)
    let res = ArrayList<String>()
    while (true) {
        match (norm.next()) {
            case Some(a) => res.add(annotation(a))
            case None => break
        }
    }
    return res.iterator()
}

/**
 * normalizeActions 归一化动作序列：消除连续重复的非 HOLD，保持 HOLD/BUY/HOLD/SELL 顺序
 * @param ac Action 迭代器
 * @return 归一化后的 Action 迭代器
 */
public func normalizeActions(ac: Iterator<Action>): Iterator<Action> {
    var last = DEFAULT_ACTION
    let res = ArrayList<Action>()
    while (true) {
        match (ac.next()) {
            case Some(a) =>
                if (a != Action.HOLD && a != last) {
                    last = a
                    res.add(a)
                } else {
                    res.add(Action.HOLD)
                }
            case None => break
        }
    }
    return res.iterator()
}

/**
 * denormalizeActions 反归一化：填充 HOLD 为上一个非 HOLD 动作
 * @param ac Action 迭代器
 * @return 反归一化后的 Action 迭代器
 */
public func denormalizeActions(ac: Iterator<Action>): Iterator<Action> {
    var last = Action.HOLD
    let res = ArrayList<Action>()
    while (true) {
        match (ac.next()) {
            case Some(a) =>
                if (a != Action.HOLD && a != last) {
                    last = a
                }
                res.add(last)
            case None => break
        }
    }
    return res.iterator()
}

/**
 * actionFromInt 将整数转换为 Action
 * @param v 整数值（1=BUY, -1=SELL, 其他=HOLD）
 * @return 对应的 Action
 */
public func actionFromInt(v: Int64): Action {
    if (v == 1) { return Action.BUY }
    if (v == -1) { return Action.SELL }
    return Action.HOLD
}

/**
 * countActions 统计多个 Action 迭代器当前值
 * @param acs Action 迭代器列表
 * @return (买入数量, 持有数量, 卖出数量, 是否全部有效)
 */
public func countActions(acs: ArrayList<Iterator<Action>>): (Int64, Int64, Int64, Bool) {
    var buy: Int64 = 0
    var hold: Int64 = 0
    var sell: Int64 = 0
    for (ac in acs) {
        match (ac.next()) {
            case Some(a) =>
                match (a) {
                    case Action.BUY => buy += 1
                    case Action.SELL => sell += 1
                    case Action.HOLD => hold += 1
                }
            case None => return (0, 0, 0, false)
        }
    }
    return (buy, hold, sell, true)
}

/**
 * countTransactions 统计交易次数（非 HOLD）
 * @param ac Action 迭代器
 * @return 累计交易次数迭代器
 */
public func countTransactions(ac: Iterator<Action>): Iterator<Int64> {
    var tx: Int64 = 0
    let res = ArrayList<Int64>()
    while (true) {
        match (ac.next()) {
            case Some(a) =>
                if (a != Action.HOLD) { tx += 1 }
                res.add(tx)
            case None => break
        }
    }
    return res.iterator()
}

