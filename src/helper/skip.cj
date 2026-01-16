package indicator4cj.helper

// Skip：跳过前 count 个元素。
public func Skip<T>(iter: Iterator<T>, count: Int64): Iterator<T> {
    var remaining = count
    while (remaining > 0) {
        match (iter.next()) {
            case Some(_) => remaining -= 1
            case None => return EmptyIterator<T>()
        }
    }
    return iter
}

// 空迭代器
public class EmptyIterator<T> <: Iterator<T> {
    public func next(): Option<T> { return None }
}

