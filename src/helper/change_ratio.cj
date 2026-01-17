package indicator4cj.helper

/**
 * changeRatio 计算比例变化
 *
 * 计算当前值与 before 步之前的值的比例变化。
 * 公式：(当前值 - 前值) / 前值
 *
 * 实现方式：按照 Go 版本使用 Duplicate/Buffered 组合。
 * 1. 复制迭代器为 2 份
 * 2. 第 1 份跳过 before 个元素后计算差值（分子）
 * 3. 第 2 份缓存 before 个元素（分母）
 * 4. 分子除以分母得到比例
 *
 * 示例：changeRatio([100, 110, 120], 1) => [None, 0.1, 0.09]
 * 解释：110 相对 100 变化 0.1（10%），120 相对 110 变化约 0.09（9%）
 *
 * @param iter 数值迭代器
 * @param before 回溯步数
 * @return 比例变化迭代器（小数形式，如 0.1 表示 10%）
 */
public func changeRatio(iter: Iterator<Float64>, before: Int64): Iterator<Float64> {
    let cs = duplicate(iter, 2)
    // 分子：cs[0] 跳过 before，与 cs[1] 未跳过对齐。
    let numerator = change(cs[0], before) // length: n-before
    let denominator = buffered(cs[1], before)
    return divide(numerator, denominator)
}

