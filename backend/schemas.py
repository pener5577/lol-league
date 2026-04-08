"""
Pydantic 模型 - 请求/响应验证
保持 snake_case 与 SQLAlchemy 一致
"""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


# ==================== 用户相关 ====================
class UserCreate(BaseModel):
    username: str
    password: str
    passwordConfirm: str
    inviteCode: str = ""


class UserLogin(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: int
    username: str
    isAdmin: bool = False
    playerId: Optional[int] = None
    createdAt: Optional[datetime] = None


class AuthResponse(BaseModel):
    success: bool
    message: str
    token: Optional[str] = None
    user: Optional[dict] = None
    data: Optional[dict] = None


# ==================== 选手相关 ====================
class PlayerCreate(BaseModel):
    matchName: str
    gameId: str = ""
    regionGroup: str  # 大区名称
    regionSmall: str = ""  # 小区名称
    position: str = "全能"
    onlineTime: str = ""
    bio: str = ""


class PlayerResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: int
    userId: int
    matchName: str
    gameId: str = ""
    regionGroup: str
    regionSmall: str = ""
    position: str = "全能"
    onlineTime: str = ""
    bio: str = ""
    avatar: str = ""
    wins: int = 0
    losses: int = 0
    kills: int = 0
    deaths: int = 0
    assists: int = 0
    mvpCount: int = 0
    gamesPlayed: int = 0
    winStreak: int = 0
    winRate: int = 0
    kda: float = 0.0
    createdAt: Optional[datetime] = None
    updatedAt: Optional[datetime] = None


# ==================== 战队相关 ====================
class TeamCreate(BaseModel):
    name: str
    logo: str = "fa-shield-alt"
    regionGroup: str  # 大区名称
    regionSmall: str = ""  # 小区名称
    description: str = ""


class TeamUpdate(BaseModel):
    name: Optional[str] = None
    logo: Optional[str] = None
    description: Optional[str] = None


class TeamResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: int
    name: str
    logo: str
    captainId: int
    regionGroup: str
    regionSmall: str = ""
    description: str = ""
    level: str = "新手"
    wins: int = 0
    losses: int = 0
    winStreak: int = 0
    score: int = 0
    memberCount: int = 0
    createdAt: Optional[datetime] = None


class TeamDetailResponse(TeamResponse):
    captain: Optional[PlayerResponse] = None
    members: List[PlayerResponse] = []


# ==================== 约战相关 ====================
class MatchCreate(BaseModel):
    teamId: int
    mode: str = "5v5"
    time: datetime
    note: str = ""


class MatchAccept(BaseModel):
    opponentTeamId: int


class MatchReviewRequest(BaseModel):
    action: str  # "approve" 或 "reject"
    rejectReason: str = ""


class MatchScreenshotUpload(BaseModel):
    screenshot: str  # Base64 图片


class MatchResultSubmit(BaseModel):
    winnerId: int
    loserId: int
    playerStats: List[dict] = []


class MatchResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: int
    teamId: int
    opponentId: Optional[int] = None
    mode: str
    time: datetime
    status: str
    note: str
    createdBy: int
    winnerId: Optional[int] = None
    loserId: Optional[int] = None
    mvpPlayerId: Optional[int] = None
    createdAt: Optional[datetime] = None
    screenshot: str = ""
    reviewedBy: Optional[int] = None
    reviewedAt: Optional[datetime] = None
    rejectReason: str = ""


# ==================== 通用响应 ====================
class Response(BaseModel):
    success: bool
    message: str
    token: Optional[str] = None
    user: Optional[dict] = None
    data: Optional[dict] = None


class ListResponse(BaseModel):
    success: bool
    data: List[dict]
    total: Optional[int] = None
    hasMore: Optional[bool] = None
