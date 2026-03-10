# AGENTS.md

本文件适用于 `docker-openclaw` 仓库根目录及其所有子目录。

## 仓库作用

本仓库用于维护 OpenClaw 的独立 Docker 部署方案，目标是：

- 固化可复用的 Docker Compose 部署流程
- 固化初始化和升级步骤
- 将 OpenClaw 源码与部署仓库解耦

本仓库不存放 OpenClaw 源码本身。

## 核心约束

- `openclaw/` 目录仅作为脚本拉取的外部源码目录，不纳入 Git
- 不要把 OpenClaw 源码文件复制进本仓库提交
- 不要把真实 `.env` 提交到仓库
- 不要把真实 token、cookie、session key、私有地址写进示例文件

## 文件职责

- `docker-compose.yml`：部署定义
- `.env.example`：环境变量模板
- `scripts/pull-openclaw.sh`：拉取或更新 OpenClaw 原仓库
- `scripts/init-openclaw.sh`：初始化 OpenClaw 配置
- `README.md`：部署说明

## 修改原则

- 优先保持部署流程稳定
- 优先做小而清晰的变更
- 如果调整了初始化流程，同步更新 `README.md`
- 如新增脚本，应保持可直接在 Linux shell 中执行

## 路径约定

- OpenClaw 源码目录：`./openclaw`
- 宿主机配置目录：`/home/workspace/openclaw`
- 面板地址：`http://127.0.0.1:18789`

## AI 行为约束

- 修改前先阅读本文件和 `README.md`
- 如涉及 OpenClaw 版本更新，优先通过 `scripts/pull-openclaw.sh` 处理
- 不要擅自把部署模式从高权限改成低权限，除非用户明确要求
- 不要擅自放宽面板暴露范围，默认只允许绑定到 `127.0.0.1`
