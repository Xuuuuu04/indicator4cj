package indicator4cj.helper

// pipe：将源迭代器内容写入目标“通道”（通过回调模拟）。
public func pipe<T>(source: Iterator<T>, sink: (T) -> Unit) {
    while (true) {
        match (source.next()) {
            case Some(v) => sink(v)
            case None => break
        }
    }
}

