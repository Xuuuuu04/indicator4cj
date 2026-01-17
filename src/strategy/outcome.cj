package indicator4cj.strategy

import std.core.*

/**
 * outcome 计算策略收益
 *
 * 根据价格序列和交易动作序列计算投资收益。
 * 采用简单交易模型：初始资金1，BUY全仓买入，SELL全仓卖出。
 *
 * ### 交易模型
 * - 初始资金：1.0
 * - 买入信号：将所有现金转换为股票（全仓买入）
 * - 卖出信号：将所有股票转换为现金（全仓卖出）
 * - 持有信号：保持当前状态
 *
 * ### 收益计算
 * 返回相对收益 = 当前总价值 - 初始资金
 * 当前总价值 = 现金 + 股票数量 × 当前价格
 *
 * ### 示例
 * ```cangjie
 * let prices = [100.0, 105.0, 103.0, 108.0]
 * let actions = [BUY, HOLD, SELL, HOLD]
 * let returns = outcome(prices.iterator(), actions.iterator())
 * // 结果: [0.0, 0.05, 0.08, 0.08] (假设初始为HOLD状态)
 * ```
 *
 * @param values 价格序列迭代器
 * @param actions 交易动作序列迭代器
 * @return 相对收益序列迭代器（范围：-1.0 到 +∞）
 */
public func outcome(values: Iterator<Float64>, actions: Iterator<Action>): Iterator<Float64> {
    return OutcomeIterator(values, actions)
}

/**
 * OutcomeIterator 收益计算迭代器
 *
 * 内部迭代器类，实现交易收益的具体计算逻辑
 */
class OutcomeIterator <: Iterator<Float64> {
    /**
     * _values 价格序列
     */
    private let _values: Iterator<Float64>

    /**
     * _actions 交易动作序列
     */
    private let _actions: Iterator<Action>

    /**
     * _balance 当前现金余额
     *
     * 初始为1.0，买入后变为0，卖出后获得现金
     */
    private var _balance: Float64 = 1.0

    /**
     * _shares 当前持股数量
     *
     * 初始为0，买入后持有，卖出后清空
     */
    private var _shares: Float64 = 0.0

    /**
     * 构造函数
     *
     * @param values 价格序列
     * @param actions 交易动作序列
     */
    public init(values: Iterator<Float64>, actions: Iterator<Action>) {
        this._values = values
        this._actions = actions
    }

    /**
     * next 计算下一个收益值
     *
     * 根据当前价格和交易动作更新投资组合状态并计算收益
     *
     * @return 当前相对收益的Option，序列结束时返回None
     */
    public func next(): Option<Float64> {
        match (_values.next()) {
            case Some(v) =>
                match (_actions.next()) {
                    case Some(a) =>
                        // 买入逻辑：全仓买入
                        if (_balance > 0.0 && a == Action.BUY) {
                            _shares = _balance / v
                            _balance = 0.0
                        }
                        // 卖出逻辑：全仓卖出
                        else if (_shares > 0.0 && a == Action.SELL) {
                            _balance = _shares * v
                            _shares = 0.0
                        }
                        // 计算当前总价值并返回相对收益
                        return Some(_balance + _shares * v - 1.0)
                    case None => return None
                }
            case None => return None
        }
    }
}
