package indicator4cj.helper

/**
 * MapIterator 映射迭代器
 *
 * 对源迭代器的每个元素应用映射函数，转换元素类型。
 * 这是一个惰性求值的迭代器包装器，用于实现函数式编程中的map操作。
 *
 * ### 惰性求值
 * 只有在调用next()时才会应用映射函数，不会提前处理所有元素。
 * 这种设计使得链式操作更加高效，避免创建中间集合。
 *
 * ### 类型转换
 * 支持源类型和目标类型不同，例如从Int64转换为Float64。
 *
 * @param TFrom 源元素类型
 * @param TTo 目标元素类型
 */
public class MapIterator<TFrom, TTo> <: Iterator<TTo> {
    /**
     * _source 源迭代器
     */
    private let _source: Iterator<TFrom>

    /**
     * _mapper 映射函数
     *
     * 接收源元素，返回转换后的元素
     */
    private let _mapper: (TFrom) -> TTo

    /**
     * 构造函数
     *
     * @param source 源迭代器
     * @param mapper 映射函数
     */
    public init(source: Iterator<TFrom>, mapper: (TFrom) -> TTo) {
        this._source = source
        this._mapper = mapper
    }

    /**
     * next 返回下一个映射后的元素
     *
     * @return 映射后元素的Option，源迭代器结束时返回None
     */
    public func next(): Option<TTo> {
        match (_source.next()) {
            case Some(v) => return Some(_mapper(v))
            case None => return None
        }
    }
}

/**
 * mapIter 创建映射迭代器（内部API）
 *
 * @param iter 源迭代器
 * @param mapper 映射函数
 * @return 映射后的迭代器
 */
public func mapIter<TFrom, TTo>(iter: Iterator<TFrom>, mapper: (TFrom) -> TTo): Iterator<TTo> {
    return MapIterator<TFrom, TTo>(iter, mapper)
}

/**
 * map 对迭代器中的每个元素应用转换函数
 *
 * 这是一个惰性求值函数，不会立即处理所有元素，
 * 而是在迭代时按需计算。
 *
 * ### 示例
 * ```cangjie
 * let numbers = [1, 2, 3, 4, 5]
 * let doubled = map(numbers.iterator(), func(x: Int64): Int64 { x * 2 })
 * // 结果: [2, 4, 6, 8, 10]
 *
 * let names = ["alice", "bob", "charlie"]
 * let uppercased = map(names.iterator(), func(s: String): String { s.uppercase() })
 * // 结果: ["ALICE", "BOB", "CHARLIE"]
 * ```
 *
 * @param iter 输入迭代器
 * @param mapper 转换函数，接收原始元素返回转换后的元素
 * @return 转换后的元素迭代器
 */
public func map<TFrom, TTo>(iter: Iterator<TFrom>, mapper: (TFrom) -> TTo): Iterator<TTo> {
    return mapIter(iter, mapper)
}
