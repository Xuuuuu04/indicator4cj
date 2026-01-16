# Package trend

`trend` 包包含了所有与价格趋势相关的技术指标。

## 包含指标 (部分列举)
- **移动平均线:** SMA, EMA, WMA, HMA, TRIMA, DEMA, TEMA, SMMA。
- **交叉类:** MACD, APO, TRIX。
- **通道类:** Envelope, Alligator。
- **其他:** Aroon, CCI, KAMA, ROC, TSI, VWMA, KDJ。

所有指标均支持流式计算，并严格对齐 `IdlePeriod`（预热期）逻辑。
