# Project Instructions

## Project

- Purpose: [待填写]
- Current scope: [待填写]
- Important directories: [待填写；小项目无必要时写“无特殊目录”]

## Commands

- Install: [待填写；不存在则写“无”]
- Run: [待填写；不存在则写“无”]
- Test: [待填写；不存在则写“无”]
- Lint: [待填写；不存在则写“无”]
- Type check: [待填写；不存在则写“无”]
- Build: [待填写；不存在则写“无”]

## Repository Rules

- 修改前理解现有实现，保持项目既有风格和设计一致性。
- 优先简单、可维护、与当前规模匹配的方案。
- [填写项目特有的兼容性、架构、编码或审查规则；没有则删除此占位项。]

## Context Routing

- 重要功能或跨模块任务读取 `.ai/current-state.md`。
- 只按任务需要读取相关 `docs/` 和 `.ai/decisions/`。
- 不默认加载全部项目文档。
- 只有代码和配置无法充分表达、且未来会反复需要的信息才写入 `docs/`。

## Sensitive Project Operations

- 涉及数据库迁移、认证权限、公开接口、核心架构或依赖、生产环境、外部状态或难回滚操作时，修改前说明方案并获得确认。
- [填写本项目额外敏感边界；没有则删除此占位项。]

## Completion

- 修改后运行与任务风险和影响范围匹配的最小充分验证。
- 完成产生文件修改的任务前，使用全局 `$project-task-finalize` Skill。
- 可以创建经过验证的本地原子 commit；不自动 push、merge、deploy 或改写历史。
- 修改本文件或既有长期决策前必须获得用户确认。
