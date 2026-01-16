package indicator4cj.helper

// Operate：二元操作，任一耗尽即结束。
public func Operate<A, B, R>(a: Iterator<A>, b: Iterator<B>, op: (A, B) -> R): Iterator<R> {
    return OperateIterator<A, B, R>(a, b, op)
}

public class OperateIterator<A, B, R> <: Iterator<R> {
    private let _a: Iterator<A>
    private let _b: Iterator<B>
    private let _op: (A, B) -> R

    public init(a: Iterator<A>, b: Iterator<B>, op: (A, B) -> R) {
        this._a = a
        this._b = b
        this._op = op
    }

    public func next(): Option<R> {
        match (_a.next()) {
            case Some(av) =>
                match (_b.next()) {
                    case Some(bv) => return Some(_op(av, bv))
                    case None => return None
                }
            case None => return None
        }
    }
}

