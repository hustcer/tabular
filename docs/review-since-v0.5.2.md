# v0.5.2 之后变更审查

审查日期：2026-09-08。固定比较：`git diff v0.5.2...HEAD`，基线 tag 指向
`ad3c78d55b8c5352b077d65e529cf7b2c6979b23`，受审 HEAD 为
`95cf77e736dc899c8b51dbdf68a9758e9dd4c1c1`，共 16 个提交、151 个变更文件。
本报告记录初审发现及随后工作区中的代码修复、回归测试与文档更新。版本保持 0.6.0，
未创建发布标签或发布版本。下文缺陷位置为初审 HEAD 的行号。

结论：**本次发现均已修复，达到本地发布检查标准**，可作为包含兼容性变化的 0.6.0
进入发布流程。初审曾因以下 P1/P2 问题建议暂停发布；修复后四后端各 1329 项测试通过，
真实 Cargo 探针验证通过。受审 HEAD 的三平台 CI 已成功，本次尚未提交的修复仍需在
推送后确认远端 CI。完整上游移植仍未完成。

## Standards：规范与发布维护

未发现明确的 AGENTS 规范硬违规或足以影响发布的结构坏味道。以下为维护问题，
并非语言风格违规。

### P2：参考探针不兼容自定义 Cargo 输出目录（已修复）

位置：`scripts/upstream-probe.nu:28–31`。`cargo build` 遵循 `CARGO_TARGET_DIR`，
但 helper 固定返回 `scratch/target/debug/tabular-upstream-probe`。
在临时目录设置 `CARGO_TARGET_DIR` 后，用真实 `dimension_probe.rs` 构建：
构建成功，返回路径不存在，自定义目录下的可执行文件存在，调用返回路径报
`Command … not found`。这会影响共用 helper 的五类参考夹具生成流程。

依据：[移植对照](tabled-parity.md) 声明五类探针使用固定上游提交和锁定依赖，
并提供重新生成命令；这些命令应能正确定位自身构建产物。
修复：显式指定临时目录内的 `--target-dir`，从 Cargo JSON 的 `compiler-artifact`
读取实际 `executable`，不再假设 debug 路径或文件后缀。新增
`scripts/upstream-probe_test.nu`，验证自定义输出目录、含空格路径和显式主机目标，
并真实执行生成的探针；两个场景均通过。临时目录仅清理脚本自己创建的内容。

### P2：Builder 改名遗漏迁移说明（已修正文档）

`builder.mbt:23` 将公开的 `Builder::extend` 政名为 `Builder::extend_`，原迁移文档
和 CHANGELOG 未列出这一从 v0.5.2 开始的源码兼容性变化。本次已补齐 README、
迁移指南和 CHANGELOG，并将 README Builder 示例改成可执行测试。

后续命名调整：推荐入口统一为已有的 `Builder::push_record(row)`；
`extend_(row)` 移至 `deprecated.mbt`，标记为弃用并保留兼容。
README、迁移指南和 CHANGELOG 已同步，追加一条记录的行为不变。

## Spec：需求符合性

依据为 [移植对照](tabled-parity.md)、[迁移指南](migration-0.6.md)、CHANGELOG 和
提交说明；本范围没有关联 issue。明确记录的尚未移植功能不计为新缺陷。

### P1：多余列宽缓存与后续宽度调整组合导致越界（已修复）

位置：`width_layout.mbt:29–30`，另涉及 `width_increase.mbt:83–86`。
`decrease_widths` 遍历全部缓存宽度，却用同一个下标访问仅有实际列数的 `mins`。

```moonbit
let table = @tabular.Table::from_rows([["abcdef"]])
  .with_(@tabular.Width::list([8, 8]))
table.with_(@tabular.Width::wrap(6)) |> ignore
```

修复前实测结果：数组越界。`Width::truncate` 也使用此缩减函数。将最后一步改为
`table.with_(@tabular.Width::increase(14))` 时不会崩溃，但 `table.total_width()`
仍为 **10**，未达到目标 **14**，因为多余缓存被计入总宽。

依据：`CompleteDimension::estimate` 的公开注释写明 “Longer arrays remain valid”，
迁移指南承诺表级宽度选项“调整整张表格的尺寸”。因此不应在接受多余缓存后崩溃。
修复：宽度调整只向优先级选择器传入实际列，将调整结果写回缓存前缀并保留其余条目；
总宽计算也只计入实际列。新增回归覆盖 wrap、truncate、increase、右侧优先级、
零值/较大额外缓存和无需调整的情况。上例现在正常换行为 `ab\ncd\nef`，总宽 6；
独立执行 increase 的案例总宽达到 14。

这是新 API 的已证实健壮性问题；上游源码可能有同类边界，未将它认定为已证实的
Rust/MoonBit 行为差异。

### P2：尺寸查询忽略兼容 setter 的渲染模式（已修复）

位置：`complete_dimension.mbt:105–114`。尺寸查询使用原始记录测量，渲染则使用
经过 legacy width/height mode 处理的记录尺寸。

```moonbit
let table = @tabular.Table::from_rows([["abcdef"]])
  .set_width(@tabular.Width::wrap(2))
  .set_height(@tabular.Height::increase(5))
```

实测输出是 **6 列 × 7 行**：

```text
+----+
| ab |
| cd |
| ef |
|    |
|    |
+----+
```

修复前 `(table.total_width(), table.total_height())` 返回 **(10, 3)**，会误导终端布局。
依据：移植对照声明支持尺寸查询，迁移指南同时保留“原渲染时处理方式”的 setter。
修复：新增底层 `IterGridDimension::rendered_dimension`，复用渲染器的列宽与行高测量，
供 `Table::to_string` 和 `CompleteDimension::estimate` 使用。上例现在返回 **(6, 7)**。
新增测试覆盖兼容 setter、行/列/单元格 `Setting`、零行高、显式宽高列表优先、
只读查询不填缓存、直接估算缓存，以及与表级 increase 的组合。
底层 `PeekableGridDimension` 和静态 width/height helpers 保持原有上游语义。

## 验证与文档更新

- 审查前：`moon fmt --check`、全部后端 `moon check/build/test --target all --deny-warn`
  成功；wasm、wasm-gc、JS、native 各 **1322** 项测试通过。
- 文档修改后：`moon info`、`moon fmt`、格式检查、全部后端 check/build/test 再次通过，
  各 **1323** 项测试成功且无 Warning；`.mbti` 无变化，`git diff --check` 通过。
- 代码修复后：相同检查全部通过，四后端各 **1329** 项测试成功且无 Warning。
  新增 5 个黑盒回归测试和 1 个底层 API 文档测试；未更新任何旧快照或上游参考期望。
  公开接口仅新增 `IterGridDimension::rendered_dimension`，已核对生成接口并写入迁移文档。
- 当前受审 HEAD 的 [GitHub CI](https://github.com/hustcer/tabular/actions/runs/34180094961)
  已确认 Windows、Linux、macOS 三个平台全部成功。
- 新问题用独立临时黑盒测试及真实 Rust 探针构建复现；仅删除自己创建的临时文件。
- README.md 保持指向 README.mbt.md 的符号链接；补充 0.6 API/未发布状态、包导入、
  工具链版本、Builder 改名、兼容 setter 与高级选项的区别、缓存约定和验证命令；
  修复后移除了已失效的临时规避说明。
- Nushell 脚本解析检查无 diagnostic，`upstream-literals_test.nu` 通过。
- 修复后的 `moon package` 归档在独立临时目录解压后，`moon check --deny-warn`
  和全部 **1329** 项默认后端测试通过，不依赖工作区或 Rust 上游源码。

复核命令：

```sh
moon info
moon fmt
moon fmt --check
moon check --target all --deny-warn
moon build --target all --deny-warn
moon test --target all --deny-warn
nu --no-config-file scripts/upstream-literals_test.nu
nu --no-config-file scripts/upstream-probe_test.nu /path/to/tabled
git diff --check
moon package
```

Standards：维护问题 2 项，已修复 2 项，初审最高 P2；
Spec：2 项，已修复 2 项，初审最高 P1。本次审查没有遗留阻断项。
