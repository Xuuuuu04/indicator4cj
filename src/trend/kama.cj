package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

/**
 * DefaultKamaErPeriod KAMA默认效率周期
 *
 * 默认值：10
 * 用途：计算效率比（Efficiency Ratio）的周期
 */
public const DefaultKamaErPeriod: Int64 = 10

/**
 * DefaultKamaFastScPeriod KAMA默认快速平滑周期
 *
 * 默认值：2
 * 用途：计算快速平滑系数的周期
 */
public const DefaultKamaFastScPeriod: Int64 = 2

/**
 * DefaultKamaSlowScPeriod KAMA默认慢速平滑周期
 *
 * 默认值：30
 * 用途：计算慢速平滑系数的周期
 */
public const DefaultKamaSlowScPeriod: Int64 = 30

/**
 * Kama 考夫曼自适应移动平均
 *
 * 计算公式：KAMA = KAMA_prev + SC * (Price - KAMA_prev)
 * 其中 SC（平滑系数）根据效率比（ER）动态调整：
 * - ER = Direction / Volatility
 * - SC = (ER * (FastSC - SlowSC) + SlowSC)^2
 *
 * 详细说明：
 * 由 Perry Kaufman 创建，是一种能够根据市场波动性自适应调整的移动平均线。
 * 在趋势明显时反应迅速，在震荡市场时平滑缓慢。
 *
 * 核心概念：
 * - 效率比（ER）：衡量价格方向性移动的效率，范围0-1
 *   * ER接近1：强趋势，价格单向移动
 *   * ER接近0：震荡，价格来回波动
 * - 平滑系数（SC）：根据ER动态调整
 *   * ER高时，SC接近快速平滑系数
 *   * ER低时，SC接近慢速平滑系数
 *
 * 特点：
 * - 自适应：根据市场状态自动调整灵敏度
 * - 智能过滤：在震荡市场减少噪音，在趋势市场快速响应
 * - 双重优势：兼具EMA的灵敏性和SMA的稳定性
 *
 * 用途：
 * - 趋势识别：KAMA的斜率反映趋势强度
 * - 交易信号：价格突破KAMA可能预示趋势改变
 * - 过滤震荡：自动适应市场波动
 *
 * 交易信号：
 * - 价格上穿KAMA：买入信号
 * - 价格下穿KAMA：卖出信号
 * - KAMA转向：趋势可能改变
 *
 * 创建者：Perry Kaufman（佩里·考夫曼）
 * 出处：《Smarter Trading》一书（1995年）
 *
 * 注意事项：
 * - 参数可根据市场特性调整
 * - 适合各种时间周期
 * - 在趋势市场中效果最佳
 */
public class Kama {
    /**
     * erPeriod 效率周期
     *
     * 默认值：DefaultKamaErPeriod（10）
     * 用途：计算效率比的时间窗口
     */
    public var erPeriod: Int64 = DefaultKamaErPeriod

    /**
     * fastScPeriod 快速平滑周期
     *
     * 默认值：DefaultKamaFastScPeriod（2）
     * 用途：在强趋势时使用的快速平滑系数
     */
    public var fastScPeriod: Int64 = DefaultKamaFastScPeriod

    /**
     * slowScPeriod 慢速平滑周期
     *
     * 默认值：DefaultKamaSlowScPeriod（30）
     * 用途：在震荡市场时使用的慢速平滑系数
     */
    public var slowScPeriod: Int64 = DefaultKamaSlowScPeriod

    /**
     * 默认构造函数
     *
     * 使用默认参数初始化KAMA
     */
    public Kama() {
        // 使用成员变量默认值
    }

    /**
     * 带参数构造函数
     *
     * @param erPeriod 效率周期
     * @param fastScPeriod 快速平滑周期
     * @param slowScPeriod 慢速平滑周期
     */
    public init(erPeriod: Int64, fastScPeriod: Int64, slowScPeriod: Int64) {
        this.erPeriod = erPeriod
        this.fastScPeriod = fastScPeriod
        this.slowScPeriod = slowScPeriod
    }

    /**
     * compute 计算考夫曼自适应移动平均
     *
     * 计算步骤：
     * 1. 计算方向性：Direction = |Price - Price_erPeriod ago|
     * 2. 计算波动性：Volatility = Sum(|Price - Price_prev|, erPeriod)
     * 3. 计算效率比：ER = Direction / Volatility
     * 4. 计算平滑系数：SC = (ER * (FastSC - SlowSC) + SlowSC)^2
     * 5. 应用KAMA公式：KAMA = KAMA_prev + SC * (Price - KAMA_prev)
     *
     * @param closings 收盘价迭代器
     * @return KAMA值迭代器
     */
    public func compute(closings: Iterator<Float64>): Iterator<Float64> {
        let closingsSplice = duplicate(closings, 3)

        let directions = abs(change(closingsSplice[0], erPeriod))

        let movingSum = MovingSum()
        movingSum.period = erPeriod
        let volatilitys = movingSum.compute(abs(change(closingsSplice[1], 1)))

        let ers = divide(directions, volatilitys)

        let fastSc = 2.0 / Float64(fastScPeriod + 1)
        let slowSc = 2.0 / Float64(slowScPeriod + 1)

        let scs = pow(
            incrementBy(
                multiplyBy(
                    ers,
                    fastSc - slowSc
                ),
                slowSc
            ),
            2.0
        )

        let closingsShifted = skip(closingsSplice[2], erPeriod - 1)
        return KamaIterator(closingsShifted, scs)
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（erPeriod-1）
     */
    public func idlePeriod(): Int64 { return erPeriod - 1 }

    /**
     * toString 返回指标的字符串表示
     *
     * @return 格式为 "KAMA(erPeriod,fastScPeriod,slowScPeriod)" 的字符串
     */
    public func toString(): String {
        return "KAMA(${erPeriod},${fastScPeriod},${slowScPeriod})"
    }
}

/**
 * KamaIterator KAMA迭代器实现
 *
 * 内部迭代器类，实现考夫曼自适应移动平均的具体计算逻辑。
 */
private class KamaIterator <: Iterator<Float64> {
    private let _prices: Iterator<Float64>
    private let _scs: Iterator<Float64>
    private var _prev: Float64 = 0.0
    private var _seeded: Bool = false

    public init(prices: Iterator<Float64>, scs: Iterator<Float64>) {
        this._prices = prices
        this._scs = scs
    }

    public func next(): Option<Float64> {
        if (!_seeded) {
            match (_prices.next()) {
                case Some(p) =>
                    _prev = p
                    _seeded = true
                    return Some(_prev)
                case None => return None
            }
        }

        match (_prices.next()) {
            case Some(price) =>
                match (_scs.next()) {
                    case Some(sc) =>
                        _prev = _prev + sc * (price - _prev)
                        return Some(_prev)
                    case None => return None
                }
            case None => return None
        }
    }
}
