package indicator4cj.helper

/**
 * Closeable 可关闭资源接口
 *
 * 简易可关闭接口，兼容Go io.Closer语义
 */
public interface Closeable {
    /**
     * close 关闭资源
     */
    func close(): Unit
}

/**
 * closeAndLogError 尝试关闭资源并忽略异常
 *
 * @param closer 可关闭资源
 * @param message 错误消息（当前未使用，保留参数以兼容签名）
 */
public func closeAndLogError(closer: Closeable, message: String): Unit {
    closeAndLogErrorWithLogger(closer, message, None)
}

/**
 * closeAndLogErrorWithLogger 带日志的关闭函数
 *
 * 可选传入日志信息，当前实现忽略日志参数，保持不抛异常。
 * 用于资源清理，确保即使关闭失败也不影响程序流程。
 *
 * @param closer 可关闭资源
 * @param message 错误消息（当前未使用，保留参数以兼容签名）
 * @param logger 日志信息（当前未使用，保留参数以兼容签名）
 */
public func closeAndLogErrorWithLogger(closer: Closeable, message: String, logger: Option<String>): Unit {
    // 参数引用以消除未使用警告
    let _ = message
    let _ = logger
    try {
        closer.close()
    } catch (_) {
        // 忽略关闭异常，仿Go slog.Error但不输出
    }
}

/**
 * DummyCloser 测试用的虚拟可关闭对象
 *
 * 简单的内存型Closeable，用于单元测试
 */
public class DummyCloser <: Closeable {
    /**
     * closedCount 关闭计数器
     *
     * 每次调用close()时递增，用于测试验证
     */
    public var closedCount: Int64 = 0

    /**
     * close 增加关闭计数
     */
    public func close(): Unit {
        closedCount += 1
    }
}


