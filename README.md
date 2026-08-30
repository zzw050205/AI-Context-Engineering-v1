# Codex 项目上下文工程 v1

这是一套面向个人长期使用的 Codex 项目上下文基础设施。它不创建新的编程 Agent，而是通过以下组件，让 Codex 在不同项目中持续理解项目规则、当前状态和长期决策：

- 全局 `AGENTS.md`：个人稳定的工作原则；
- 两个全局 Skill：初始化项目、完成任务收尾；
- 最小项目上下文模板：项目规则、当前状态、决策与按需文档；
- 确定性脚本：创建骨架、收集 Git 变更证据；
- Git 工作流：验证、精确暂存、本地原子提交和可恢复历史。

## 文件入口

- `IMPLEMENTATION.md`：架构、边界和实施规范；
- `USER_GUIDE.md`：日常使用手册；
- `CODEX_INSTALL_PROMPT.md`：交付给 Codex 的安装与验证提示词；
- `global/`：需要安装到个人 Codex 环境的资产；
- `project-template/`：项目初始化生成的最小模板；
- `scripts/`：安全安装和验证辅助脚本。

## 推荐使用方式

1. 解压本包；
2. 在本目录启动 Codex；
3. 将 `CODEX_INSTALL_PROMPT.md` 的内容交给 Codex；
4. 审核 Codex 给出的安装 diff；
5. 安装后在一个小型 Git 项目中调用 `$project-context-init` 验证；
6. 新开会话后执行一个小任务，验证 `$project-task-finalize`。

本项目第一版刻意不包含 MCP、Hook、多 Agent、自动 push/PR、外部知识库和复杂项目脚手架。只有实践证明存在稳定需求后再增加。
