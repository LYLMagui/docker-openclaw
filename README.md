# docker-openclaw

这个仓库用于部署高权限 Docker 版 OpenClaw，不将 OpenClaw 源码本身纳入 Git。

## 仓库内容

- `docker-compose.yml`：高权限 OpenClaw 部署配置
- `.env.example`：环境变量模板
- `scripts/pull-openclaw.sh`：拉取 OpenClaw 原仓库 `main` 分支
- `scripts/init-openclaw.sh`：初始化 OpenClaw 配置并写入关键网关参数

## 设计目标

- OpenClaw 配置固定挂载到 `/home/workspace/openclaw`
- 容器可直接操作宿主机文件系统：`/:/host`
- 容器可直接控制宿主机 Docker：`/var/run/docker.sock`
- 控制面板仅暴露到宿主机回环地址：`127.0.0.1:18789`
- 仓库中不存储 OpenClaw 源码，仅通过脚本拉取

## 快速开始

### 1. 准备环境变量

```bash
cp .env.example .env
```

编辑 `.env`，至少填写：

```env
OPENCLAW_GATEWAY_TOKEN=你的长随机token
```

### 2. 拉取 OpenClaw 源码

```bash
bash scripts/pull-openclaw.sh
```

默认拉取：

- 仓库：`https://github.com/openclaw/openclaw.git`
- 分支：`main`

源码会被放到当前仓库下的 `./openclaw`，该目录已被 `.gitignore` 忽略。

### 3. 构建并启动

```bash
docker compose up -d --build openclaw-gateway
```

### 4. 初始化 OpenClaw

```bash
bash scripts/init-openclaw.sh
```

该脚本会自动：

- 执行 onboarding
- 设置 `gateway.mode=local`
- 设置 `gateway.bind=lan`
- 设置 `gateway.controlUi.allowedOrigins=["http://127.0.0.1:18789"]`
- 设置 `gateway.auth.token`
- 重建并重启 `openclaw-gateway`

## 访问面板

本机浏览器打开：

```text
http://127.0.0.1:18789
```

远程访问时，建议使用 SSH 隧道：

```bash
ssh -L 18789:127.0.0.1:18789 root@your-server
```

## 常用命令

查看日志：

```bash
docker compose logs -f openclaw-gateway
```

查看健康状态：

```bash
curl http://127.0.0.1:18789/healthz
```

执行 OpenClaw CLI：

```bash
docker compose exec openclaw-gateway node dist/index.js status
```

配置渠道，例如 WhatsApp：

```bash
docker compose exec openclaw-gateway node dist/index.js channels login --channel whatsapp
```

## 注意

- 这是高权限部署，等价于把宿主机级能力交给 OpenClaw
- `OPENCLAW_GATEWAY_TOKEN` 必须自行妥善保管
- 不要把真实 `.env` 提交到仓库
