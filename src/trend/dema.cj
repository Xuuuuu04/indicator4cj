package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

/**
 * Dema 双重指数移动平均线
 *
 * 计算公式：DEMA = 2 * EMA1 - EMA(EMA1)
 * 其中 EMA1 是原始价格的EMA，EMA(EMA1) 是对EMA1再求EMA
 *
 * 详细说明：
 * 由 Patrick G. Mulloy 在1994年创建，旨在减少单次EMA的滞后性。
 * 通过对EMA再求EMA，然后调整权重，使得指标更贴近价格走势。
 *
 * 特点：
 * - 滞后更小：相比普通EMA滞后性明显减小
 * - 反应更快：对价格变化反应更灵敏
 * - 更贴近价格：曲线更接近实际价格走势
 * - 权重调整：通过2*EMA - EMA(EMA)的公式调整权重
 *
 * 用途：
 * - 短线交易：适合捕捉短期价格变动
 * - 趋势确认：快速响应趋势变化
 * - 交叉系统：DEMA交叉比EMA交叉更灵敏
 *
 * 优势：
 * - 滞后性远小于EMA和SMA
 * - 保持平滑性的同时提高了灵敏度
 *
 * 劣势：
 * - 可能产生过多信号
 * - 在震荡市场中容易受噪音影响
 *
 * 创建者：Patrick G. Mulloy
 * 创建时间：1994年
 * 相关指标：TEMA（三重指数移动平均）
 */
public class Dema {
    /**
     * ema1 第一层EMA（快速EMA）
     *
     * 用于计算原始价格的指数移动平均
     */
    public let ema1: Ema

    /**
     * ema2 第二层EMA（慢速EMA）
     *
     * 用于对EMA1的结果再求指数移动平均
     */
    public let ema2: Ema

    /**
     * 默认构造函数
     *
     * 使用默认周期初始化DEMA
     */
    public Dema() {
        this.ema1 = Ema()
        this.ema2 = Ema()
    }

    /**
     * compute 计算双重指数移动平均线
     *
     * 计算步骤：
     * 1. 计算原始价格的EMA（ema1）
     * 2. 对ema1的结果再求EMA（ema2）
     * 3. 应用公式：DEMA = 2 * ema1 - ema2
     *
     * @param values 价格数据迭代器
     * @return DEMA值迭代器
     */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let ema1Values = duplicate(this.ema1.compute(values), 2)
        let ema2Value = this.ema2.compute(ema1Values[1])

        var doubleEma1 = multiplyBy(ema1Values[0], 2.0)
        doubleEma1 = buffered(doubleEma1, this.ema2.period)

        return subtract(doubleEma1, ema2Value)
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（period1 + period2 - 2）
     */
    public func idlePeriod(): Int64 {
        return this.ema1.period + this.ema2.period - 2
    }
}

