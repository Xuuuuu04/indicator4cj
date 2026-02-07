# indicator4cj - 项目体检

最后复核：2026-02-05

## 状态
- 状态标签：reference
- 定位：仓颉（Cangjie）金融技术分析与回测组件库；对标 `cinar/indicator v2` 并做回归验证。

## 架构速览
- 构建工具：`cjpm`（配置：`cjpm.toml`）
- 可执行入口：
  - `indicator-backtest`（`cmd/backtest`）
  - `indicator-sync`（`cmd/sync`）
  - `indicator-mcp`（`cmd/mcp`）
- 模块：`src/asset`、`src/backtest`、`src/strategy`、`src/trend/momentum/volatility/volume/valuation` 等
- 文档：`doc/design.md`、`doc/feature_api.md`、`doc/migration_status.md`

## 当前实现亮点
- 工程量与回归强：README 标注 `cjpm test` 374/374 通过。
- 体系完整：指标 + 策略 + 回测 + 报表 + 数据摄取层，结构清晰。

## 风险与建议
- 若作为作品集主打：建议在 `doc/design.md` 基础上再加一页“典型回测案例”（输入数据 → 策略 → 报表截图/输出）以便面试 5 分钟讲清楚。

