package indicator4cj.helper

// changePercent：百分比变化 = ChangeRatio * 100。
public func changePercent(iter: Iterator<Float64>, before: Int64): Iterator<Float64> {
    return apply(changeRatio(iter, before), { v => v * 100.0 })
}

