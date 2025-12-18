package indicator4cj.helper

// ChangePercent：百分比变化 = ChangeRatio * 100。
public func ChangePercent(iter: Iterator<Float64>, before: Int64): Iterator<Float64> {
    return Apply(ChangeRatio(iter, before), { v => v * 100.0 })
}

