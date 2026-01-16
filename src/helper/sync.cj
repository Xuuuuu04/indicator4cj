package indicator4cj.helper

import std.collection.*

// commonPeriod：返回多个周期中的最大值，用于对齐。
public func commonPeriod(periods: ArrayList<Int64>): Int64 {
    if (periods.isEmpty()) {
        return 0
    }
    var maxVal = periods[0]
    for (i in 1..periods.size) {
        let v = periods[i]
        if (v > maxVal) {
            maxVal = v
        }
    }
    return maxVal
}

// syncPeriod：将迭代器右移 (commonPeriod - period) 以对齐。
public func syncPeriod<T>(commonPeriod: Int64, period: Int64, iter: Iterator<T>): Iterator<T> {
    let forward = commonPeriod - period
    if (forward > 0) {
        return skip(iter, forward)
    }
    return iter
}

