package indicator4cj.helper

// Filter：按谓词过滤迭代器元素，等价 Go 版 Filter。
public func filterIter<T>(iter: Iterator<T>, predicate: (T) -> Bool): Iterator<T> {
    return FilterIterator<T>(iter, predicate)
}

// Go同名兼容导出。
public func Filter<T>(iter: Iterator<T>, predicate: (T) -> Bool): Iterator<T> {
    return filterIter(iter, predicate)
}

public class FilterIterator<T> <: Iterator<T> {
    private let _source: Iterator<T>
    private let _predicate: (T) -> Bool

    public init(source: Iterator<T>, predicate: (T) -> Bool) {
        this._source = source
        this._predicate = predicate
    }

    public func next(): Option<T> {
        while (true) {
            match (_source.next()) {
                case Some(v) =>
                    if (_predicate(v)) {
                        return Some(v)
                    }
                case None => return None
            }
        }
        return None
    }
}

