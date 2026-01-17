package indicator4cj.helper

/**
 * changePercent 计算百分比变化
 *
 * 计算当前值与 before 步之前的值的百分比变化。
 * 公式：((当前值 - 前值) / 前值) * 100
 *
 * 等价于 changeRatio(iter, before) * 100
 *
 * 示例：changePercent([100, 110, 120], 1) => [None, 10.0, 9.09]
 * 解释：110 相对 100 变化 10%，120 相对 110 变化约 9.09%
 *
 * @param iter 数值迭代器
 * @param before 回溯步数
 * @return 百分比变化迭代器（单位：%）
 */
public func changePercent(iter: Iterator<Float64>, before: Int64): Iterator<Float64> {
    return apply(changeRatio(iter, before), { v => v * 100.0 })
}

