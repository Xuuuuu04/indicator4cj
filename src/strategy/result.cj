package indicator4cj.strategy

// 修改为 class 以支持反射填充 (CSV)。
public class Result {
    public var Action: Int64
    public init() { this.Action = 0 }
    public init(action: Int64) { this.Action = action }
}
