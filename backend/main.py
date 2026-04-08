"""
英雄联盟业余联赛平台 - FastAPI 后端
Python + SQLite + 前端
"""
from fastapi import FastAPI, Depends, HTTPException, Query, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, FileResponse, Response as HttpResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from datetime import datetime
from typing import List, Optional
import json
import os

from database import engine, get_db, Base, SessionLocal
import models
from schemas import (
    UserCreate, UserLogin, UserResponse,
    PlayerCreate, PlayerResponse,
    TeamCreate, TeamUpdate, TeamResponse, TeamDetailResponse,
    MatchCreate, MatchAccept, MatchReviewRequest, MatchScreenshotUpload, MatchResultSubmit, MatchResponse,
    Response, ListResponse
)
from auth import (
    get_password_hash, verify_password, create_access_token,
    get_current_user, admin_required
)

# 创建数据库表
Base.metadata.create_all(bind=engine)

# 数据库迁移：为已有数据库添加新列
def run_migrations():
    """为已存在的数据库添加新字段"""
    from sqlalchemy import text
    db = SessionLocal()
    try:
        # 检查 matches 表是否有 screenshot 列
        result = db.execute(text("PRAGMA table_info(matches)")).fetchall()
        column_names = [row[1] for row in result]
        if "screenshot" not in column_names:
            db.execute(text("ALTER TABLE matches ADD COLUMN screenshot TEXT DEFAULT ''"))
        if "reviewed_by" not in column_names:
            db.execute(text("ALTER TABLE matches ADD COLUMN reviewed_by INTEGER REFERENCES users(id)"))
        if "reviewed_at" not in column_names:
            db.execute(text("ALTER TABLE matches ADD COLUMN reviewed_at DATETIME"))
        if "reject_reason" not in column_names:
            db.execute(text("ALTER TABLE matches ADD COLUMN reject_reason TEXT DEFAULT ''"))
        db.commit()
    except Exception as e:
        db.rollback()
        print(f"迁移警告: {e}")
    finally:
        db.close()

run_migrations()

# FastAPI 应用
app = FastAPI(
    title="英雄联盟业余联赛 API",
    description="电竞平台后端服务",
    version="1.0.0"
)

# CORS 配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 获取当前目录
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PARENT_DIR = os.path.dirname(BASE_DIR)


# ==================== 前端页面 ====================
@app.get("/", response_class=HTMLResponse)
async def root():
    """返回前端页面"""
    html_path = os.path.join(PARENT_DIR, "lol-league.html")
    with open(html_path, "r", encoding="utf-8") as f:
        content = f.read()
    return content


@app.get("/api.js")
async def serve_api_js():
    """返回 api.js 文件"""
    api_path = os.path.join(PARENT_DIR, "api.js")
    with open(api_path, "r", encoding="utf-8") as f:
        content = f.read()
    # 修改 API_BASE 为相对路径
    content = content.replace("'http://localhost:3000/api'", "'/api'")
    return HttpResponse(content=content, media_type="application/javascript")


# ==================== 健康检查 ====================
@app.get("/api/health")
async def health_check():
    return {"status": "ok", "timestamp": datetime.utcnow().isoformat()}


# ==================== 认证接口 ====================
@app.post("/api/auth/register", response_model=Response)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """用户注册"""
    if user_data.password != user_data.passwordConfirm:
        return Response(success=False, message="两次密码不一致")

    existing = db.query(models.User).filter(models.User.username == user_data.username).first()
    if existing:
        return Response(success=False, message="用户名已存在")

    hashed_password = get_password_hash(user_data.password)
    user = models.User(
        username=user_data.username,
        hashed_password=hashed_password,
        is_admin=False
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # 创建访问令牌
    access_token = create_access_token(data={"sub": str(user.id)})

    return Response(
        success=True,
        message="注册成功",
        token=access_token,
        user={"id": user.id, "username": user.username, "isAdmin": user.is_admin}
    )


@app.post("/api/auth/login", response_model=Response)
async def login(user_data: UserLogin, db: Session = Depends(get_db)):
    """用户登录"""
    user = db.query(models.User).filter(models.User.username == user_data.username).first()
    if not user or not verify_password(user_data.password, user.hashed_password):
        return Response(success=False, message="用户名或密码错误")

    access_token = create_access_token(data={"sub": str(user.id)})

    return Response(
        success=True,
        message="登录成功",
        token=access_token,
        user={"id": user.id, "username": user.username, "isAdmin": user.is_admin}
    )


@app.get("/api/auth/me", response_model=Response)
async def get_me(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """获取当前用户信息"""
    player = db.query(models.Player).filter(models.Player.user_id == current_user.id).first()
    player_data = None
    if player:
        player_data = {
            "id": player.id,
            "userId": player.user_id,
            "matchName": player.match_name,
            "gameId": player.game_id or "",
            "regionGroup": player.region_group,
            "regionSmall": player.region_small or "",
            "position": player.position,
            "onlineTime": player.online_time or "",
            "bio": player.bio or "",
            "avatar": player.avatar or "",
            "wins": player.wins,
            "losses": player.losses,
            "kills": player.kills,
            "deaths": player.deaths,
            "assists": player.assists,
            "mvpCount": player.mvp_count,
            "gamesPlayed": player.games_played,
            "winStreak": player.win_streak,
            "winRate": player.win_rate,
            "kda": player.kda
        }

    return Response(
        success=True,
        message="成功",
        data={"player": player_data},
        user={"id": current_user.id, "username": current_user.username, "isAdmin": current_user.is_admin}
    )


# ==================== 选手接口 ====================
@app.get("/api/players", response_model=ListResponse)
async def get_players(
    region: Optional[str] = None,
    position: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """获取所有选手"""
    query = db.query(models.Player)
    if region:
        # 支持小区筛选，如果 region_small 匹配则通过
        query = query.filter(
            (models.Player.region_group == region) |
            (models.Player.region_small == region)
        )
    if position:
        query = query.filter(models.Player.position == position)

    players = query.all()
    player_list = [{
        "id": p.id,
        "userId": p.user_id,
        "matchName": p.match_name,
        "gameId": p.game_id or "",
        "regionGroup": p.region_group,
        "regionSmall": p.region_small or "",
        "position": p.position,
        "onlineTime": p.online_time or "",
        "bio": p.bio or "",
        "avatar": p.avatar or "",
        "wins": p.wins,
        "losses": p.losses,
        "kills": p.kills,
        "deaths": p.deaths,
        "assists": p.assists,
        "mvpCount": p.mvp_count,
        "gamesPlayed": p.games_played,
        "winStreak": p.win_streak,
        "winRate": p.win_rate,
        "kda": p.kda
    } for p in players]

    return ListResponse(success=True, data=player_list)


@app.get("/api/players/me/current", response_model=Response)
async def get_current_player(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """获取当前用户的选手"""
    player = db.query(models.Player).filter(models.Player.user_id == current_user.id).first()
    if not player:
        return Response(success=False, message="未找到选手信息")

    return Response(
        success=True,
        message="成功",
        data={"player": {
            "id": player.id,
            "userId": player.user_id,
            "matchName": player.match_name,
            "gameId": player.game_id or "",
            "regionGroup": player.region_group,
            "position": player.position,
            "onlineTime": player.online_time or "",
            "bio": player.bio or "",
            "avatar": player.avatar or "",
            "wins": player.wins,
            "losses": player.losses,
            "kills": player.kills,
            "deaths": player.deaths,
            "assists": player.assists,
            "mvpCount": player.mvp_count,
            "gamesPlayed": player.games_played,
            "winStreak": player.win_streak,
            "winRate": player.win_rate,
            "kda": player.kda
        }}
    )


@app.post("/api/players", response_model=Response)
async def create_or_update_player(
    player_data: PlayerCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """创建或更新选手"""
    if not player_data.matchName or not player_data.regionGroup:
        return Response(success=False, message="召唤师名称和所属大区不能为空")

    existing_player = db.query(models.Player).filter(models.Player.user_id == current_user.id).first()

    if existing_player:
        existing_player.match_name = player_data.matchName
        existing_player.game_id = player_data.gameId
        existing_player.region_group = player_data.regionGroup
        existing_player.region_small = player_data.regionSmall
        existing_player.position = player_data.position
        existing_player.online_time = player_data.onlineTime
        existing_player.bio = player_data.bio
        db.commit()
        db.refresh(existing_player)
        player = existing_player
        message = "选手信息更新成功"
    else:
        player = models.Player(
            user_id=current_user.id,
            match_name=player_data.matchName,
            game_id=player_data.gameId,
            region_group=player_data.regionGroup,
            region_small=player_data.regionSmall,
            position=player_data.position,
            online_time=player_data.onlineTime,
            bio=player_data.bio
        )
        db.add(player)
        db.commit()
        db.refresh(player)
        message = "选手创建成功"

    return Response(
        success=True,
        message=message,
        data={"player": {
            "id": player.id,
            "userId": player.user_id,
            "matchName": player.match_name,
            "gameId": player.game_id or "",
            "regionGroup": player.region_group,
            "regionSmall": player.region_small or "",
            "position": player.position,
            "onlineTime": player.online_time or "",
            "bio": player.bio or "",
            "wins": player.wins,
            "losses": player.losses,
            "kills": player.kills,
            "deaths": player.deaths,
            "assists": player.assists,
            "mvpCount": player.mvp_count,
            "gamesPlayed": player.games_played,
            "winStreak": player.win_streak,
            "winRate": player.win_rate,
            "kda": player.kda
        }}
    )


@app.get("/api/players/rankings/winrate", response_model=ListResponse)
async def get_winrate_ranking(db: Session = Depends(get_db)):
    """获取胜率榜"""
    players = db.query(models.Player).filter(models.Player.games_played >= 5).all()
    players.sort(key=lambda p: p.win_rate, reverse=True)
    return ListResponse(success=True, data=[{
        "id": p.id,
        "matchName": p.match_name,
        "winRate": p.win_rate,
        "gamesPlayed": p.games_played
    } for p in players[:10]])


@app.get("/api/players/rankings/kda", response_model=ListResponse)
async def get_kda_ranking(db: Session = Depends(get_db)):
    """获取KDA榜"""
    players = db.query(models.Player).filter(models.Player.games_played >= 5).all()
    players.sort(key=lambda p: p.kda, reverse=True)
    return ListResponse(success=True, data=[{
        "id": p.id,
        "matchName": p.match_name,
        "kda": p.kda,
        "gamesPlayed": p.games_played
    } for p in players[:10]])


@app.get("/api/players/rankings/mvp", response_model=ListResponse)
async def get_mvp_ranking(db: Session = Depends(get_db)):
    """获取MVP榜"""
    players = db.query(models.Player).filter(models.Player.games_played >= 5).all()
    players.sort(key=lambda p: p.mvp_count, reverse=True)
    return ListResponse(success=True, data=[{
        "id": p.id,
        "matchName": p.match_name,
        "mvpCount": p.mvp_count
    } for p in players[:10]])


# ==================== 战队接口 ====================
@app.get("/api/teams", response_model=ListResponse)
async def get_teams(region: Optional[str] = None, db: Session = Depends(get_db)):
    """获取所有战队"""
    query = db.query(models.Team)
    if region:
        query = query.filter(
            (models.Team.region_group == region) |
            (models.Team.region_small == region)
        )

    teams = query.all()
    team_list = []
    for t in teams:
        captain = db.query(models.Player).filter(models.Player.id == t.captain_id).first()
        members = db.query(models.Player).filter(models.Player.team_id == t.id).all()
        team_list.append({
            "id": t.id,
            "name": t.name,
            "logo": t.logo,
            "captainId": t.captain_id,
            "captain": {"id": captain.id, "matchName": captain.match_name, "position": captain.position} if captain else None,
            "regionGroup": t.region_group,
            "regionSmall": t.region_small or "",
            "description": t.description or "",
            "level": t.level,
            "wins": t.wins,
            "losses": t.losses,
            "winStreak": t.win_streak,
            "score": t.score,
            "memberCount": len(members),
            "members": [{"id": m.id, "matchName": m.match_name, "position": m.position} for m in members],
            "recruitStatus": t.recruit_status
        })

    return ListResponse(success=True, data=team_list)


@app.get("/api/teams/{team_id}", response_model=Response)
async def get_team(team_id: int, db: Session = Depends(get_db)):
    """获取单个战队"""
    team = db.query(models.Team).filter(models.Team.id == team_id).first()
    if not team:
        return Response(success=False, message="战队不存在")

    captain = db.query(models.Player).filter(models.Player.id == team.captain_id).first()
    members = db.query(models.Player).filter(models.Player.team_id == team.id).all()

    return Response(success=True, message="成功", data={
        "id": team.id,
        "name": team.name,
        "logo": team.logo,
        "captainId": team.captain_id,
        "captain": {"id": captain.id, "matchName": captain.match_name, "position": captain.position} if captain else None,
        "regionGroup": team.region_group,
        "regionSmall": team.region_small or "",
        "description": team.description or "",
        "level": team.level,
        "wins": team.wins,
        "losses": team.losses,
        "winStreak": team.win_streak,
        "score": team.score,
        "memberCount": len(members),
        "members": [{"id": m.id, "matchName": m.match_name, "position": m.position} for m in members],
        "recruitStatus": team.recruit_status
    })


@app.post("/api/teams", response_model=Response)
async def create_team(
    team_data: TeamCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """创建战队"""
    if not team_data.name or not team_data.regionGroup:
        return Response(success=False, message="战队名称和所属大区不能为空")

    player = db.query(models.Player).filter(models.Player.user_id == current_user.id).first()
    if not player:
        return Response(success=False, message="请先创建选手身份")

    if player.team_id:
        return Response(success=False, message="你已经加入了一个战队")

    team = models.Team(
        name=team_data.name,
        logo=team_data.logo,
        captain_id=player.id,
        region_group=team_data.regionGroup,
        region_small=team_data.regionSmall,
        description=team_data.description
    )
    db.add(team)
    db.commit()
    db.refresh(team)

    player.team_id = team.id
    db.commit()

    return Response(success=True, message="战队创建成功", data={"team": {
        "id": team.id,
        "name": team.name,
        "logo": team.logo,
        "captainId": team.captain_id,
        "regionGroup": team.region_group,
        "regionSmall": team.region_small or ""
    }})


@app.post("/api/teams/{team_id}/recruit", response_model=Response)
async def join_team(
    team_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """加入战队"""
    player = db.query(models.Player).filter(models.Player.user_id == current_user.id).first()
    if not player:
        return Response(success=False, message="请先创建选手身份")

    if player.team_id:
        return Response(success=False, message="你已经加入了一个战队")

    team = db.query(models.Team).filter(models.Team.id == team_id).first()
    if not team:
        return Response(success=False, message="战队不存在")

    if len(db.query(models.Player).filter(models.Player.team_id == team_id).all()) >= 10:
        return Response(success=False, message="战队已满员")

    player.team_id = team_id
    db.commit()

    return Response(success=True, message="加入战队成功")


@app.post("/api/teams/{team_id}/leave", response_model=Response)
async def leave_team(
    team_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """退出战队"""
    player = db.query(models.Player).filter(models.Player.user_id == current_user.id).first()
    if not player or player.team_id != team_id:
        return Response(success=False, message="你不在这个战队中")

    team = db.query(models.Team).filter(models.Team.id == team_id).first()
    if team and team.captain_id == player.id:
        return Response(success=False, message="队长不能退出战队，请先解散战队")

    player.team_id = None
    db.commit()

    return Response(success=True, message="退出战队成功")


@app.delete("/api/teams/{team_id}", response_model=Response)
async def delete_team(
    team_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """解散战队"""
    player = db.query(models.Player).filter(models.Player.user_id == current_user.id).first()
    if not player or player.id != db.query(models.Team).filter(models.Team.id == team_id).first().captain_id:
        return Response(success=False, message="只有队长可以解散战队")

    db.query(models.Player).filter(models.Player.team_id == team_id).update({"team_id": None})
    db.query(models.Match).filter(models.Match.team_id == team_id).delete()
    db.query(models.Team).filter(models.Team.id == team_id).delete()
    db.commit()

    return Response(success=True, message="战队已解散")


@app.get("/api/teams/rankings/score", response_model=ListResponse)
async def get_score_ranking(db: Session = Depends(get_db)):
    """获取积分榜"""
    teams = db.query(models.Team).all()
    teams.sort(key=lambda t: t.score, reverse=True)
    return ListResponse(success=True, data=[{
        "id": t.id,
        "name": t.name,
        "logo": t.logo,
        "score": t.score
    } for t in teams[:10]])


@app.get("/api/teams/rankings/winStreak", response_model=ListResponse)
async def get_winstreak_ranking(db: Session = Depends(get_db)):
    """获取连胜榜"""
    teams = db.query(models.Team).all()
    teams.sort(key=lambda t: t.win_streak, reverse=True)
    return ListResponse(success=True, data=[{
        "id": t.id,
        "name": t.name,
        "logo": t.logo,
        "winStreak": t.win_streak
    } for t in teams[:10]])


# ==================== 约战接口 ====================
@app.get("/api/matches", response_model=ListResponse)
async def get_matches(
    status: Optional[str] = None,
    region: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """获取所有约战"""
    query = db.query(models.Match)

    if status:
        query = query.filter(models.Match.status == status)

    matches = query.order_by(models.Match.time.desc()).limit(100).all()

    match_list = []
    for m in matches:
        team = db.query(models.Team).filter(models.Team.id == m.team_id).first()
        opponent = db.query(models.Team).filter(models.Team.id == m.opponent_id).first() if m.opponent_id else None
        creator = db.query(models.User).filter(models.User.id == m.created_by).first()

        match_list.append({
            "id": m.id,
            "teamId": m.team_id,
            "team": {"id": team.id, "name": team.name, "logo": team.logo, "regionGroup": team.region_group, "regionSmall": team.region_small or ""} if team else None,
            "opponentId": m.opponent_id,
            "opponent": {"id": opponent.id, "name": opponent.name, "logo": opponent.logo, "regionGroup": opponent.region_group, "regionSmall": opponent.region_small or ""} if opponent else None,
            "mode": m.mode,
            "time": m.time.isoformat() if m.time else None,
            "status": m.status,
            "note": m.note,
            "createdBy": m.created_by,
            "creatorUsername": creator.username if creator else None,
            "screenshot": m.screenshot or "",
            "reviewedBy": m.reviewed_by,
            "reviewedAt": m.reviewed_at.isoformat() if m.reviewed_at else None,
            "rejectReason": m.reject_reason or ""
        })

    return ListResponse(success=True, data=match_list)


@app.get("/api/matches/{match_id}", response_model=Response)
async def get_match(match_id: int, db: Session = Depends(get_db)):
    """获取单个约战"""
    m = db.query(models.Match).filter(models.Match.id == match_id).first()
    if not m:
        return Response(success=False, message="约战不存在")

    team = db.query(models.Team).filter(models.Team.id == m.team_id).first()
    opponent = db.query(models.Team).filter(models.Team.id == m.opponent_id).first() if m.opponent_id else None

    return Response(success=True, message="成功", data={
        "id": m.id,
        "teamId": m.team_id,
        "team": {"id": team.id, "name": team.name, "logo": team.logo, "regionGroup": team.region_group, "regionSmall": team.region_small or ""} if team else None,
        "opponentId": m.opponent_id,
        "opponent": {"id": opponent.id, "name": opponent.name, "logo": opponent.logo, "regionGroup": opponent.region_group, "regionSmall": opponent.region_small or ""} if opponent else None,
        "mode": m.mode,
        "time": m.time.isoformat() if m.time else None,
        "status": m.status,
        "note": m.note,
        "winnerId": m.winner_id,
        "loserId": m.loser_id,
        "mvpPlayerId": m.mvp_player_id,
        "screenshot": m.screenshot or "",
        "reviewedBy": m.reviewed_by,
        "reviewedAt": m.reviewed_at.isoformat() if m.reviewed_at else None,
        "rejectReason": m.reject_reason or ""
    })


@app.post("/api/matches", response_model=Response)
async def create_match(
    match_data: MatchCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """发布约战"""
    player = db.query(models.Player).filter(models.Player.user_id == current_user.id).first()
    if not player or not player.team_id:
        return Response(success=False, message="请先加入一个战队")

    match = models.Match(
        team_id=match_data.teamId,
        mode=match_data.mode,
        time=match_data.time if match_data.time else datetime.now(),
        note=match_data.note,
        status="待审核",
        created_by=current_user.id
    )
    db.add(match)
    db.commit()
    db.refresh(match)

    return Response(success=True, message="约战发布成功，请等待管理员审核", data={"match": {
        "id": match.id,
        "teamId": match.team_id,
        "status": match.status
    }})


@app.post("/api/matches/{match_id}/accept", response_model=Response)
async def accept_match(
    match_id: int,
    match_data: MatchAccept,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """应战"""
    player = db.query(models.Player).filter(models.Player.user_id == current_user.id).first()
    if not player or not player.team_id:
        return Response(success=False, message="请先加入一个战队")

    match = db.query(models.Match).filter(models.Match.id == match_id).first()
    if not match:
        return Response(success=False, message="约战不存在")

    if match.status != "待应战":
        return Response(success=False, message="该约战当前不接受应战")

    if match.team_id == player.team_id:
        return Response(success=False, message="不能应战自己的战队")

    match.opponent_id = player.team_id
    match.status = "已约战"
    db.commit()

    return Response(success=True, message="应战成功")


@app.post("/api/matches/{match_id}/cancel", response_model=Response)
async def cancel_match(
    match_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """取消约战"""
    match = db.query(models.Match).filter(models.Match.id == match_id).first()
    if not match:
        return Response(success=False, message="约战不存在")

    if match.created_by != current_user.id and not current_user.is_admin:
        return Response(success=False, message="只有发布者或管理员可以取消约战")

    match.status = "已取消"
    db.commit()

    return Response(success=True, message="约战已取消")


@app.post("/api/matches/{match_id}/review", response_model=Response)
async def review_match(
    match_id: int,
    review_data: MatchReviewRequest,
    current_user: models.User = Depends(admin_required),
    db: Session = Depends(get_db)
):
    """审核约战（需管理员权限）"""
    match = db.query(models.Match).filter(models.Match.id == match_id).first()
    if not match:
        return Response(success=False, message="约战不存在")

    if match.status != "待审核":
        return Response(success=False, message="该约战不在待审核状态")

    if review_data.action == "approve":
        match.status = "待应战"
        match.reviewed_by = current_user.id
        match.reviewed_at = datetime.utcnow()
        db.commit()
        return Response(success=True, message="约战审核通过")
    elif review_data.action == "reject":
        match.status = "未通过"
        match.reviewed_by = current_user.id
        match.reviewed_at = datetime.utcnow()
        match.reject_reason = review_data.rejectReason
        db.commit()
        return Response(success=True, message="约战已驳回")
    else:
        return Response(success=False, message="无效的审核操作")


@app.post("/api/matches/{match_id}/screenshot", response_model=Response)
async def upload_screenshot(
    match_id: int,
    screenshot_data: MatchScreenshotUpload,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """上传战绩截图"""
    match = db.query(models.Match).filter(models.Match.id == match_id).first()
    if not match:
        return Response(success=False, message="约战不存在")

    if match.status not in ["已约战", "已结束"]:
        return Response(success=False, message="当前状态不允许上传截图")

    # 检查是否为队长
    team = db.query(models.Team).filter(models.Team.id == match.team_id).first()
    player = db.query(models.Player).filter(models.Player.user_id == current_user.id).first()

    if not player or team.captain_id != player.id:
        return Response(success=False, message="只有队长可以上传截图")

    match.screenshot = screenshot_data.screenshot
    db.commit()

    return Response(success=True, message="截图上传成功")


@app.post("/api/matches/{match_id}/result", response_model=Response)
async def submit_result(
    match_id: int,
    result_data: MatchResultSubmit,
    current_user: models.User = Depends(admin_required),
    db: Session = Depends(get_db)
):
    """录入战绩（需管理员权限）"""
    match = db.query(models.Match).filter(models.Match.id == match_id).first()
    if not match:
        return Response(success=False, message="约战不存在")

    if match.status not in ["已约战"]:
        return Response(success=False, message="当前状态不允许录入战绩")

    winner_team = db.query(models.Team).filter(models.Team.id == result_data.winnerId).first()
    loser_team = db.query(models.Team).filter(models.Team.id == result_data.loserId).first()

    if not winner_team or not loser_team:
        return Response(success=False, message="战队不存在")

    # 更新约战状态
    match.winner_id = result_data.winnerId
    match.loser_id = result_data.loserId
    match.status = "已结束"

    # 计算MVP
    mvp_player_id = None
    best_kda = 0

    # 获取胜方队伍的选手ID列表
    winner_player_ids = [p["playerId"] for p in result_data.playerStats
                         if p.get("playerId") and p.get("teamId") == result_data.winnerId]

    for ps in result_data.playerStats:
        player = db.query(models.Player).filter(models.Player.id == ps["playerId"]).first()
        if not player:
            continue

        player.games_played += 1
        player.kills += ps.get("kills", 0)
        player.deaths += ps.get("deaths", 0)
        player.assists += ps.get("assists", 0)

        # 根据选手所在队伍判断胜负
        if ps["playerId"] in winner_player_ids:
            player.wins += 1
        else:
            player.losses += 1

        kda = (ps.get("kills", 0) + ps.get("assists", 0)) / max(ps.get("deaths", 1), 1)
        if kda > best_kda:
            best_kda = kda
            mvp_player_id = ps["playerId"]

    if mvp_player_id:
        mvp_player = db.query(models.Player).filter(models.Player.id == mvp_player_id).first()
        if mvp_player:
            mvp_player.mvp_count += 1
        match.mvp_player_id = mvp_player_id

    # 更新战队战绩
    winner_team.wins += 1
    winner_team.score += 3
    winner_team.win_streak = winner_team.win_streak + 1 if winner_team.win_streak >= 0 else 1

    loser_team.losses += 1
    loser_team.win_streak = 0

    db.commit()

    return Response(success=True, message="战绩录入成功")


@app.get("/api/matches/results/list", response_model=Response)
async def get_match_results(limit: int = 20, offset: int = 0, db: Session = Depends(get_db)):
    """获取战绩列表"""
    matches = db.query(models.Match).filter(models.Match.status == "已结束").order_by(models.Match.id.desc()).limit(limit).offset(offset).all()

    results = []
    for m in matches:
        results.append({
            "id": m.id,
            "matchId": m.id,
            "winnerId": m.winner_id,
            "loserId": m.loser_id,
            "mvpPlayerId": m.mvp_player_id,
            "createdAt": m.time.isoformat() if m.time else None
        })

    return Response(success=True, message="成功", data={"results": results, "total": len(results)})


# ==================== 用户管理接口 ====================
@app.get("/api/users", response_model=ListResponse)
async def get_users(
    current_user: models.User = Depends(admin_required),
    db: Session = Depends(get_db)
):
    """获取所有用户（需管理员权限）"""
    users = db.query(models.User).all()
    return ListResponse(success=True, data=[{
        "id": u.id,
        "username": u.username,
        "isAdmin": u.is_admin
    } for u in users])


@app.put("/api/users/{user_id}/admin", response_model=Response)
async def set_admin(
    user_id: int,
    is_admin: bool = True,
    current_user: models.User = Depends(admin_required),
    db: Session = Depends(get_db)
):
    """设置管理员"""
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        return Response(success=False, message="用户不存在")

    user.is_admin = is_admin
    db.commit()

    return Response(success=True, message=f"{'设为' if is_admin else '取消'}管理员成功")


# ==================== 统计接口 ====================
@app.get("/api/stats/overview", response_model=Response)
async def get_overview(db: Session = Depends(get_db)):
    """获取平台统计"""
    players = db.query(models.Player).all()
    teams = db.query(models.Team).all()
    matches = db.query(models.Match).filter(models.Match.status == "已结束").all()

    total_kills = sum(p.kills for p in players)
    total_assists = sum(p.assists for p in players)
    total_mvp = sum(p.mvp_count for p in players)

    return Response(success=True, message="成功", data={
        "players": len(players),
        "teams": len(teams),
        "totalMatches": len(matches),
        "totalKills": total_kills,
        "totalAssists": total_assists,
        "totalMVP": total_mvp
    })


@app.get("/api/stats/public", response_model=Response)
async def get_public_stats(db: Session = Depends(get_db)):
    """获取公开统计"""
    players = db.query(models.Player).all()
    teams = db.query(models.Team).all()
    matches = db.query(models.Match).all()

    return Response(success=True, message="成功", data={
        "players": len(players),
        "teams": len(teams),
        "matches": len(matches)
    })


@app.post("/api/stats/reset", response_model=Response)
async def reset_data(
    current_user: models.User = Depends(admin_required),
    db: Session = Depends(get_db)
):
    """重置所有数据"""
    db.query(models.Match).delete()
    db.query(models.Player).update({"team_id": None, "wins": 0, "losses": 0, "kills": 0, "deaths": 0, "assists": 0, "mvp_count": 0, "games_played": 0, "win_streak": 0})
    db.query(models.Team).delete()
    db.query(models.User).filter(models.User.id != current_user.id).delete()
    db.commit()

    return Response(success=True, message="数据已重置")


@app.post("/api/stats/clear-results", response_model=Response)
async def clear_results(
    current_user: models.User = Depends(admin_required),
    db: Session = Depends(get_db)
):
    """清空战绩"""
    db.query(models.Match).delete()
    db.query(models.Player).update({"wins": 0, "losses": 0, "kills": 0, "deaths": 0, "assists": 0, "mvp_count": 0, "games_played": 0, "win_streak": 0})
    db.query(models.Team).update({"wins": 0, "losses": 0, "win_streak": 0, "score": 0})
    db.commit()

    return Response(success=True, message="战绩已清空")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)
