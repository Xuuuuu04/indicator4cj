# Package asset

`asset` 包负责金融历史数据的摄取、转换与仓储管理。

## 核心组件

1. **Snapshot (快照):**
   - 定义了标准化的 K 线数据结构：`Open`, `High`, `Low`, `Close`, `AdjClose`, `Volume`, `Date`。
   - 提供快捷视图转换（如 `SnapshotsAsClosings`）将快照流转换为单一数值流。

2. **Repository (仓储接口):**
   - `InMemoryRepository`: 适用于轻量级测试的内存仓储。
   - `FileSystemRepository`: 基于 CSV 文件的本地文件仓储。
   - `TiingoRepository`: 支持从 Tiingo API 实时/历史数据获取（需要有效的 Token）。
   - `SQLRepository`: 定义了数据库持久化接口。

3. **同步工具 (Sync):**
   - 支持不同 Repository 之间的数据增量同步，方便建立本地镜像。
