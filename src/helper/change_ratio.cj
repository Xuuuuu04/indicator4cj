package indicator4cj.helper

// changeRatio：当前与 before 步之前的比例变化 (curr - prev) / prev，按 Go 版 Duplicate/Buffered 组合。
public func changeRatio(iter: Iterator<Float64>, before: Int64): Iterator<Float64> {
    let cs = duplicate(iter, 2)
    // 分子：cs[0] 跳过 before，与 cs[1] 未跳过对齐。
    let numerator = change(cs[0], before) // length: n-before
    let denominator = buffered(cs[1], before)
    return divide(numerator, denominator)
}

