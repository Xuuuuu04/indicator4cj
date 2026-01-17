package indicator4cj.helper

/**
 * operate 二元操作，任一迭代器耗尽即结束
 *
 * 对两个迭代器对应位置的元素进行任意二元操作。
 *
 * @param left 第一个迭代器（左操作数）
 * @param right 第二个迭代器（右操作数）
 * @param operation 二元操作函数
 * @return 操作结果迭代器
 */
public func operate<A, B, R>(
    left: Iterator<A>,
    right: Iterator<B>,
    operation: (A, B) -> R
): Iterator<R> {
    return OperateIterator<A, B, R>(left, right, operation)
}

public class OperateIterator<A, B, R> <: Iterator<R> {
    private let _left: Iterator<A>
    private let _right: Iterator<B>
    private let _operation: (A, B) -> R

    public init(left: Iterator<A>, right: Iterator<B>, operation: (A, B) -> R) {
        this._left = left
        this._right = right
        this._operation = operation
    }

    public func next(): Option<R> {
        match (_left.next()) {
            case Some(leftValue) =>
                match (_right.next()) {
                    case Some(rightValue) => return Some(_operation(leftValue, rightValue))
                    case None => return None
                }
            case None => return None
        }
    }
}

