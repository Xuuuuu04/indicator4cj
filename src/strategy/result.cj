package indicator4cj.strategy

// 修改为 class 以支持反射填充 (CSV)。
public class Result {
    // 动作
    public var action: Int64
    public init() {
        this.action = 0
    }

    public init(action: Int64) {
        this.action = action
    }
}
