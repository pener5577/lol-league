"""
数据模型 - SQLAlchemy
"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text, Float
from sqlalchemy.orm import relationship
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(16), unique=True, index=True, nullable=False)
    hashed_password = Column(String(128), nullable=False)
    is_admin = Column(Boolean, default=False)
    player_id = Column(Integer, ForeignKey("players.id"), nullable=True)
    invite_code = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_login = Column(DateTime, nullable=True)


class Player(Base):
    __tablename__ = "players"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    team_id = Column(Integer, ForeignKey("teams.id"), nullable=True)  # 所属战队
    match_name = Column(String(50), nullable=False)
    game_id = Column(String(50), default="")
    region_group = Column(String(50), nullable=False)  # 大区名称（用于筛选）
    region_small = Column(String(50), default="")  # 小区名称
    position = Column(String(20), default="全能")
    online_time = Column(String(100), default="")
    bio = Column(Text, default="")
    avatar = Column(String(200), default="")

    # 统计数据
    wins = Column(Integer, default=0)
    losses = Column(Integer, default=0)
    kills = Column(Integer, default=0)
    deaths = Column(Integer, default=0)
    assists = Column(Integer, default=0)
    mvp_count = Column(Integer, default=0)
    games_played = Column(Integer, default=0)
    win_streak = Column(Integer, default=0)
    win_rate = Column(Integer, default=0)  # 胜率百分比
    kda = Column(Float, default=0.0)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class Team(Base):
    __tablename__ = "teams"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, nullable=False)
    logo = Column(String(50), default="fa-shield-alt")
    captain_id = Column(Integer, ForeignKey("players.id"), nullable=False)
    region_group = Column(String(50), nullable=False)  # 大区名称（用于筛选）
    region_small = Column(String(50), default="")  # 小区名称
    description = Column(Text, default="")
    level = Column(String(20), default="新手")

    # 统计数据
    wins = Column(Integer, default=0)
    losses = Column(Integer, default=0)
    win_streak = Column(Integer, default=0)
    score = Column(Integer, default=0)
    recruit_status = Column(String(20), default="招募中")  # 招募状态

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class TeamMember(Base):
    """战队成员关联表"""
    __tablename__ = "team_members"

    id = Column(Integer, primary_key=True, index=True)
    team_id = Column(Integer, ForeignKey("teams.id"), nullable=False)
    player_id = Column(Integer, ForeignKey("players.id"), nullable=False)
    joined_at = Column(DateTime, default=datetime.utcnow)


class Match(Base):
    __tablename__ = "matches"

    id = Column(Integer, primary_key=True, index=True)
    team_id = Column(Integer, ForeignKey("teams.id"), nullable=False)
    opponent_id = Column(Integer, ForeignKey("teams.id"), nullable=True)
    mode = Column(String(10), default="5v5")
    time = Column(DateTime, nullable=False)
    status = Column(String(20), default="待审核")
    note = Column(Text, default="")
    created_by = Column(Integer, ForeignKey("users.id"), nullable=False)

    winner_id = Column(Integer, ForeignKey("teams.id"), nullable=True)
    loser_id = Column(Integer, ForeignKey("teams.id"), nullable=True)
    mvp_player_id = Column(Integer, ForeignKey("players.id"), nullable=True)

    # 新增字段
    screenshot = Column(Text, default="")  # 战绩截图 (Base64)
    reviewed_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    reviewed_at = Column(DateTime, nullable=True)
    reject_reason = Column(Text, default="")

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class MatchResult(Base):
    __tablename__ = "match_results"

    id = Column(Integer, primary_key=True, index=True)
    match_id = Column(Integer, ForeignKey("matches.id"), nullable=False)
    winner_team_id = Column(Integer, ForeignKey("teams.id"), nullable=False)
    loser_team_id = Column(Integer, ForeignKey("teams.id"), nullable=False)
    mvp_player_id = Column(Integer, ForeignKey("players.id"), nullable=True)
    player_stats = Column(Text, default="[]")  # JSON 存储选手战绩
    recorded_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
