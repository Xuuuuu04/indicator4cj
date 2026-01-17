package indicator4cj.strategy

/**
 * Result 策略执行结果
 *
 * 表示策略在某个时间点的执行结果（交易动作）。
 * 使用class类型以支持CSV反射填充。
 *
 * ### 字段说明
 * - action: 交易动作（整数表示）
 *   - 1: 买入（BUY）
 *   - -1: 卖出（SELL）
 *   - 0: 持有（HOLD）
 *
 * ### 使用场景
 * - CSV导出策略结果
 * - 回测报告生成
 * - 数据持久化
 *
 * ### 示例
 * ```cangjie
 * let r1 = Result()           // 默认HOLD
 * let r2 = Result(1)          // BUY
 * let r3 = Result(-1)         // SELL
 * ```
 */
public class Result {
    /**
     * action 交易动作
     *
     * 整数表示：1=BUY, -1=SELL, 0=HOLD
     */
    public var action: Int64

    /**
     * 默认构造函数
     *
     * 创建一个HOLD状态的空结果（用于CSV反射填充）
     */
    public init() {
        this.action = 0
    }

    /**
     * 完整构造函数
     *
     * @param action 交易动作（1=BUY, -1=SELL, 0=HOLD）
     */
    public init(action: Int64) {
        this.action = action
    }
}
