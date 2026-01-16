package indicator4cj.helper

import std.collection.*

// slicesReverse：从索引 i 开始反向遍历切片，先 [i-1..0] 再 [len-1..i]。
// f 返回 false 即终止。
public func slicesReverse<T>(arr: ArrayList<T>, i: Int64, f: (T) -> Bool): Unit {
    let l = arr.size
    if (l == 0 || i < 0 || i >= l) {
        return
    }

    var m = i - 1
    while (m >= 0) {
        if (!f(arr[m])) {
            return
        }
        m -= 1
    }

    m = l - 1
    while (m >= i) {
        if (!f(arr[m])) {
            return
        }
        m -= 1
    }
}

