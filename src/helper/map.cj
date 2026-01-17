package indicator4cj.helper

// mapIterator 映射迭代器，对源迭代器的每个元素应用映射函数
public class MapIterator<TFrom, TTo> <: Iterator<TTo> {
    private let _source: Iterator<TFrom>
    private let _mapper: (TFrom) -> TTo

    public init(source: Iterator<TFrom>, mapper: (TFrom) -> TTo) {
        this._source = source
        this._mapper = mapper
    }

    public func next(): Option<TTo> {
        match (_source.next()) {
            case Some(v) => return Some(_mapper(v))
            case None => return None
        }
    }
}

// mapIter 创建映射迭代器
public func mapIter<TFrom, TTo>(iter: Iterator<TFrom>, mapper: (TFrom) -> TTo): Iterator<TTo> {
    return MapIterator<TFrom, TTo>(iter, mapper)
}

// map 公共 API 函数（保持向后兼容）
public func map<TFrom, TTo>(iter: Iterator<TFrom>, mapper: (TFrom) -> TTo): Iterator<TTo> {
    return mapIter(iter, mapper)
}

