package indicator4cj.helper

// Lcm：最小公倍数（Int64 变体）。
public func Lcm(values: Array<Int64>): Int64 {
    var lcm = values[0]
    var i: Int64 = 1
    while (i < values.size) {
        lcm = (values[i] * lcm) / Gcd([values[i], lcm])
        i += 1
    }
    return lcm
}

