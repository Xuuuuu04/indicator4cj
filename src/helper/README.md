# Package helper

`helper` 包是 `indicator4cj` 的底层基石，提供了一套针对 `Iterator<T>` 优化的流式计算工具集，以及反射驱动的 CSV 解析和报表构建功能。

## 核心功能

1. **流式管道 (Pipelines):**
   - `Map/Apply`: 对流中每个元素进行转换。
   - `Duplicate`: 将单个迭代器复制为多个独立副本，支持多路径计算。
   - `Operate/Operate3`: 多流合并运算。
   - `Shift/Skip`: 实现时间序列的位移与对齐。
   - `Window`: 滑动窗口切片支持。

2. **反射驱动的 CSV 解析:**
   - 自动映射：基于仓颉反射机制，将 CSV 列自动填充至 Class/Struct 字段。
   - 格式支持：支持自定义日期格式、引号包裹及无头文件模式。

3. **报表系统 (Report System):**
   - 提供抽象的 `Report` 接口。
   - 支持数值列 (`NumericReportColumn`) 和注解列 (`AnnotationReportColumn`)。
   - 为回测结果的格式化输出提供底层支持。

4. **数学辅助:**
   - 高精度舍入 (`RoundDigit`)。
   - 移动求和/标准差。
   - 序列生成与统计函数。
