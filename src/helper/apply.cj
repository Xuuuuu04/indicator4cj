package indicator4cj.helper

// apply：数值迭代器自映射，等价 Go 版 Apply。
public func applyIter<T>(iter: Iterator<T>, mapper: (T) -> T): Iterator<T> {
    return mapIter(iter, mapper)
}

// go同名兼容导出。
public func apply<T>(iter: Iterator<T>, mapper: (T) -> T): Iterator<T> {
    return applyIter(iter, mapper)
}

