# 英雄联盟业余联赛平台 - Python 后端

## 技术栈

- **运行时**: Python 3.12+
- **框架**: FastAPI
- **数据库**: SQLite
- **认证**: JWT (python-jose)
- **密码加密**: passlib

## 快速开始

### 1. 安装依赖

```bash
cd backend
pip install -r requirements.txt
```

### 2. 启动服务器

```bash
python main.py
```

服务器将在 http://localhost:3000 启动

### 3. 访问 API 文档

启动后访问 http://localhost:3000/docs 查看交互式 API 文档

## 管理员账号

- 用户名: pener
- 密码: pener123

## API 接口

### 认证接口

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | /api/auth/register | 注册 |
| POST | /api/auth/login | 登录 |
| GET | /api/auth/me | 获取当前用户 |

### 选手接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/players | 获取所有选手 |
| POST | /api/players | 创建/更新选手 |
| GET | /api/players/rankings/winrate | 胜率榜 |
| GET | /api/players/rankings/kda | KDA榜 |
| GET | /api/players/rankings/mvp | MVP榜 |

### 战队接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/teams | 获取所有战队 |
| POST | /api/teams | 创建战队 |
| POST | /api/teams/{id}/recruit | 加入战队 |
| DELETE | /api/teams/{id} | 解散战队 |

### 约战接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/matches | 获取所有约战 |
| POST | /api/matches | 发布约战 |
| POST | /api/matches/{id}/accept | 应战 |
| POST | /api/matches/{id}/result | 录入战绩 |

## 前端配置

前端 HTML 文件需要调用此 API，将 `lol-league.html` 中的 JavaScript 数据操作替换为 API 调用。

API 基础地址: `http://localhost:3000/api`
