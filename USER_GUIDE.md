# 用户使用手册

## 1. 你最终获得了什么

这套实施包会在你的 Mac 上安装：

```text
~/.codex/AGENTS.md
$HOME/.agents/skills/project-context-init/
$HOME/.agents/skills/project-task-finalize/
```

以后每个经过初始化的项目会拥有：

```text
project/
├── AGENTS.md
├── README.md
├── .gitignore
├── .ai/
│   ├── current-state.md
│   └── decisions/
└── docs/
```

它不会替代 Codex，也不会建立独立应用。它改变的是 Codex 在项目中的工作方式。

## 2. 第一次安装

1. 解压实施包；
2. 在解压目录启动 Codex；
3. 将 `CODEX_INSTALL_PROMPT.md` 的内容交给 Codex；
4. Codex 会检查现有全局配置，并给出安装 diff；
5. 重点确认：
   - 没有覆盖你原来的 `~/.codex/AGENTS.md`；
   - Skill 安装路径为 `$HOME/.agents/skills/`；
   - 脚本通过语法和临时仓库测试；
6. 同意后由 Codex执行安装；
7. 重启 Codex，使 Skill 和全局指令稳定加载。

实施包也提供 `scripts/install.sh`，但首次安装仍推荐由 Codex先审核后执行。

## 3. 初始化一个新项目

```bash
mkdir my-project
cd my-project
git init
codex
```

在 Codex 中输入：

```text
$project-context-init

项目名称：my-project
项目目标：用一句话描述项目要完成什么。
```

Codex 将：

- 创建最小上下文结构；
- 填写可以确认的项目事实；
- 显示 diff；
- 创建 `chore: initialize project context` commit。

完成后必须：

1. 退出当前 Codex 会话；
2. 从项目根目录重新启动 Codex；
3. 输入：

```text
列出你加载的指令来源，并简要总结当前项目状态。
```

确认它读取了全局和项目 `AGENTS.md`。

## 4. 初始化已有项目

进入已有 Git 仓库后调用：

```text
$project-context-init
```

Codex 会分析已有 README、依赖、配置、代码入口、测试和 CI，不会覆盖非空文件。若已有修改与目标文件冲突，它会停止并汇报。

## 5. 日常开发

初始化后，你只需自然描述任务，例如：

```text
为登录接口增加刷新令牌支持。
```

不需要重复说：

- 读取 AGENTS；
- 读取 current-state；
- 检查 docs；
- 更新项目状态；
- 运行测试；
- 提交 Git。

这些由项目指令和 Skill 负责。

## 6. 高风险任务

例如：

```text
把用户数据库从 SQLite 迁移到 PostgreSQL。
```

Codex 应先说明：

- 方案；
- 影响范围；
- 数据风险；
- 验证方法；
- 回滚或恢复方案。

得到确认后再修改。若它直接开始执行，立即停止并把该失误加入后续 Skill/AGENTS 改进清单。

## 7. 任务收尾

正常情况下，项目 `AGENTS.md` 会要求 Codex 在产生文件修改的任务结束前使用 `$project-task-finalize`。

也可以显式调用：

```text
$project-task-finalize
```

它会检查：

- 本次目标和 Git diff 是否一致；
- 验证是否足够；
- 是否需要更新 `current-state`、decision 或 docs；
- 是否混入无关修改；
- 是否可以创建本地 commit。

最终报告应包括：

- 实现结果；
- 运行的验证；
- 上下文更新；
- commit 哈希；
- 未解决问题或未验证范围。

## 8. 查看项目状态

直接询问：

```text
总结当前项目状态、已知问题和下一步。
```

Codex 应结合 `.ai/current-state.md` 与实际代码回答，而不是只复述旧文档。

## 9. 何时记录 decision

适合记录：

- 数据库或核心框架选择；
- 公开接口或数据模型的重要变化；
- 认证、权限和安全设计；
- 已否决但未来可能再次提出的合理方案。

不记录：

- 普通 Bug 修复；
- 临时调试；
- 局部实现细节；
- Git 已充分表达的变更。

## 10. 如何改进全局 Skill

当你发现重复问题，例如：

- 经常漏掉某类验证；
- 经常错误更新 `current-state`；
- 经常创建无意义文档；
- 经常把无关文件加入 commit；

在任意项目中对 Codex说：

```text
这个问题反复出现。请分析它应该修改项目规则还是全局 Skill；先给出修改理由和 diff，不要直接安装。
```

确认后修改 `$HOME/.agents/skills/` 中对应 Skill。Codex 会自动发现 Skill 变化；若未出现，重启 Codex。全局 Skill 更新后，所有项目都会使用新流程，但不会共享各项目的具体知识。

## 11. 什么时候不要扩展系统

暂时不要因为“可能有用”就增加：

- 更多 Skill；
- MCP；
- Hook；
- 任务日志；
- 项目地图；
- 完整 Changelog；
- 多 Agent。

只有重复出现、能够明确描述、跨项目有价值的问题，才值得固化为新的全局资产。

## 12. 常见问题

### Skill 没有自动调用

先显式输入 `$project-task-finalize`。若多次漏调用，再考虑 Stop Hook，而不是立即扩大 AGENTS.md。

### 项目文档变得越来越长

要求 Codex执行上下文清理：删除重复、替换过期状态、保留当前事实；不要把流水账转存到新文件。

### 工作区已有自己的修改

Codex 不应 stash、reset、clean 或覆盖。它只能精确暂存当前任务文件；同一文件无法分离时应停止。

### 自动 commit 是否安全

本地原子 commit 提供清晰历史和回滚点；默认不自动 push。高风险任务仍需先确认方案。

### 能否用于 Claude Code 或其他 Agent

项目内的上下文思想可复用，但不同工具的指令文件和 Skill 机制不同。第一版只保证 Codex，不做跨工具兼容层。
