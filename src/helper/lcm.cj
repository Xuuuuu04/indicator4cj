package indicator4cj.helper

// lcm：最小公倍数（Int64 变体）。
public func lcm(values: Array<Int64>): Int64 {
    var lcm = values[0]
    var i: Int64 = 1
    while (i < values.size) {
        lcm = (values[i] * lcm) / gcd([values[i], lcm])
        i += 1
    }
    return lcm
}

