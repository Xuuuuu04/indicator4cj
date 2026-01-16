# Package test

`test` 包负责 `indicator4cj` 库的全量自动化测试与验证，确保迁移后的仓颉实现与原版 Go 实现（cinar/indicator v2）在逻辑和数值上严格对齐。

## 测试体系结构

1. **单元测试 (Unit Tests):**
   - 针对每个指标、算子和策略的边界情况（空输入、单元素、极值）进行验证。
   - 文件命名：`{feature}_test.cj`。

2. **1:1 对标验证 (Parity Tests):**
   - **机制**：从 Go 参考实现中导出特定参数下的指标计算结果（CSV），作为“真值”。
   - **流程**：在仓颉中加载相同的原始数据，计算后使用 `CheckEquals` 与真值进行逐行对比。
   - **容差**：对于浮点数计算，默认使用 `1e-8` 的 epsilon 容差。

3. **鲁棒性测试 (Robustness Tests):**
   - 专门验证系统在非正常输入（如 Period <= 0, 迭代器提前关闭等）下的行为。

## 测试数据管理

所有测试依赖的 CSV 数据均统一存放在 `src/test/testdata` 目录下，按模块分类：
- `testdata/trend/`: 趋势指标真值。
- `testdata/strategy/`: 策略信号真值。
- `testdata/asset/`: 标准历史行情样本。

## 运行测试

使用标准 `cjpm` 命令运行所有测试：

```shell
cjpm test
```

## 注意事项

- **反射限制**：测试中使用的 DTO（如 `Result`, `Snapshot`）必须使用 `class` 而非 `struct`，以支持 `helper.Csv` 的反射填充。
- **环境依赖**：部分 `tiingo` 相关测试需要网络连接，若环境不具备条件，相关测试用例将报错或跳过。
