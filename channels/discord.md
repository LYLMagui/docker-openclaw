# discord 连接问题

**如果 openclaw 部署的服务器是在国内，需要配置代理。**

1. docker compose 中环境变量需要添加如下内容：

```yaml
 environment:
      # 运行期间的代理配置
      HTTP_PROXY: ${HTTP_PROXY:-http://127.0.0.1:7890}
      HTTPS_PROXY: ${HTTPS_PROXY:-http://127.0.0.1:7890}
      NO_PROXY: ${NO_PROXY:-localhost,127.0.0.1}
      # --dns-result-order=ipv4first：在云服务器环境优先用 IPv4，减少 IPv6 解析后连接超时的问题。
      # --use-env-proxy：明确要求 Node 内建 fetch / undici 读取 HTTP_PROXY / HTTPS_PROXY / NO_PROXY
      # 这一项必须配置，否则 Node 默认不会走代理，会导致 fetch失败
      NODE_OPTIONS: --dns-result-order=ipv4first --use-env-proxy
```

2. 在 openclaw.json 中开启代理
   
   ```json
   "channels": {
    "discord": {
      "enabled": true,
      "token": "机器人token",
      "groupPolicy": "open",
      "dmPolicy": "open",
      "proxy": "http://代理ip:7890",
      "allowFrom": [
        "*"
      ],
      "dm": {
        "enabled": true
      },
      "streaming": "off"
    }
   },
   ```
