# [v0.1.0]

## Feature

- **指标与策略对齐 Go**：完成 `cinar/indicator` v2 的仓颉迁移，趋势/动量/波动率/成交量/估值/策略/回测等模块均已实现，并通过 `cjpm test`。
- **数据与测试同步**：`src/test/testdata` 使用上游 CSV，便于交叉验证。
- **仓颉惯用流水线**：Iterator + Duplicate/Map/Shift/Operate，对齐 Channel 语义；显式 Option/Exception 处理。
- **资产与回测支持**：内存/文件/Tiingo 仓库接口，Backtest 提供数据报表与 HTML 报表。

## Known Limitations

- **SQLRepository**：仓颉 std/stdx 暂无通用 DB 驱动，当前为内存实现，待外部 DB/FFI 可用后接入真实 SQL。
- **MCP**：仓颉侧缺少 MCP 客户端实现，目录保留占位。
- **Tiingo 依赖外网与 Token**：未配置或无法联网时相关功能不可用。
- **跨平台路径**：`cjpm.toml` 中 stdx 动态库路径需按本机安装位置调整。

