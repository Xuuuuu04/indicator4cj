package indicator4cj.helper

// Ring：固定容量环形缓冲。
public class Ring<T> {
    private let buffer: Array<Option<T>>
    private let capacity: Int64
    private var begin: Int64 = 0
    private var end: Int64 = 0
    private var empty: Bool = true

    public init(size: Int64) {
        this.capacity = size
        this.buffer = Array<Option<T>>(size, { _ => None<T> })
    }

    // Put 插入并返回被覆盖的旧值（若无旧值则返回 None）。
    public func Put(value: T): Option<T> {
        let old = buffer[end]
        if (IsFull()) {
            begin = nextIndex(begin)
        }
        buffer[end] = Some(value)
        end = nextIndex(end)
        empty = false
        return old
    }

    // Get 获取当前最早元素；空返回 None。
    public func Get(): Option<T> {
        if (empty) {
            return None<T>
        }
        let v = buffer[begin]
        buffer[begin] = None<T>
        begin = nextIndex(begin)
        if (begin == end) {
            empty = true
        }
        return v
    }

    public func At(index: Int64): T {
        return buffer[(begin + index) % capacity].getOrThrow()
    }

    public func IsEmpty(): Bool {
        return empty
    }

    public func IsFull(): Bool {
        return (!empty) && (end == begin)
    }

    private func nextIndex(i: Int64): Int64 {
        return (i + 1) % capacity
    }
}

