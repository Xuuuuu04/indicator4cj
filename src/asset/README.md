# Package asset

`asset` 包负责金融历史数据的摄取、转换与仓储管理。

## 核心组件

### 1. Snapshot (资产快照)

定义了标准化的 K 线（OHLCV）数据结构。

#### 数据结构

```cangjie
public class Snapshot <: ToString {
    public var date: DateTime       // 日期时间戳
    public var open: Float64        // 开盘价
    public var high: Float64        // 最高价
    public var low: Float64         // 最低价
    public var close: Float64       // 收盘价
    public var adjClose: Float64    // 调整后收盘价（考虑分红、拆股等）
    public var volume: Float64      // 成交量
}
```

#### 特性

- **CSV 序列化/反序列化**：支持从 CSV 文件自动加载
- **反射填充**：通过反射机制自动填充字段
- **ToString 接口**：便于调试输出

### 2. Repository (仓储接口)

提供统一的数据访问抽象，支持多种数据源。

#### 接口定义

```cangjie
public interface Repository {
    func assets(): ArrayList<String>                        // 获取所有资产名称
    func get(name: String): Option<Iterator<Snapshot>>      // 获取指定资产的全部快照
    func getSince(name: String, date: DateTime): Iterator<Snapshot>  // 获取指定日期后的快照
    func lastDate(name: String): Option<DateTime>           // 获取资产的最新日期
    func append(name: String, snapshots: Iterator<Snapshot>): Unit    // 追加快照数据
}
```

#### 实现类

##### InMemoryRepository (内存仓储)

- **适用场景**：单元测试、快速原型开发
- **特点**：数据存储在内存 HashMap 中，程序结束后数据丢失
- **性能**：访问速度最快，适合小规模数据

```cangjie
public class InMemoryRepository <: Repository {
    // 内部使用 HashMap<String, ArrayList<Snapshot>> 存储
}
```

##### FileSystemRepository (文件系统仓储)

- **适用场景**：本地数据持久化
- **特点**：数据以 CSV 文件形式存储在文件系统
- **优势**：简单可靠，无需数据库依赖

```cangjie
public class FileSystemRepository <: Repository {
    public init(root: String)  // root 为数据目录路径
}
```

##### SQLRepository (SQL 数据库仓储)

- **适用场景**：生产环境、大规模数据存储
- **状态**：已定义标准接口，待集成具体数据库驱动
- **支持**：支持多种数据库方言（MySQL, SQLite 等）

```cangjie
public interface SQLRepository <: Repository {
    func connect(): Option<Exception>           // 建立数据库连接
    func close(): Unit                          // 关闭连接
}
```

### 3. 数据转换工具

#### snapshotsAsClosings

将快照流转换为收盘价流，方便指标计算。

```cangjie
public func snapshotsAsClosings(snapshots: Iterator<Snapshot>): Iterator<Float64>
```

#### 便捷视图转换

- `snapshotsAsClosings`：提取收盘价序列
- `snapshotsAsVolumes`：提取成交量序列
- `snapshotsAsHighs`：提取最高价序列
- `snapshotsAsLows`：提取最低价序列

## 使用示例

### 加载 CSV 数据

```cangjie
import indicator4cj.asset.*
import indicator4cj.helper.*

main() {
    // 从 CSV 文件加载快照数据
    let snaps = loadFromCsv<Snapshot>("testdata/AAPL.csv")

    // 存储到内存仓储
    let repo = InMemoryRepository()
    repo.append("AAPL", snaps)

    // 获取数据
    match (repo.get("AAPL")) {
        case Some(data) => println("成功加载 ${data.count()} 条数据")
        case None => println("资产不存在")
    }
}
```

### 多仓储同步

```cangjie
// 从文件系统仓储同步到内存仓储
let fsRepo = FileSystemRepository("/path/to/data")
let memRepo = InMemoryRepository()

let assets = fsRepo.assets()
for (assetName in assets) {
    match (fsRepo.get(assetName)) {
        case Some(snaps) => memRepo.append(assetName, snaps)
        case None => ()
    }
}
```

## 数据格式要求

### CSV 文件格式

CSV 文件必须包含以下列（列名不区分大小写）：

| 列名 | 类型 | 必需 | 说明 |
|------|------|------|------|
| Date | DateTime | ✅ | 日期时间 |
| Open | Float64 | ✅ | 开盘价 |
| High | Float64 | ✅ | 最高价 |
| Low | Float64 | ✅ | 最低价 |
| Close | Float64 | ✅ | 收盘价 |
| AdjClose | Float64 | ❌ | 调整后收盘价（可选） |
| Volume | Float64 | ✅ | 成交量 |

### CSV 示例

```csv
Date,Open,High,Low,Close,AdjClose,Volume
2024-01-01,150.0,155.0,149.0,153.0,153.0,1000000
2024-01-02,153.0,158.0,152.0,157.0,157.0,1200000
```

## 注意事项

1. **反射字段匹配**：CSV 列名与 Snapshot 字段名必须匹配（忽略大小写）
2. **日期格式**：支持标准 ISO 8601 格式（YYYY-MM-DD）
3. **内存管理**：InMemoryRepository 会占用较多内存，大规模数据建议使用 FileSystemRepository
4. **数据库驱动**：SQLRepository 需要额外安装数据库驱动（如 mysql-driver-cj）
