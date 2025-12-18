package indicator4cj.helper

// Operate3：三元操作，任一耗尽即结束。
public func Operate3<A, B, C, R>(a: Iterator<A>, b: Iterator<B>, c: Iterator<C>, op: (A, B, C) -> R): Iterator<R> {
    return Operate3Iterator<A, B, C, R>(a, b, c, op)
}

public class Operate3Iterator<A, B, C, R> <: Iterator<R> {
    private let a: Iterator<A>
    private let b: Iterator<B>
    private let c: Iterator<C>
    private let op: (A, B, C) -> R

    public init(a: Iterator<A>, b: Iterator<B>, c: Iterator<C>, op: (A, B, C) -> R) {
        this.a = a
        this.b = b
        this.c = c
        this.op = op
    }

    public func next(): Option<R> {
        match (a.next()) {
            case Some(av) =>
                match (b.next()) {
                    case Some(bv) =>
                        match (c.next()) {
                            case Some(cv) => return Some(op(av, bv, cv))
                            case None => return None
                        }
                    case None => return None
                }
            case None => return None
        }
    }
}

