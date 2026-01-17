package indicator4cj.helper

// skip：跳过前 count 个元素。
public func skip<TElement>(iter: Iterator<TElement>, count: Int64): Iterator<TElement> {
    var remaining = count
    while (remaining > 0) {
        match (iter.next()) {
            case Some(_) => remaining -= 1
            case None => return EmptyIterator<TElement>()
        }
    }
    return iter
}

// 空迭代器
public class EmptyIterator<TElement> <: Iterator<TElement> {
    public func next(): Option<TElement> { return None }
}

