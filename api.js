/**
 * API 服务层 - 英雄联盟业余联赛平台
 * 与后端 FastAPI 交互
 */

const API_BASE = 'http://localhost:3000/api';

// 获取 token
function getToken() {
    return localStorage.getItem('lol_league_token');
}

// 设置 token
function setToken(token) {
    localStorage.setItem('lol_league_token', token);
}

// 清除 token
function clearToken() {
    localStorage.removeItem('lol_league_token');
}

// 通用请求函数
async function request(endpoint, options = {}) {
    const url = `${API_BASE}${endpoint}`;
    const token = getToken();

    const headers = {
        'Content-Type': 'application/json',
        ...options.headers
    };

    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    try {
        const response = await fetch(url, {
            ...options,
            headers
        });

        const data = await response.json();
        return data;
    } catch (error) {
        console.error('API 请求失败:', error);
        throw error;
    }
}

// API 对象
const API = {
    // 检查是否已登录
    isLoggedIn() {
        return !!getToken();
    },

    // 获取当前选手ID
    getPlayerId() {
        return localStorage.getItem('lol_league_current_player_id');
    },

    // 认证相关
    Auth: {
        async register(username, password, passwordConfirm, inviteCode = '') {
            return request('/auth/register', {
                method: 'POST',
                body: JSON.stringify({
                    username,
                    password,
                    passwordConfirm,
                    inviteCode
                })
            });
        },

        async login(username, password) {
            const result = await request('/auth/login', {
                method: 'POST',
                body: JSON.stringify({ username, password })
            });
            if (result.token) {
                setToken(result.token);
            }
            return result;
        },

        async getCurrentUser() {
            return request('/auth/me');
        },

        logout() {
            clearToken();
            localStorage.removeItem('lol_league_current_player_id');
            localStorage.removeItem('lol_league_current_user');
        }
    },

    // 选手相关
    Player: {
        async getAll() {
            const result = await request('/players');
            return result.data || [];
        },

        async getCurrentPlayer() {
            const result = await request('/players/me/current');
            return result.data?.player || null;
        },

        async save(playerData) {
            return request('/players', {
                method: 'POST',
                body: JSON.stringify(playerData)
            });
        },

        async getWinRateRanking() {
            const result = await request('/players/rankings/winrate');
            return result.data || [];
        },

        async getKDARanking() {
            const result = await request('/players/rankings/kda');
            return result.data || [];
        },

        async getMVPRanking() {
            const result = await request('/players/rankings/mvp');
            return result.data || [];
        }
    },

    // 战队相关
    Team: {
        async getAll() {
            const result = await request('/teams');
            return result.data || [];
        },

        async getById(id) {
            const result = await request(`/teams/${id}`);
            return result.data || null;
        },

        async create(teamData) {
            return request('/teams', {
                method: 'POST',
                body: JSON.stringify(teamData)
            });
        },

        async delete(id) {
            return request(`/teams/${id}`, {
                method: 'DELETE'
            });
        },

        async join(teamId) {
            return request(`/teams/${teamId}/recruit`, {
                method: 'POST'
            });
        },

        async leave(teamId) {
            return request(`/teams/${teamId}/leave`, {
                method: 'POST'
            });
        },

        async invite(teamId, playerId) {
            return request(`/teams/${teamId}/invite`, {
                method: 'POST',
                body: JSON.stringify({ playerId })
            });
        },

        async getScoreRanking() {
            const result = await request('/teams/rankings/score');
            return result.data || [];
        },

        async getWinStreakRanking() {
            const result = await request('/teams/rankings/winStreak');
            return result.data || [];
        }
    },

    // 约战相关
    Match: {
        async getAll(params = {}) {
            const queryParams = new URLSearchParams(params).toString();
            const endpoint = queryParams ? `/matches?${queryParams}` : '/matches';
            const result = await request(endpoint);
            return result.data || [];
        },

        async getById(id) {
            const result = await request(`/matches/${id}`);
            return result.data || null;
        },

        async create(matchData) {
            return request('/matches', {
                method: 'POST',
                body: JSON.stringify(matchData)
            });
        },

        async accept(matchId, opponentTeamId) {
            return request(`/matches/${matchId}/accept`, {
                method: 'POST',
                body: JSON.stringify({ opponentTeamId })
            });
        },

        async cancel(matchId) {
            return request(`/matches/${matchId}/cancel`, {
                method: 'POST'
            });
        },

        async submitResult(matchId, resultData) {
            return request(`/matches/${matchId}/result`, {
                method: 'POST',
                body: JSON.stringify(resultData)
            });
        },

        async getResults(limit = 20, offset = 0) {
            const result = await request(`/matches/results/list?limit=${limit}&offset=${offset}`);
            return result.data || [];
        },

        async review(matchId, action, rejectReason = '') {
            return request(`/matches/${matchId}/review`, {
                method: 'POST',
                body: JSON.stringify({ action, rejectReason })
            });
        },

        async uploadScreenshot(matchId, screenshot) {
            return request(`/matches/${matchId}/screenshot`, {
                method: 'POST',
                body: JSON.stringify({ screenshot })
            });
        }
    },

    // 用户相关
    User: {
        async getAll() {
            const result = await request('/users');
            return result.data || [];
        },

        async setAdmin(userId, isAdmin) {
            return request(`/users/${userId}/admin`, {
                method: 'PUT',
                body: JSON.stringify({ isAdmin })
            });
        },

        async delete(userId) {
            return request(`/users/${userId}`, {
                method: 'DELETE'
            });
        }
    },

    // 选手统计更新
    PlayerStats: {
        async update(playerId, statsData) {
            return request(`/players/${playerId}/stats`, {
                method: 'PUT',
                body: JSON.stringify(statsData)
            });
        }
    },

    // 战队统计更新
    TeamStats: {
        async update(teamId, statsData) {
            return request(`/teams/${teamId}/stats`, {
                method: 'PUT',
                body: JSON.stringify(statsData)
            });
        }
    },

    // 通知相关
    Notification: {
        async getAll() {
            const result = await request('/notifications');
            return result.data || [];
        },

        async markAsRead(notificationId) {
            return request(`/notifications/${notificationId}`, {
                method: 'PUT',
                body: JSON.stringify({ read: true })
            });
        },

        async accept(notificationId) {
            return request(`/notifications/${notificationId}`, {
                method: 'PUT',
                body: JSON.stringify({ status: 'accepted' })
            });
        },

        async reject(notificationId) {
            return request(`/notifications/${notificationId}`, {
                method: 'PUT',
                body: JSON.stringify({ status: 'rejected' })
            });
        },

        async getUnreadCount() {
            const result = await request('/notifications/unread-count');
            return result.data?.count || 0;
        }
    },

    // 统计相关
    Stats: {
        async getOverview() {
            const result = await request('/stats/overview');
            return result.data || null;
        },

        async getPublic() {
            const result = await request('/stats/public');
            return result.data || null;
        },

        async reset() {
            return request('/stats/reset', {
                method: 'POST'
            });
        },

        async clearResults() {
            return request('/stats/clear-results', {
                method: 'POST'
            });
        }
    }
};
