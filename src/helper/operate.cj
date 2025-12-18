package indicator4cj.helper

// Operate：二元操作，任一耗尽即结束。
public func Operate<A, B, R>(a: Iterator<A>, b: Iterator<B>, op: (A, B) -> R): Iterator<R> {
    return OperateIterator<A, B, R>(a, b, op)
}

public class OperateIterator<A, B, R> <: Iterator<R> {
    private let a: Iterator<A>
    private let b: Iterator<B>
    private let op: (A, B) -> R

    public init(a: Iterator<A>, b: Iterator<B>, op: (A, B) -> R) {
        this.a = a
        this.b = b
        this.op = op
    }

    public func next(): Option<R> {
        match (a.next()) {
            case Some(av) =>
                match (b.next()) {
                    case Some(bv) => return Some(op(av, bv))
                    case None => return None
                }
            case None => return None
        }
    }
}

