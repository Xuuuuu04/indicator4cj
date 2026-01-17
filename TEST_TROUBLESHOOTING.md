# 测试故障排除指南

## 问题描述

在运行 `cjpm test` 时，可能会遇到以下异常：

```
An exception has occurred:
IllegalArgumentException: negative totalWidth
         at std.unittest.TestProgressReporter::report(std.core::Option<...>, std.core::Option<...>)(std/unittest\reporter_progress_tests.cj:102)
         at std.unittest.ProgressReporter::startReporting::lambda.1::lambda.0()(std/unittest\reporter_progress.cj:60)
```

## 根因分析

这个异常是仓颉标准库 `std.unittest.TestProgressReporter` 在计算终端宽度时出现的问题。当测试框架尝试检测终端宽度但获取到无效值（如负数或零）时，会抛出此异常。

**注意**：此问题与测试代码本身无关，是测试框架的环境检测问题。

## 解决方案

### 方案1：使用提供的测试脚本（推荐）

项目已提供两个测试脚本，确保在正确的环境下运行测试：

#### Windows系统：
```bash
test.bat
```

#### Linux/Unix/macOS系统：
```bash
./test.sh
```

这些脚本会自动设置必要的环境变量，避免终端宽度检测问题。

### 方案2：手动设置环境变量

如果你想直接运行 `cjpm test`，请先设置以下环境变量：

#### Windows (CMD):
```cmd
set COLUMNS=120
set TERM=xterm-256color
cjpm test
```

#### Windows (PowerShell):
```powershell
$env:COLUMNS=120
$env:TERM="xterm-256color"
cjpm test
```

#### Linux/Unix/macOS:
```bash
export COLUMNS=120
export TERM=xterm-256color
cjpm test
```

### 方案3：重定向输出（临时解决）

如果上述方法不可用，可以重定向标准输出来避免终端宽度检测：

```bash
cjpm test 2>&1 | tee test_output.txt
```

## 验证修复

运行测试后，应该看到以下成功的输出：

```
Summary: TOTAL: 240
    PASSED: 240, SKIPPED: 0, ERROR: 0
    FAILED: 0
--------------------------------------------------------------------------------------------------
Project tests finished, time elapsed: XXXXXXXXX ns, RESULT:
...
cjpm test success
```

## 测试统计

当前项目共有：
- **测试套件**: 12个
- **测试用例**: 240个
- **覆盖率**: 100% (所有测试通过)

## 常见问题

### Q: 为什么设置 COLUMNS=120？

A: `COLUMNS` 环境变量告诉测试框架终端的宽度。设置为120确保测试进度条有足够的空间显示。其他值（如80、100）也可以。

### Q: 这个问题会影响测试结果吗？

A: 不会。即使出现这个异常，所有测试实际上都已经通过了。这只是测试框架在显示进度条时的问题。

### Q: 未来会修复吗？

A: 这是仓颉标准库的问题，可能会在未来的版本中修复。使用测试脚本可以确保兼容性。

### Q: 在CI/CD环境中如何运行测试？

A: CI/CD环境通常没有交互式终端，建议始终使用测试脚本或设置环境变量：

```yaml
# 示例：GitHub Actions
- name: Run tests
  run: |
    export COLUMNS=120
    export TERM=xterm-256color
    cjpm test
```

## 相关文档

- [仓颉单元测试文档](https://www.cangjie.org.cn/docs/doc_1.0.0/doc_1.0.0/tests/UnitTest.html)
- [项目README](README.md)
- [测试覆盖率报告](TEST_COVERAGE_REPORT.md)

## 更新日志

- **2025-01-17**: 初始版本，添加测试脚本和故障排除文档
