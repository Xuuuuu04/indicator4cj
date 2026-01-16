package indicator4cj.helper

// simpleDate：简化日期，仅年/月/日，用于 DaysBetween 计算。
public struct SimpleDate {
    // year
    public let year: Int64
    // month
    public let month: Int64 // 1-12
    // day
    public let day: Int64   // 1-31

    public init(year: Int64, month: Int64, day: Int64) {
        this.year = year
        this.month = month
        this.day = day
    }
}

// daysBetween：计算两个日期之间的整天差（to - from）。
public func daysBetween(from: SimpleDate, to: SimpleDate): Int64 {
    return daysFromCivil(to) - daysFromCivil(from)
}

// 参考 Howard Hinnant days from civil 算法，使用公历。
private func daysFromCivil(date: SimpleDate): Int64 {
    var y = date.year
    var m = date.month
    let d = date.day

    // 将 1,2 月视为上一年的 13,14 月，便于计算。
    if (m <= 2) {
        y = y - 1
        m = m + 12
    }

    let era = floorDiv(y, 400)
    let yoe = y - era * 400                     // [0, 399]
    let doy = (153 * (m - 3) + 2) / 5 + d - 1   // [0, 365]
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy // [0, 146096]
    return era * 146097 + doe - 719468 // 719468 调整到 Unix epoch (1970-01-01) 为 0
}

private func floorDiv(a: Int64, b: Int64): Int64 {
    if (a >= 0) {
        return a / b
    }
    return -(((-a) + b - 1) / b)
}

