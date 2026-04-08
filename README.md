# 英雄联盟业余联赛平台

一个基于 FastAPI + SQLite 的英雄联盟业余联赛管理平台，支持选手管理、战队管理、约战审核、战绩统计等功能。

## 功能特性

- **用户系统** - 注册登录、JWT 认证、角色权限（普通用户/管理员）
- **选手管理** - 选手信息管理、大区筛选、位置分类
- **战队系统** - 创建战队、招募成员、加入/退出战队
- **约战系统** - 发布约战、管理员审核、对手应战、战绩截图上传
- **排行榜** - 胜率榜、KDA榜、MVP榜、积分榜、连胜榜
- **统计面板** - 平台数据统计、公开数据展示
- **管理员功能** - 约战审核、战绩录入、数据重置

## 技术栈

| 分类 | 技术 |
|------|------|
| 后端 | Python 3.12+ / FastAPI |
| 数据库 | SQLite + SQLAlchemy |
| 认证 | JWT (python-jose) |
| 前端 | 原生 HTML/CSS/JavaScript |
| 运行端口 | 3000 |

## 项目结构

```
lol-league/
├── backend/
│   ├── main.py          # FastAPI 主应用
│   ├── models.py        # SQLAlchemy 数据模型
│   ├── schemas.py       # Pydantic 请求/响应模型
│   ├── database.py      # 数据库配置
│   ├── auth.py          # JWT 认证
│   ├── requirements.txt # Python 依赖
│   └── README.md        # 后端说明
├── lol-league.html      # 前端页面
├── api.js               # 前端 API 调用
└── README.md            # 项目说明
```

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

### 3. 访问应用

- 前端页面: http://localhost:3000
- API 文档: http://localhost:3000/docs

## 管理员账号

| 字段 | 值 |
|------|-----|
| 用户名 | pener |
| 密码 | pener123 |

## 约战状态流转

```
待审核 → (admin approve) → 待应战 → (opponent accept) → 已约战 → (admin records result) → 已结束
         (admin reject) → 未通过
```

| 状态 | 含义 |
|------|------|
| `待审核` | 等待管理员审核 |
| `待应战` | 审核通过，等待对手应战 |
| `已约战` | 对手已应战，等待比赛 |
| `已结束` | 比赛结束，已录入战绩 |
| `已取消` | 发布者或管理员取消 |
| `未通过` | 管理员驳回 |

## API 接口

### 认证接口

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | /api/auth/register | 用户注册 |
| POST | /api/auth/login | 用户登录 |
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
| GET | /api/teams/{id} | 获取战队详情 |
| POST | /api/teams/{id}/recruit | 加入战队 |
| POST | /api/teams/{id}/leave | 退出战队 |
| DELETE | /api/teams/{id} | 解散战队 |
| GET | /api/teams/rankings/score | 积分榜 |
| GET | /api/teams/rankings/winStreak | 连胜榜 |

### 约战接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/matches | 获取所有约战 |
| POST | /api/matches | 发布约战 |
| GET | /api/matches/{id} | 获取约战详情 |
| POST | /api/matches/{id}/review | 审核约战 (管理员) |
| POST | /api/matches/{id}/accept | 应战约战 |
| POST | /api/matches/{id}/screenshot | 上传战绩截图 |
| POST | /api/matches/{id}/cancel | 取消约战 |
| POST | /api/matches/{id}/result | 录入战绩 (管理员) |

### 统计接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/stats/overview | 平台统计 (需登录) |
| GET | /api/stats/public | 公开统计 |
| POST | /api/stats/reset | 重置数据 (管理员) |
| POST | /api/stats/clear-results | 清空战绩 (管理员) |

## 数据模型

### User (用户)
- `id` - 用户ID
- `username` - 用户名
- `hashed_password` - 加密密码
- `is_admin` - 是否管理员
- `player_id` - 关联选手ID
- `created_at` - 创建时间

### Player (选手)
- `id` - 选手ID
- `user_id` - 关联用户ID
- `team_id` - 所属战队ID
- `match_name` - 召唤师名称
- `game_id` - 游戏ID
- `region_group` - 大区
- `region_small` - 小区
- `position` - 位置
- 统计数据: wins, losses, kills, deaths, assists, mvp_count, games_played, win_rate, kda

### Team (战队)
- `id` - 战队ID
- `name` - 战队名称
- `captain_id` - 队长ID
- `region_group` - 大区
- `region_small` - 小区
- 统计数据: wins, losses, win_streak, score
- `recruit_status` - 招募状态

### Match (约战)
- `id` - 约战ID
- `team_id` - 发起战队ID
- `opponent_id` - 应对战队ID
- `mode` - 比赛模式
- `time` - 约战时间
- `status` - 状态
- `winner_id` - 获胜方
- `loser_id` - 失败方
- `mvp_player_id` - MVP选手
- `screenshot` - 战绩截图 (Base64)
- `reviewed_by` - 审核人
- `reviewed_at` - 审核时间
- `reject_reason` - 驳回原因

## 开发说明

### 前端配置

前端页面通过 `api.js` 调用后端 API，API 基础地址为 `/api`（相对路径）。

如需修改 API 地址，编辑 `api.js` 中的 `API_BASE` 常量。

### 数据库

默认使用 SQLite 数据库 `lol-league.db`，数据库表会在首次启动时自动创建。

如需重置数据库，删除 `backend/lol-league.db` 文件后重启服务。

## License

MIT
