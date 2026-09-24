<h1 align="center">QoderGate</h1>

<p align="center">
  将多个 Qoder 账号统一转换成 OpenAI 兼容接口的本地网关。<br>
  此 fork 已移除自动注册账号功能，并针对 Docker 部署做了精简。
</p>

## 当前版本

- OpenAI 兼容接口：`/v1/chat/completions`
- 多账号池、失败轮转、Token 刷新、额度查询
- WebUI 管理控制台与文档站
- SQLite 持久化
- 支持 PAT、账号 JSON 和本机 Qoder 登录会话导入
- 已移除自动注册机、DrissionPage、pypiwin32 及相关注册脚本
- Docker / Docker Compose 部署

## Docker 安装

要求：Docker Desktop 或 Docker Engine + Docker Compose。

```bash
git clone https://github.com/ajoa76/QoderGateway.git
cd QoderGateway
cp .env.example .env
docker compose up -d --build
```

Windows PowerShell 可使用：

```powershell
git clone https://github.com/ajoa76/QoderGateway.git
cd QoderGateway
Copy-Item .env.example .env
docker compose up -d --build
```

启动后访问：

- 管理控制台：`http://127.0.0.1:5050/console`
- 文档：`http://127.0.0.1:5050/documents`
- 健康检查：`http://127.0.0.1:5050/healthz`
- OpenAI API Base URL：`http://127.0.0.1:5050/v1`

默认管理密码为 `admin`。建议在 `.env` 中修改 `QODER_ADMIN_PASSWORD` 后再正式使用。

## 数据持久化

Docker Compose 使用命名 volume：

```text
qodergateway-data -> /root/.qoder
```

SQLite 数据库位于容器中的：

```text
/root/.qoder/qoder2api.db
```

因此重新构建或升级容器不会删除账号、API Key 和网关配置。

## 常用命令

```bash
# 查看状态
docker compose ps

# 查看日志
docker compose logs -f qodergateway

# 重启
docker compose restart qodergateway

# 更新代码并重建
git pull
docker compose up -d --build

# 停止
docker compose down
```

不要使用 `docker compose down -v`，除非明确要删除持久化数据。

## 导入账号

可以在 WebUI 中：

1. 添加 Qoder PAT。
2. 导入本机已有 Qoder 登录会话（仅适用于直接在宿主机运行后端的场景）。
3. 批量粘贴账号 JSON。

Docker 容器不会自动创建或注册新的 Qoder 账号。

## 第一次 API 调用

```bash
curl http://127.0.0.1:5050/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "lite",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": false
  }'
```

如果在控制台开启了 API Key 鉴权，请按页面生成的 Key 添加对应请求头。

## 环境变量

| 变量 | 说明 | 默认值 |
|---|---|---|
| `QODER_HOST` | 容器内监听地址 | `0.0.0.0` |
| `QODER_PORT` | 服务端口 | `5050` |
| `QODER_ADMIN_PASSWORD` | 管理后台密码 | `admin` |
| `QODER_PROXY` | 可选出站代理 | 空 |
| `QODER_ENABLE_DOCUMENTS` | 是否启用文档页 | `1` |
| `QODER_ENABLE_LANDING` | 是否启用 Landing Page | `1` |
| `QODER_PAT` | 首次启动自动导入的 PAT | 空 |

如果 Docker 需要访问 Windows 宿主机上的代理，可使用：

```env
QODER_PROXY=http://host.docker.internal:7890
```

## 项目结构

```text
├── Dockerfile
├── docker-compose.yml
├── frontend/
├── src/qoder2api/
│   ├── app.py
│   ├── accounts.py
│   ├── auth.py
│   ├── bridge.py
│   ├── config.py
│   ├── database.py
│   ├── env.py
│   └── tokens.py
├── .env.example
└── pyproject.toml
```

## License

MIT
