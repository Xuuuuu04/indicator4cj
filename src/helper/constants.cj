package indicator4cj.helper

/**
 * 仓颉技术指标库 - 全局常量定义
 *
 * 定义所有技术指标中使用的魔法数字常量，提高代码可维护性。
 */

// ========== RSI 相关常量 ==========
/**
 * RSI缩放因子
 * RSI公式: RSI = 100 - 100 / (1 + RS)
 */
public const RSI_SCALE_FACTOR: Float64 = 100.0

/**
 * RSI默认周期
 * 常用值为14周期
 */
public const RSI_DEFAULT_PERIOD: Int64 = 14

// ========== 布林带相关常量 ==========
/**
 * 布林带标准差倍数
 * 上轨 = 中轨 + 倍数 * 标准差
 * 下轨 = 中轨 - 倍数 * 标准差
 * 标准值为2.0
 */
public const BOLLINGER_BANDS_MULTIPLIER: Float64 = 2.0

/**
 * 布林带默认周期
 * 常用值为20周期
 */
public const BOLLINGER_BANDS_DEFAULT_PERIOD: Int64 = 20

// ========== EMA 相关常量 ==========
/**
 * EMA默认平滑系数
 * 用于计算EMA的权重: alpha = smoothing / (period + 1)
 * 标准值为2.0
 */
public const EMA_DEFAULT_SMOOTHING: Float64 = 2.0

/**
 * EMA默认周期
 * 常用值为20周期
 */
public const EMA_DEFAULT_PERIOD: Int64 = 20

// ========== MACD 相关常量 ==========
/**
 * MACD快速EMA默认周期
 * 标准值为12周期
 */
public const MACD_DEFAULT_FAST_PERIOD: Int64 = 12

/**
 * MACD慢速EMA默认周期
 * 标准值为26周期
 */
public const MACD_DEFAULT_SLOW_PERIOD: Int64 = 26

/**
 * MACD信号线EMA默认周期
 * 标准值为9周期
 */
public const MACD_DEFAULT_SIGNAL_PERIOD: Int64 = 9

// ========== 移动平均默认周期 ==========
/**
 * 简单移动平均(SMA)默认周期
 * 常用值为50周期
 */
public const MA_DEFAULT_PERIOD: Int64 = 50

/**
 * 短期移动平均周期
 * 常用值为5或10周期
 */
public const MA_SHORT_PERIOD: Int64 = 5

/**
 * 中期移动平均周期
 * 常用值为20周期
 */
public const MA_MEDIUM_PERIOD: Int64 = 20

/**
 * 长期移动平均周期
 * 常用值为50或200周期
 */
public const MA_LONG_PERIOD: Int64 = 50

// ========== 其他常用常量 ==========
/**
 * 百分比转换因子
 * 用于将小数转换为百分比
 */
public const PERCENTAGE_FACTOR: Float64 = 100.0

/**
 * 布林带宽度计算的分母
 * 中轨通常乘以2来标准化宽度
 */
public const BOLLINGER_BANDS_DIVISOR: Float64 = 2.0

/**
 * 唐奇安通道默认周期
 * 常用值为20周期
 */
public const DONCHIAN_CHANNEL_DEFAULT_PERIOD: Int64 = 20

/**
 * ATR默认周期
 * 常用值为14周期
 */
public const ATR_DEFAULT_PERIOD: Int64 = 14
