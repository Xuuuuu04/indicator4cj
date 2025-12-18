package indicator4cj.helper

// Map：对迭代器逐元素映射，保持与 Go 版 Map 语义一致。
public func mapIter<F, T>(iter: Iterator<F>, mapper: (F) -> T): Iterator<T> {
    return MapIterator<F, T>(iter, mapper)
}

// Go 同名兼容导出。
public func Map<F, T>(iter: Iterator<F>, mapper: (F) -> T): Iterator<T> {
    return mapIter(iter, mapper)
}

// 内部迭代器实现，避免依赖扩展。
public class MapIterator<F, T> <: Iterator<T> {
    private let source: Iterator<F>
    private let mapper: (F) -> T

    public init(source: Iterator<F>, mapper: (F) -> T) {
        this.source = source
        this.mapper = mapper
    }

    public func next(): Option<T> {
        match (source.next()) {
            case Some(v) => return Some(mapper(v))
            case None => return None
        }
    }
}

