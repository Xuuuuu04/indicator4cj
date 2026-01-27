# indicator4cj 迁移对比与完备性审计

> **版本**: v1.0.0
> **仓颉版本**: 1.0.4
> **对照基准**: 本仓库内的 Go 版本 `indicator/`（cinar/indicator v2）
> **审计日期**: 2026-01-27
> **回归结果**: `cjpm test` 374/374 通过，`cjpm build` 通过

---

## 1. 迁移范围说明

本项目的目标是将 Go 版 `cinar/indicator`（v2）中的 **技术指标、策略、回测与报告** 迁移到仓颉生态，并保留一致的核心语义与默认参数。

为便于复核，本仓库同时包含：
- Go 原版（对照基准）：`indicator/`
- 仓颉迁移版（交付产物）：`indicator4cj/`

---

## 2. 与 Go 原版的功能对比（摘要）

| 模块 | 对比结论 | 说明 |
|---|---|---|
| helper（流式/工具） | ✅ 高一致 | 以 `Iterator<T>` 构建 pull-based 流式管线，覆盖原版大多数工具算子；并保留 golden test 对齐关键 HTML/Report 输出。 |
| trend/momentum/volatility/volume/valuation（指标） | ✅ 高一致 | 指标实现与默认参数对齐；以测试数据集与单测覆盖为主（并非对每个指标做跨语言逐点 golden）。 |
| strategy（策略框架） | ✅ 高一致 | 基础策略、组合策略（and/or/majority/split）、装饰器策略（止损/反向/无损）等行为可回归。 |
| 策略集合口径（默认/扩展） | ✅ 已对齐 | 默认策略集合按 Go 口径对齐；额外策略归入扩展集合，通过开关显式启用。 |
| backtest（回测引擎） | ✅ 高一致 | 支持多资产/多策略运行、交易结果汇总、HTML 报告生成；关键 HTML 产物通过 golden test 回归。 |
| asset（仓储/同步/数据源） | ⚠️ 一致但受限 | FileSystem/InMemory/SQL/Tiingo 均已迁移；Tiingo 受数据源语义限制，不支持 `append`（与 Go 原版一致）。 |
| MCP（stdio tools） | ⚠️ 子集实现 | 覆盖 JSON-RPC framing、tools/list 与 tools/call（含参数校验与错误码）；未实现 MCP 的 resources/prompts/sampling 等高级能力。 |
| CLI（backtest/sync/mcp） | ⚠️ 工程形态受限 | `cmd/` 下入口已迁移且参与编译/测试；当前工程以静态库形态组织，未提供“一键生成 exe 并 cjpm run 直接运行”的交付方式。 |

---

## 3. 已知差异与限制（如实陈述）

1. **可执行产物交付形态**
   - 当前 `indicator4cj` 以静态库为主，便于作为依赖被其他仓颉工程引用。
   - `cmd/backtest`、`cmd/sync`、`cmd/mcp` 的入口代码已迁移，但未将工程组织成以可执行文件为主的工作空间交付，因此默认 `cjpm run` 不会生成 `target/release/bin/*.exe`。

2. **跨语言逐点对齐范围**
   - 目前的验证以迁移后的单元测试、测试数据集、以及关键 HTML/Report golden tests 为主。
   - 尚未引入“自动调用 Go 版本并对每个指标逐点对比输出”的跨语言集成测试（可作为后续增强项）。

3. **MCP 能力范围**
   - 当前实现聚焦 tools 能力（列举策略、回测、基于仓储回测）与 JSON-RPC 错误鲁棒性。
   - resources/prompts/sampling、取消/进度等能力未实现。

4. **外部数据源约束**
   - Tiingo 的数据写入（append）在语义上不被支持：`TiingoRepository.append()` 抛出异常（与 Go 原版一致）。

---

## 4. 推荐验收口径

如果以“功能迁移完成且可回归”为验收标准：
- ✅ 本版本已达到：`cjpm test` 全绿 + 关键行为对齐（策略集合、报告、MCP schema、CLI 参数解析）。

如果以“可执行工具链完整交付（直接运行 backtest/sync/mcp exe）”为验收标准：
- ⚠️ 仍需要一次工程结构升级（以 workspace/可执行产物为中心进行交付）。

