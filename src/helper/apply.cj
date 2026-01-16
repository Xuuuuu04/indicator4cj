package indicator4cj.helper

// Apply：数值迭代器自映射，等价 Go 版 Apply。
public func applyIter<T>(iter: Iterator<T>, mapper: (T) -> T): Iterator<T> {
    return mapIter(iter, mapper)
}

// Go同名兼容导出。
public func Apply<T>(iter: Iterator<T>, mapper: (T) -> T): Iterator<T> {
    return applyIter(iter, mapper)
}

