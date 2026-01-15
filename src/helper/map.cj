package indicator4cj.helper

// MapIterator 映射迭代器，对源迭代器的每个元素应用映射函数
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

// mapIter 创建映射迭代器
public func mapIter<F, T>(iter: Iterator<F>, mapper: (F) -> T): Iterator<T> {
    return MapIterator<F, T>(iter, mapper)
}

// Map 公共 API 函数（保持向后兼容）
public func Map<F, T>(iter: Iterator<F>, mapper: (F) -> T): Iterator<T> {
    return mapIter(iter, mapper)
}

