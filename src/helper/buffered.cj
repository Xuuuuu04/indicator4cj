package indicator4cj.helper

// buffered：返回等价迭代器，保留签名与 Go 版一致。
// 在迭代模型下，缓冲无阻塞语义，仅作为直通包装。
public func buffered<T>(iter: Iterator<T>, _: Int64): Iterator<T> {
    // 可按需扩展为预取，当前保持直通。
    return iter
}

