package indicator4cj.helper

/**
 * Ring 固定容量环形缓冲区
 *
 * 实现一个固定大小的环形队列，支持高效的插入和删除操作。
 *
 * ### 特性
 * - 固定容量：初始化后大小不可变
 * - 覆盖策略：满时插入会覆盖最旧元素
 * - O(1)操作：插入和删除均为常数时间
 * - 循环利用：使用模运算实现循环索引
 *
 * ### 适用场景
 * - 实现滑动窗口算法
 * - 保存最近N个历史数据
 * - 内存受限环境下的固定大小缓冲
 *
 * ### 示例
 * ```cangjie
 * let ring = Ring<Int64>(3)
 * ring.put(1)  // [1]
 * ring.put(2)  // [1, 2]
 * ring.put(3)  // [1, 2, 3]
 * ring.put(4)  // [2, 3, 4] (1被覆盖)
 * let first = ring.get()  // 返回Some(2), 队列变为[3, 4]
 * ```
 *
 * @param TElement 元素类型
 */
public class Ring<TElement> {
    private let _buffer: Array<Option<TElement>>
    private let _capacity: Int64
    private var _begin: Int64 = 0
    private var _end: Int64 = 0
    private var _empty: Bool = true

    /**
     * 构造函数
     *
     * @param size 环形缓冲区容量
     */
    public init(size: Int64) {
        this._capacity = size
        this._buffer = Array<Option<TElement>>(size, { _ => None<TElement> })
    }

    /**
     * put 插入元素
     *
     * 在环形缓冲区尾部插入元素，如果缓冲区已满则覆盖最旧的元素。
     *
     * @param value 要插入的元素
     * @return 被覆盖的旧元素（如果缓冲区已满）或None
     */
    public func put(value: TElement): Option<TElement> {
        let old = _buffer[_end]
        if (isFull()) {
            _begin = nextIndex(_begin)
        }
        _buffer[_end] = Some(value)
        _end = nextIndex(_end)
        _empty = false
        return old
    }

    /**
     * get 获取并移除最早元素
     *
     * 从环形缓冲区头部获取并移除最旧的元素。
     *
     * @return 最旧元素的Option，缓冲区为空时返回None
     */
    public func get(): Option<TElement> {
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

    /**
     * at 访问指定索引的元素（不移除）
     *
     * 访问环形缓冲区中指定位置的元素，0表示最旧的元素。
     * 索引必须在有效范围内，否则会抛出异常。
     *
     * @param index 元素索引（从0开始）
     * @return 指定位置的元素
     */
    public func at(index: Int64): TElement {
        return _buffer[(_begin + index) % _capacity].getOrThrow()
    }

    /**
     * isEmpty 判断缓冲区是否为空
     *
     * @return 缓冲区为空时返回true
     */
    public func isEmpty(): Bool {
        return _empty
    }

    /**
     * isFull 判断缓冲区是否已满
     *
     * @return 缓冲区已满时返回true
     */
    public func isFull(): Bool {
        return (!_empty) && (_end == _begin)
    }

    /**
     * nextIndex 计算下一个循环索引
     *
     * 使用模运算实现循环索引，当索引达到容量时自动回到0。
     *
     * @param i 当前索引
     * @return 下一个索引
     */
    private func nextIndex(i: Int64): Int64 {
        return (i + 1) % _capacity
    }
}

