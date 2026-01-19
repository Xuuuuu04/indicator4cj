package indicator4cj.helper

/**
 * buffered 带缓冲的迭代器包装器
 *
 * 在迭代模型下，缓冲无阻塞语义，仅作为直通包装。
 * 保留签名与Go版本一致，便于代码迁移。
 *
 * ### 当前实现
 * 直接返回原迭代器，不进行实际缓冲处理。
 * 未来可扩展为预取（prefetch）实现。
 *
 * @param iter 源迭代器
 * @param _bufferSize 缓冲区大小（当前未使用，保留参数以兼容签名）
 * @return 原迭代器（直通）
 */
public func buffered<T>(iter: Iterator<T>, _bufferSize: Int64): Iterator<T> {
    // 可按需扩展为预取，当前保持直通。
    return iter
}


