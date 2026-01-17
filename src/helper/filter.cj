package indicator4cj.helper

// filter：按谓词过滤迭代器元素，等价 Go 版 Filter。
public func filterIter<TElement>(iter: Iterator<TElement>, predicate: (TElement) -> Bool): Iterator<TElement> {
    return FilterIterator<TElement>(iter, predicate)
}

// go同名兼容导出。
public func filter<TElement>(iter: Iterator<TElement>, predicate: (TElement) -> Bool): Iterator<TElement> {
    return filterIter(iter, predicate)
}

public class FilterIterator<TElement> <: Iterator<TElement> {
    private let _source: Iterator<TElement>
    private let _predicate: (TElement) -> Bool

    public init(source: Iterator<TElement>, predicate: (TElement) -> Bool) {
        this._source = source
        this._predicate = predicate
    }

    public func next(): Option<TElement> {
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

