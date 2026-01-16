package indicator4cj.helper

// Ring：固定容量环形缓冲。
public class Ring<TElement> {
    private let _buffer: Array<Option<TElement>>
    private let _capacity: Int64
    private var _begin: Int64 = 0
    private var _end: Int64 = 0
    private var _empty: Bool = true

    public init(size: Int64) {
        this._capacity = size
        this._buffer = Array<Option<TElement>>(size, { _ => None<TElement> })
    }

    // Put 插入并返回被覆盖的旧值（若无旧值则返回 None）。
    public func Put(value: TElement): Option<TElement> {
        let old = _buffer[_end]
        if (IsFull()) {
            _begin = nextIndex(_begin)
        }
        _buffer[_end] = Some(value)
        _end = nextIndex(_end)
        _empty = false
        return old
    }

    // Get 获取当前最早元素；空返回 None。
    public func Get(): Option<TElement> {
        if (_empty) {
            return None<TElement>
        }
        let v = _buffer[_begin]
        _buffer[_begin] = None<TElement>
        _begin = nextIndex(_begin)
        if (_begin == _end) {
            _empty = true
        }
        return v
    }

    public func At(index: Int64): TElement {
        return _buffer[(_begin + index) % _capacity].getOrThrow()
    }

    public func IsEmpty(): Bool {
        return _empty
    }

    public func IsFull(): Bool {
        return (!_empty) && (_end == _begin)
    }

    private func nextIndex(i: Int64): Int64 {
        return (i + 1) % _capacity
    }
}

