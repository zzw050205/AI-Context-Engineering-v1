# 官方机制依据

本实施包依据 2026-08-01 可访问的 OpenAI Codex 官方文档设计：

- AGENTS.md：`https://developers.openai.com/codex/agent-configuration/agents-md`
- Codex Skills：`https://developers.openai.com/codex/build-skills`
- Customization overview：`https://developers.openai.com/codex/customization/overview`
- Agent approvals & security：`https://developers.openai.com/codex/agent-approvals-security`
- Codex Rules：`https://developers.openai.com/codex/rules`

采用的关键事实：

- 全局指令文件位于 `~/.codex/AGENTS.md`；
- 用户级 Skill 位于 `$HOME/.agents/skills/`；
- Skill 必须包含带 `name` 和 `description` 的 `SKILL.md`；
- Skill 可以附带 `scripts/`、`references/`、`assets/` 和 `agents/openai.yaml`；
- Codex 支持 `$skill-name` 显式调用，也可根据 description 隐式调用；
- `policy.allow_implicit_invocation` 默认为 true，可显式关闭；
- Skill 修改通常会自动发现，未出现时重启 Codex；
- AGENTS.md 应保持精简，复杂可复用流程优先封装为 Skill；
- Codex 原生沙盒控制技术权限，审批策略控制何时询问用户。

产品机制可能更新。若未来路径、元数据或调用方式发生变化，应优先以最新官方文档为准，再更新本实施包。
