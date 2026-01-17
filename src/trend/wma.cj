package indicator4cj.trend

import std.core.*
import std.collection.*

/**
 * Wma 加权移动平均线
 *
 * 计算公式：WMA = (P1*1 + P2*2 + ... + Pn*n) / (1 + 2 + ... + n)
 *
 * 详细说明：
 * 对价格序列中的每个数据点赋予线性递增的权重。
 * 最新数据权重最大，最旧数据权重最小（权重为1）。
 *
 * 特点：
 * - 线性加权：权重按1, 2, 3, ..., n线性递增
 * - 贴近价格：相比SMA更贴近实际价格走势
 * - 滞后较小：比SMA滞后性小，但比EMA稍大
 * - 权重明确：每个数据点的权重都是确定的
 *
 * 权重分布：
 * - 最旧数据（索引0）：权重 = 1
 * - 次旧数据（索引1）：权重 = 2
 * - ...
 * - 最新数据（索引n-1）：权重 = n
 *
 * 用途：
 * - 趋势确认：识别趋势方向
 * - 交叉信号：WMA交叉系统
 * - 价格分析：作为价格参考线
 *
 * 交易信号：
 * - 短期WMA上穿长期WMA：买入信号
 * - 价格上穿WMA：可能的上涨信号
 *
 * 优势：
 * - 比SMA反应更快
 * - 计算相对简单
 * - 权重分布明确
 *
 * 劣势：
 * - 仍然存在滞后性
 * - 权重分布不如EMA合理
 *
 * 注意事项：
 * - 周期越长，滞后越明显
 * - 适合中短期分析
 * - 可与其他MA组合使用
 */
public class Wma {
    /**
     * period WMA周期
     *
     * 默认值：20
     * 必须大于0
     * 用途：确定加权窗口的大小
     */
    public var period: Int64 = 20

    /**
     * 带参数构造函数
     *
     * @param period WMA周期，必须大于0
     * @throws Exception 如果周期小于等于0
     */
    public init(period: Int64) {
        if (period <= 0) { throw Exception("[WMA] period must be positive, got ${period}") }
        this.period = period
    }

    /**
     * 默认构造函数
     *
     * 使用默认周期20初始化WMA
     */
    public Wma() {
        this.period = period
    }

    /**
     * compute 计算加权移动平均线
     *
     * 计算方法：
     * 1. 收集周期内的价格数据
     * 2. 对每个价格赋予权重：最新权重=period，最旧权重=1
     * 3. 计算：WMA = Σ(Price[i] * Weight[i]) / Σ(Weight[i])
     *
     * @param values 价格数据迭代器
     * @return WMA值迭代器
     */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        return WmaIterator(values, period)
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（period-1）
     */
    public func idlePeriod(): Int64 { return period - 1 }
}

/**
 * WmaIterator WMA迭代器实现
 *
 * 内部迭代器类，实现加权移动平均的具体计算逻辑。
 * 使用缓冲区存储最近period个价格，并应用线性权重。
 */
private class WmaIterator <: Iterator<Float64> {
    private let _source: Iterator<Float64>
    private let _period: Int64
    private let _buffer = ArrayList<Float64>()
    private let _divisor: Float64

    public init(source: Iterator<Float64>, period: Int64) {
        this._source = source
        this._period = period
        this._divisor = Float64(period) * (Float64(period) + 1.0) / 2.0
    }

    public func next(): Option<Float64> {
        while (true) {
            match (_source.next()) {
                case Some(v) =>
                    _buffer.add(v)
                    if (_buffer.size < _period) {
                        continue
                    }
                    if (_buffer.size > _period) {
                        _buffer.remove(at: 0)
                    }
                    var sum = 0.0
                    var i: Int64 = 0
                    while (i < _period) {
                        // 权重应该是：最新的（索引 period-1）具有权重 'period'
                        // 最旧的（索引 0）具有权重 '1'
                        // 公式：(P*D_t + (P-1)*D_{t-1} + ... + 1*D_{t-P+1}) / 除数
                        // buffer[period-1] 是当前（D_t）
                        // buffer[0] 是最旧的（D_{t-P+1}）

                        // 我的循环：i 从 0 到 period-1。
                        // buffer[i]
                        // 如果 i=0（最旧），权重应该是 1？
                        // 如果 i=period-1（最新），权重应该是 period？

                        // 当前代码：
                        // let weight = Float64(period - i)
                        // i=0 -> weight=period。（最旧获得最大权重？错误！）
                        // i=period-1 -> weight=1。（最新获得最小权重？错误！）

                        // 匹配 Go 实现：最旧的获得最高权重（周期）。
                        let weight = Float64(_period - i)
                        sum += _buffer[i] * weight
                        i += 1
                    }
                    return Some(sum / _divisor)
                case None => return None
            }
        }
        return None
    }
}

// Wma 符合 Ma 接口。
extend Wma <: Ma {}