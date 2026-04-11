# 英雄联盟业余联赛平台

一个基于 FastAPI + SQLite + Flutter 的英雄联盟业余联赛管理平台，支持选手管理、战队管理、约战审核、战绩统计等功能。

## 功能特性

- **用户系统** - 注册登录、JWT 认证、角色权限（普通用户/管理员）
- **选手管理** - 选手信息管理、大区筛选、位置分类
- **战队系统** - 创建战队、招募成员、加入/退出战队
- **约战系统** - 发布约战、管理员审核、对手应战、战绩截图上传
- **排行榜** - 胜率榜、KDA榜、MVP榜、积分榜、连胜榜
- **统计面板** - 平台数据统计、公开数据展示
- **管理员功能** - 约战审核、战绩录入、数据管理(Excel导入导出)、用户管理
- **通知系统** - 战队邀请、入队申请、约战邀请等通知

## 技术栈

| 分类 | 技术 |
|------|------|
| 后端 | Python 3.12+ / FastAPI |
| 数据库 | SQLite + SQLAlchemy |
| 认证 | JWT (python-jose) |
| 移动端 | Flutter + Provider + GoRouter |
| 运行端口 | 3000 |

## 项目结构

```
lol-league/
├── backend/                    # FastAPI 后端
│   ├── main.py               # FastAPI 主应用
│   ├── models.py             # SQLAlchemy 数据模型
│   ├── schemas.py            # Pydantic 请求/响应模型
│   ├── database.py           # 数据库配置
│   ├── auth.py               # JWT 认证
│   ├── requirements.txt     # Python 依赖
│   └── lol-league.db        # SQLite 数据库
├── lol_league_app/           # Flutter 移动端应用
│   ├── lib/
│   │   ├── core/            # 核心配置、网络、工具
│   │   ├── data/            # 数据层 (models, repositories)
│   │   ├── domain/          # 业务层 (providers)
│   │   ├── presentation/   # 界面层 (screens, widgets)
│   │   └── routes/          # 路由配置
│   └── pubspec.yaml
├── lol-league.html           # Web 前端
└── README.md
```

## 快速开始

### 后端启动

```bash
cd backend
pip install -r requirements.txt
python main.py
```

服务器将在 http://localhost:3000 启动

### Flutter 应用启动

```bash
cd lol_league_app
flutter pub get
flutter run
```

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
| `pending` | 待审核 |
| `waiting` | 待应战 |
| `accepted` | 已约战 |
| `completed` | 已结束 |
| `cancelled` | 已取消 |
| `rejected` | 未通过 |

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
| PUT | /api/players/{id}/stats | 更新选手统计 (管理员) |

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
| PUT | /api/teams/{id}/stats | 更新战队统计 (管理员) |

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

### 通知接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/notifications | 获取通知列表 |
| POST | /api/notifications | 创建通知 |
| PUT | /api/notifications/{id} | 更新通知状态 |
| DELETE | /api/notifications/{id} | 删除通知 |
| GET | /api/notifications/unread-count | 获取未读数量 |

### 用户管理接口 (管理员)

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/users | 获取所有用户 |
| PUT | /api/users/{id}/admin | 设置/取消管理员 |
| DELETE | /api/users/{id} | 删除用户 |

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
- 统计数据: wins, losses, kills, deaths, assists, mvp_count, games_played, win_rate, kda, win_streak

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

### Notification (通知)
- `id` - 通知ID
- `type` - 通知类型 (team_invite, team_apply, match_invite, match_accept, match_reject)
- `status` - 状态 (pending, accepted, rejected, cancelled)
- `from_user_id` - 发送者用户ID
- `to_user_id` - 接收者用户ID
- `team_id` - 相关战队ID
- `match_id` - 相关约战ID
- `message` - 通知消息内容
- `read` - 是否已读

## 开发说明

### Flutter 应用配置

Flutter 应用位于 `lol_league_app/` 目录，使用 Provider 进行状态管理，GoRouter 进行路由管理。

主要依赖：
- provider: 状态管理
- dio: 网络请求
- go_router: 路由管理
- shared_preferences: 本地存储
- flutter_secure_storage: 安全存储
- excel: Excel 文件处理

### 数据库

默认使用 SQLite 数据库 `backend/lol-league.db`，数据库表会在首次启动时自动创建。

## License

MIT
