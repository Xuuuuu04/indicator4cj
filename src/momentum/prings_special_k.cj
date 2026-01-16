package indicator4cj.momentum

import std.core.*
import indicator4cj.helper.*
import indicator4cj.trend.*

// Pring's Special K：加权 ROC 总和经 EMA(10) 平滑。
public class PringsSpecialK {
    // compute 计算普林特殊K指标。
    public func compute(values: Iterator<Float64>): Iterator<Float64> {
        let roc10 = multiplyBy(Roc(values, 10), 1.0)
        let roc15 = multiplyBy(Roc(values, 15), 2.0)
        let roc20 = multiplyBy(Roc(values, 20), 3.0)
        let roc30 = multiplyBy(Roc(values, 30), 4.0)
        let roc40 = multiplyBy(Roc(values, 40), 1.0)
        let roc65 = multiplyBy(Roc(values, 65), 2.0)
        let roc75 = multiplyBy(Roc(values, 75), 3.0)
        let roc100 = multiplyBy(Roc(values, 100), 4.0)
        let roc195 = multiplyBy(Roc(values, 195), 1.0)
        let roc265 = multiplyBy(Roc(values, 265), 2.0)
        let roc390 = multiplyBy(Roc(values, 390), 3.0)
        let roc530 = multiplyBy(Roc(values, 530), 4.0)

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

    // idlePeriod 返回空闲周期数。
    public func idlePeriod(): Int64 { return 530 - 1 }
}

// 变化率辅助函数：(curr - prev_n) / prev_n * 100
private func Roc(values: Iterator<Float64>, period: Int64): Iterator<Float64> {
    return multiplyBy(changeRatio(values, period), 100.0)
}

