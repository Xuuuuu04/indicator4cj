package indicator4cj.helper

// Gcd：最大公约数（Int64 变体）。
public func Gcd(values: Array<Int64>): Int64 {
    var gcd = values[0]
    var i: Int64 = 1
    while (i < values.size) {
        var value = values[i]
        while (value > 0) {
            let tmp = gcd % value
            gcd = value
            value = tmp
        }
        if (gcd == 1) {
            break
        }
        i += 1
    }
    return gcd
}

