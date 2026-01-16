package indicator4cj.helper

// 简易可关闭接口，兼容 Go io.closer 语义。
public interface Closeable {
    func close(): Unit
}

// closeAndLogError：尝试关闭，忽略异常。message 保留以兼容签名。
public func closeAndLogError(closer: Closeable, message: String): Unit {
    closeAndLogErrorWithLogger(closer, message, None)
}

// closeAndLogErrorWithLogger：可选传入日志信息，当前实现忽略日志，保持不抛异常。
public func closeAndLogErrorWithLogger(closer: Closeable, _: String, _: Option<String>): Unit {
    try {
        closer.close()
    } catch (_) {
        // 忽略关闭异常，仿 Go slog.Error 但不输出
    }
}

// 简单的内存型 Closeable，用于测试。
public class DummyCloser <: Closeable {
    // 计数
    public var closedCount: Int64 = 0

    public func close(): Unit {
        closedCount += 1
    }
}

