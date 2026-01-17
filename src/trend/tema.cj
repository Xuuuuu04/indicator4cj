package indicator4cj.trend

import std.core.*
import indicator4cj.helper.*

/**
 * Tema 三重指数移动平均线
 *
 * 计算公式：TEMA = 3 * EMA1 - 3 * EMA2 + EMA3
 * 其中：
 * - EMA1 = EMA(price)
 * - EMA2 = EMA(EMA1)
 * - EMA3 = EMA(EMA2)
 *
 * 详细说明：
 * 由 Patrick G. Mulloy 在1994年创建，是DEMA的进一步扩展。
 * 通过三层EMA计算和复杂的权重调整，最大程度减小滞后性。
 *
 * 特点：
 * - 滞后最小：在EMA系列中滞后性最小
 * - 反应最快：对价格变化反应极其灵敏
 * - 贴合度最高：曲线最接近实际价格
 * - 权重复杂：通过3*EMA1 - 3*EMA2 + EMA3调整
 *
 * 用途：
 * - 高频交易：适合需要快速响应的交易策略
 * - 日内交易：捕捉日内价格波动
 * - 突破交易：快速识别价格突破
 *
 * 优势：
 * - 滞后性在所有移动平均中最小
 * - 对趋势变化反应最快
 *
 * 劣势：
 * - 极易产生假信号
 * - 对噪音非常敏感
 * - 不适合新手使用
 *
 * 创建者：Patrick G. Mulloy
 * 创建时间：1994年（与DEMA同时发表）
 * 相关指标：DEMA（双重指数移动平均）
 *
 * 注意事项：
 * - 建议配合其他指标使用以过滤假信号
 * - 适合有经验的交易者
 * - 在强趋势市场中效果最佳
 */
public class Tema {
    /**
     * ema1 第一层EMA（快速EMA）
     *
     * 计算原始价格的指数移动平均
     */
    public let ema1: Ema

    /**
     * ema2 第二层EMA（中速EMA）
     *
     * 对ema1的结果再求指数移动平均
     */
    public let ema2: Ema

    /**
     * ema3 第三层EMA（慢速EMA）
     *
     * 对ema2的结果再求指数移动平均
     */
    public let ema3: Ema

    /**
     * 默认构造函数
     *
     * 使用默认周期初始化TEMA
     */
    public Tema() {
        this.ema1 = Ema()
        this.ema2 = Ema()
        this.ema3 = Ema()
    }

    /**
     * compute 计算三重指数移动平均线
     *
     * 计算步骤：
     * 1. 计算原始价格的EMA（ema1）
     * 2. 对ema1再求EMA（ema2）
     * 3. 对ema2再求EMA（ema3）
     * 4. 应用公式：TEMA = 3*ema1 - 3*ema2 + ema3
     *
     * @param values 价格数据迭代器
     * @return TEMA值迭代器
     */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let ema1Values = duplicate(this.ema1.compute(values), 2)
        let ema2Values = duplicate(this.ema2.compute(ema1Values[0]), 2)

        ema1Values[1] = skip(ema1Values[1], this.ema2.period - 1)

        let ema3Value = this.ema3.compute(ema2Values[0])
        ema1Values[1] = skip(ema1Values[1], this.ema3.period - 1)
        ema2Values[1] = skip(ema2Values[1], this.ema3.period - 1)

        let temaValue = add(
            subtract(
                multiplyBy(ema1Values[1], 3.0),
                multiplyBy(ema2Values[1], 3.0)
            ),
            ema3Value
        )

        return temaValue
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（period1 + period2 + period3 - 3）
     */
    public func idlePeriod(): Int64 {
        return this.ema1.period + this.ema2.period + this.ema3.period - 3
    }
}
