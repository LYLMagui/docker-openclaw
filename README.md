# docker-openclaw

高权限 Docker 版 OpenClaw 的部署方案。

openclaw 部署在服务器，想用来维护服务器，但是官方的 docker 部署权限太低了，因此自己重写一个高权限版的 docker compose也方便后续迁移

### 1. 准备环境变量 `.env`

```bash
cp .env.example .env
```

```env
# 网关令牌
OPENCLAW_GATEWAY_TOKEN=replace-with-a-long-random-token 
```

建议使用`openssl rand -hex 32openssl rand -hex 32`生成：

### 2. 在本目录下拉取 OpenClaw 源码

```bash
bash scripts/pull-openclaw.sh
```

### 3. 启动openclaw容器

```bash
docker compose up -d --build
```

其中 `openclaw-cli` 通过 `network_mode: "service:openclaw-gateway"` 共享网关容器的网络命名空间，因此可以直接访问 `127.0.0.1:18789`。

### 4. 初始化 OpenClaw 配置

```bash
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js config set gateway.mode local
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js config set gateway.bind lan
# 限制ui访问ip为本机
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js config set gateway.controlUi.allowedOrigins '["http://127.0.0.1:18789"]' --strict-json
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js config set gateway.auth.token "$OPENCLAW_GATEWAY_TOKEN"
```

### 5. 重新构建容器

```bash
docker compose stop openclaw-gateway || true
docker compose rm -f openclaw-gateway || true
docker compose up -d --force-recreate openclaw-gateway
```

#### 容器运行后openclaw的初始化配置

```bash
docker compose run --rm openclaw-cli config
```

### 6. 查看日志：

```bash
docker compose logs  --tail=50 openclaw-gateway
```

远程访问建议使用 SSH 隧道：

```bash
ssh -L 18789:127.0.0.1:18789 root@your-server
```

### 踩坑点

#### 面板报错：disconnected (1008): pairing required

**容器网络说明**

当前 `openclaw-cli` 不是独立网络栈，而是共享 `openclaw-gateway` 的网络命名空间，所以它访问 `127.0.0.1:18789` 时，实际访问的是网关容器里的同一个回环地址。

**设置 Gateway 绑定到局域网**

内置向导默认使用回环地址，但浏览器请求是通过 Docker 的桥接网络（172.18.0.x）到达的。在`~/.openclaw/openclaw.json`中：

```json
"gateway": {
  "bind": "lan"
}
```

**批准待匹配设备**

控制 UI 第一次从"新浏览器/新设备"连到 Gateway 时，需要做一次性"设备配对批准"（即使同一台机器、同一个 Tailnet 也可能需要）。

```bash
docker compose exec openclaw-gateway node dist/index.js devices list
docker compose exec openclaw-gateway node dist/index.js devices approve <request-id>
```

[discord连接问题](./channels/discord.md)
