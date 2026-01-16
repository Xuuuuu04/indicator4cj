package indicator4cj.helper

// Operate3：三元操作，任一耗尽即结束。
public func Operate3<A, B, C, R>(a: Iterator<A>, b: Iterator<B>, c: Iterator<C>, op: (A, B, C) -> R): Iterator<R> {
    return Operate3Iterator<A, B, C, R>(a, b, c, op)
}

public class Operate3Iterator<A, B, C, R> <: Iterator<R> {
    private let _a: Iterator<A>
    private let _b: Iterator<B>
    private let _c: Iterator<C>
    private let _op: (A, B, C) -> R

    public init(a: Iterator<A>, b: Iterator<B>, c: Iterator<C>, op: (A, B, C) -> R) {
        this._a = a
        this._b = b
        this._c = c
        this._op = op
    }

    public func next(): Option<R> {
        match (_a.next()) {
            case Some(av) =>
                match (_b.next()) {
                    case Some(bv) =>
                        match (_c.next()) {
                            case Some(cv) => return Some(_op(av, bv, cv))
                            case None => return None
                        }
                    case None => return None
                }
            case None => return None
        }
    }
}

