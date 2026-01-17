package indicator4cj.helper

/**
 * applyIter 对迭代器每个元素应用映射函数
 *
 * 等价于 Go 版本的 Apply。对迭代器中的每个元素应用指定的映射函数，
 * 返回包含映射结果的新迭代器。
 *
 * @param iter 源迭代器
 * @param mapper 映射函数，接收一个元素并返回转换后的值
 * @return 映射后的迭代器
 */
public func applyIter<TElement>(iter: Iterator<TElement>, mapper: (TElement) -> TElement): Iterator<TElement> {
    return mapIter(iter, mapper)
}

/**
 * apply Go 版本兼容函数
 *
 * 与 applyIter 功能完全相同，提供此函数是为了与 Go 版本保持命名兼容。
 *
 * @param iter 源迭代器
 * @param mapper 映射函数，接收一个元素并返回转换后的值
 * @return 映射后的迭代器
 */
public func apply<TElement>(iter: Iterator<TElement>, mapper: (TElement) -> TElement): Iterator<TElement> {
    return applyIter(iter, mapper)
}

