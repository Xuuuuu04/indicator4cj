package indicator4cj.helper

// 消费：消费迭代器直至结束。
public func Drain<T>(iter: Iterator<T>): Unit {
    while (true) {
        match (iter.next()) {
            case Some(_) => ()
            case None => break
        }
    }
}

