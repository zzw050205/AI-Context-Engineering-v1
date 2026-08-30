# 交付给 Codex 的安装提示词

请把当前目录视为一份已经完成架构设计的实施包，负责将它安全安装到我的本机 Codex 环境，并完成验证。不要重新设计整体架构，也不要擅自扩大第一版范围。

## 目标

安装并验证以下内容：

- 将 `global/AGENTS.md` 的规则安全合并到 `~/.codex/AGENTS.md`；
- 将以下用户级 Skill 安装到 `$HOME/.agents/skills/`：
  - `project-context-init`
  - `project-task-finalize`
- 验证两个 Skill 的结构、元数据和脚本；
- 使用临时 Git 仓库验证项目初始化流程；
- 不修改任何真实业务项目。

## 必读文件

先完整阅读并遵循：

1. `IMPLEMENTATION.md`
2. `USER_GUIDE.md`
3. `global/AGENTS.md`
4. 两个 Skill 的 `SKILL.md`
5. `scripts/install.sh`
6. `scripts/verify_package.sh`

## 安装原则

1. 先检查当前系统、`$HOME`、Codex 可用性、现有 `~/.codex/AGENTS.md` 和 `$HOME/.agents/skills/`。
2. 不覆盖、删除或重写现有个人配置。
3. 若 `~/.codex/AGENTS.md` 已存在：
   - 先备份；
   - 比较现有规则与本包规则；
   - 去除重复与冲突；
   - 给出合并后的 diff；
   - 获得我确认后再写入。
4. 若同名 Skill 已存在：
   - 先备份；
   - 比较版本和内容；
   - 给出替换或合并方案；
   - 获得我确认后再安装。
5. 不修改 `~/.codex/config.toml`、权限、网络、MCP、Hook 或 Git 全局配置，除非验证表明这是安装两个 Skill 所必需的；若必要，先说明理由并请求确认。
6. 不执行 push、发布、部署或任何外部状态变更。
7. 不使用破坏性 Git 或文件命令。

## 执行顺序

### 阶段 A：只读审查

- 检查实施包完整性；
- 执行 `scripts/verify_package.sh`；
- 审查所有 shell 脚本；
- 检查 Skill frontmatter 和 `agents/openai.yaml`；
- 列出发现的问题。

发现实现错误时，可以修改本实施包，但必须保持 `IMPLEMENTATION.md` 的架构边界，并说明修改原因。

### 阶段 B：安装预览

- 运行 `scripts/install.sh --dry-run`；
- 展示将创建、更新、跳过和备份的内容；
- 展示全局 AGENTS 合并方案；
- 等待我确认。

### 阶段 C：执行安装

获得确认后：

- 执行安全安装；
- 保留时间戳备份；
- 确保 Skill 脚本具有执行权限；
- 不覆盖无关文件。

### 阶段 D：验证

在临时目录创建一个最小 Git 仓库并验证：

1. `project-context-init` 的脚本只创建缺失结构；
2. 重复执行不会破坏或覆盖现有非空文件；
3. `.gitignore` 合并不会删除已有内容；
4. `project-task-finalize` 的取证脚本能正确输出分支、工作区状态、diff、未跟踪文件和最近提交；
5. 两个 Skill 可被 Codex发现；若当前会话未刷新，说明需要重启或新开会话；
6. 新建项目 `AGENTS.md` 后，明确提醒必须新开 Codex 会话才能正式加载。

不要在临时验证中模拟真实密钥、生产环境、网络或外部服务。

## 最终输出

完成后向我汇报：

- 实际安装路径；
- 创建、合并、跳过和备份的文件；
- 包内修复内容；
- 执行过的验证及结果；
- Skill 发现状态；
- 仍需我手动完成的步骤；
- 如何初始化第一个真实项目。

安装完成后不要继续扩展 MCP、Hook、Plugin、多 Agent 或更多 Skill。第一版先投入真实项目验证。
