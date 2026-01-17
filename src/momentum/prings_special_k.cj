package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

/**
 * PringsSpecialK Pring特别K指标
 *
 * 计算公式：Special K = EMA(10, 加权ROC总和)
 * 其中加权ROC总和 = Σ(ROC(period) * 权重)
 *
 * 权重分配：
 * - ROC(10) * 1.0, ROC(15) * 2.0, ROC(20) * 3.0, ROC(30) * 4.0
 * - ROC(40) * 1.0, ROC(65) * 2.0, ROC(75) * 3.0, ROC(100) * 4.0
 * - ROC(195) * 1.0, ROC(265) * 2.0, ROC(390) * 3.0, ROC(530) * 4.0
 *
 * 详细说明：
 * 由 Martin Pring 创建，是一种复合动量振荡器。
 * 结合多个时间周期的ROC（变化率）指标，通过加权平均来平滑数据。
 *
 * 特点：
 * - 多周期复合：整合从短期（10期）到长期（530期）的动量信息
 * - 加权设计：中间周期权重更高，两端权重较低
 * - 平滑处理：最终经EMA(10)平滑，减少噪音
 *
 * 用途：
 * - 识别长期趋势转折点
 * - 确认趋势强度
 * - 生成买卖信号（零轴交叉）
 *
 * 创建者：Martin Pring（马丁·普林）
 * 相关指标：KST Indicator（Know Sure Thing）
 *
 * 注意事项：
 * - 空闲周期较长（529期），需要足够的历史数据
 * - 适合日线级别以上的分析
 * - 在强趋势市场中表现最佳
 */
public class PringsSpecialK {
    /**
     * compute 计算普林特殊K指标值
     *
     * @param values 价格序列迭代器
     * @return 特殊K值迭代器，正值表示上涨动量，负值表示下跌动量
     */
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let roc10 = multiplyBy(roc(values, 10), 1.0)
        let roc15 = multiplyBy(roc(values, 15), 2.0)
        let roc20 = multiplyBy(roc(values, 20), 3.0)
        let roc30 = multiplyBy(roc(values, 30), 4.0)
        let roc40 = multiplyBy(roc(values, 40), 1.0)
        let roc65 = multiplyBy(roc(values, 65), 2.0)
        let roc75 = multiplyBy(roc(values, 75), 3.0)
        let roc100 = multiplyBy(roc(values, 100), 4.0)
        let roc195 = multiplyBy(roc(values, 195), 1.0)
        let roc265 = multiplyBy(roc(values, 265), 2.0)
        let roc390 = multiplyBy(roc(values, 390), 3.0)
        let roc530 = multiplyBy(roc(values, 530), 4.0)

        let s1 = add(roc10, roc15)
        let s2 = add(roc20, roc30)
        let s3 = add(roc40, roc65)
        let s4 = add(roc75, roc100)
        let s5 = add(roc195, roc265)
        let s6 = add(roc390, roc530)
        let sum = add(add(s1, s2), add(add(s3, s4), add(s5, s6)))

        let ema = Ema(10)
        return ema.compute(sum)
    }

    /**
     * idlePeriod 返回空闲周期数
     *
     * @return 需要预热的周期数（530-1=529），前529个数据点不产生有效输出
     */
    public func idlePeriod(): Int64 { return 530 - 1 }
}

/**
 * roc 变化率辅助函数
 *
 * 计算公式：ROC = (当前价格 - n期前价格) / n期前价格 * 100
 *
 * @param values 价格序列迭代器
 * @param period 计算周期
 * @return ROC值迭代器（百分比形式）
 */
private func roc(values: Iterator<Float64>, period: Int64): Iterator<Float64> {
    return multiplyBy(changeRatio(values, period), 100.0)
}

