# SecretCat

SecretCat 是一个开源的密码管理工具，帮助你安全地存储和管理各种密码、密钥和敏感信息。

## 特性

- 🔒 安全加密：使用强大的加密算法保护你的数据
- 🌐 多平台支持：支持 x86_64、ARM64 和 ARMv7 架构
- 🔑 密码生成器：生成强密码
- 📱 响应式设计：支持桌面和移动设备访问
- 🔄 数据备份：支持数据导入导出
- 🚀 快速搜索：快速查找存储的密码和信息

## 使用 Docker 部署

### 快速开始

最简单的方式是使用 Docker 运行 SecretCat：

```bash
mkdir -p $HOME/secretcat
docker run -d --restart always \
  --name secretcat \
  -p 3000:3000 \
  -v $HOME/secretcat:/rails/storage \
  -v $HOME/secretcat/credentials:/rails/config/credentials \
  ghcr.io/qichunren/secretcat:latest
```

### 使用 Docker Compose

推荐使用 Docker Compose 进行部署，创建 `docker-compose.yml` 文件：

```yaml
version: '3'
services:
  secretcat:
    image: ghcr.io/qichunren/secretcat:latest
    container_name: secretcat
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - $HOME/secretcat:/rails/storage
      - $HOME/secretcat/credentials:/rails/config/credentials
    environment:
      - RAILS_ENV=production

volumes:
  secretcat-data:
```

然后运行：

```bash
docker compose up -d
```

### 配置说明

- `3000:3000`: 端口映射，可以根据需要修改左边的端口
- `secretcat-data`: 数据持久化卷，包含数据库和配置文件
- `DATABASE_URL`: 数据库连接配置，默认使用 SQLite

### 更新到最新版本

```bash
# 拉取最新镜像
docker pull ghcr.io/qichunren/secretcat:latest

# 如果使用 docker run
docker restart secretcat

# 如果使用 docker compose
docker compose up -d
```

## 开发说明

如果你想参与开发，请参考以下步骤：

1. Clone 项目
2. 安装依赖
3. 设置开发环境
4. 运行测试
5. 提交 PR

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件
