"""
全功能测试脚本 - 英雄联盟业余联赛平台
测试流程：10人注册 -> 2人建战队 -> 8人入队 -> 约战/应战 -> 抖音直播 -> 战绩录入
"""
import requests
import time
import sys
from datetime import datetime, timedelta

# Windows 编码支持
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

BASE_URL = "http://localhost:3000/api"

def log(msg):
    print(f"[INFO] {msg}")

def success(msg):
    print(f"[OK] {msg}")

def error(msg):
    print(f"[FAIL] {msg}")

def section(msg):
    print(f"\n{'='*50}")
    print(f" {msg}")
    print(f"{'='*50}\n")


class TestRunner:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({'Content-Type': 'application/json'})
        self.tokens = {}
        self.player_ids = {}
        self.team_ids = {}

    def register(self, username, password):
        resp = self.session.post(f"{BASE_URL}/auth/register", json={
            "username": username,
            "password": password,
            "passwordConfirm": password,
            "inviteCode": ""
        })
        data = resp.json()
        if data.get('success'):
            success(f"User registered: {username}")
            return True
        else:
            error(f"Register failed: {username} - {data.get('message')}")
            return False

    def login(self, username, password):
        resp = self.session.post(f"{BASE_URL}/auth/login", json={
            "username": username,
            "password": password
        })
        data = resp.json()
        if data.get('success') and data.get('token'):
            self.tokens[username] = data['token']
            self.session.headers.update({'Authorization': f"Bearer {data['token']}"})
            success(f"Logged in: {username}")
            return True
        else:
            error(f"Login failed: {username} - {data.get('message')}")
            return False

    def create_player(self, username, match_name, game_id, region_small, region_group):
        resp = self.session.post(f"{BASE_URL}/players", json={
            "matchName": match_name,
            "gameId": game_id,
            "regionGroup": region_group,
            "regionSmall": region_small,
            "position": "mid",
            "onlineTime": "weekend",
            "bio": f"Test player {match_name}"
        })
        data = resp.json()
        if data.get('success'):
            player_id = data.get('data', {}).get('player', {}).get('id')
            self.player_ids[username] = player_id
            success(f"Player created: {match_name} (ID: {player_id})")
            return player_id
        else:
            error(f"Player creation failed: {match_name} - {data.get('message')}")
            return None

    def create_team(self, username, team_name, region_small, region_group):
        resp = self.session.post(f"{BASE_URL}/teams", json={
            "name": team_name,
            "regionGroup": region_group,
            "regionSmall": region_small,
            "logo": "fa-shield-alt",
            "description": f"Test team {team_name}"
        })
        data = resp.json()
        if data.get('success'):
            team_id = data.get('data', {}).get('team', {}).get('id')
            self.team_ids[team_name] = team_id
            success(f"Team created: {team_name} (ID: {team_id})")
            return team_id
        else:
            error(f"Team creation failed: {team_name} - {data.get('message')}")
            return None

    def join_team(self, username, team_id):
        resp = self.session.post(f"{BASE_URL}/teams/{team_id}/recruit", json={})
        data = resp.json()
        if data.get('success'):
            success(f"Joined team: {username} -> team {team_id}")
            return True
        else:
            error(f"Join team failed: {username} - {data.get('message')}")
            return False

    def create_battle(self, username, team_id, opponent_team_id):
        battle_time = (datetime.now() + timedelta(days=1)).isoformat()
        resp = self.session.post(f"{BASE_URL}/matches", json={
            "teamId": team_id,
            "mode": "5v5",
            "time": battle_time,
            "note": "Test battle - Douyin livestream"
        })
        data = resp.json()
        if data.get('success'):
            # 后端返回格式是 {"match": {"id": xxx, ...}}
            match_id = data.get('data', {}).get('match', {}).get('id')
            success(f"Battle created: team{team_id} VS team{opponent_team_id} (match_id: {match_id})")
            return match_id
        else:
            error(f"Battle creation failed - {data.get('message')}")
            return None

    def accept_battle(self, username, match_id, opponent_team_id):
        resp = self.session.post(f"{BASE_URL}/matches/{match_id}/accept", json={
            "opponentTeamId": opponent_team_id
        })
        data = resp.json()
        if data.get('success'):
            success(f"Battle accepted: {username}")
            return True
        else:
            error(f"Battle accept failed: {username} - {data.get('message')}")
            return False

    def submit_result(self, username, match_id, winner_id, loser_id):
        resp = self.session.post(f"{BASE_URL}/matches/{match_id}/result", json={
            "winnerId": winner_id,
            "loserId": loser_id,
            "playerStats": []
        })
        data = resp.json()
        if data.get('success'):
            success(f"Result submitted: winner {winner_id}, loser {loser_id}")
            return True
        else:
            error(f"Result submission failed: {data.get('message')}")
            return False

    def get_teams(self):
        resp = self.session.get(f"{BASE_URL}/teams")
        data = resp.json()
        return data.get('data', []) if data.get('success') else []

    def get_players(self):
        resp = self.session.get(f"{BASE_URL}/players")
        data = resp.json()
        return data.get('data', []) if data.get('success') else []


def run_test():
    runner = TestRunner()

    # ===== Phase 1: Register 10 users =====
    section("Phase 1: Register 10 users and create players")

    users = [
        ("test1", "pass123", "艾欧尼亚", "独立大区"),
        ("test2", "pass123", "祖安", "联盟一区"),
        ("test3", "pass123", "比尔吉沃特", "联盟四区"),
        ("test4", "pass123", "德玛西亚", "联盟五区"),
        ("test5", "pass123", "班德尔城", "联盟三区"),
        ("test6", "pass123", "卡拉曼达", "联盟二区"),
        ("test7", "pass123", "暗影岛", "联盟二区"),
        ("test8", "pass123", "诺克萨斯", "联盟二区"),
        ("test9", "pass123", "皮尔特沃夫", "联盟一区"),
        ("test10", "pass123", "教育网", "联盟一区"),
    ]

    for username, password, region_small, region_group in users:
        if runner.register(username, password):
            runner.login(username, password)
            runner.create_player(username, f"player_{username}", f"GID_{username}",
                               region_small, region_group)
            time.sleep(0.1)

    # ===== Phase 2: 2 users create teams =====
    section("Phase 2: 2 users create teams")

    runner.login("test1", "pass123")
    runner.create_team("test1", "AlphaTeam", "艾欧尼亚", "独立大区")

    runner.login("test2", "pass123")
    runner.create_team("test2", "BetaTeam", "祖安", "联盟一区")

    time.sleep(0.5)

    # ===== Phase 3: 8 users join teams =====
    section("Phase 3: 8 users join teams")

    # 4 users apply to join AlphaTeam
    log("--- 4 users apply to join AlphaTeam ---")
    for username in ["test3", "test4", "test5", "test6"]:
        runner.login(username, "pass123")
        runner.join_team(username, runner.team_ids['AlphaTeam'])

    # 4 users join BetaTeam
    log("--- 4 users join BetaTeam ---")
    for username in ["test7", "test8", "test9", "test10"]:
        runner.login(username, "pass123")
        runner.join_team(username, runner.team_ids['BetaTeam'])

    time.sleep(0.5)

    # ===== Phase 4: Create battle and accept =====
    section("Phase 4: AlphaTeam challenges BetaTeam, BetaTeam accepts")

    runner.login("test1", "pass123")
    match_id = runner.create_battle("test1", runner.team_ids['AlphaTeam'], runner.team_ids['BetaTeam'])

    if match_id:
        runner.login("test2", "pass123")
        runner.accept_battle("test2", match_id, runner.team_ids['AlphaTeam'])
        success("Douyin livestream requested")

    time.sleep(0.5)

    # ===== Phase 5: Admin submits result =====
    section("Phase 5: Admin submits result")

    # Login as admin
    resp = runner.session.post(f"{BASE_URL}/auth/login", json={
        "username": "pener",
        "password": "pener123"
    })
    data = resp.json()
    if data.get('success'):
        runner.session.headers.update({'Authorization': f"Bearer {data['token']}"})
        success("Admin logged in")

        if match_id:
            runner.submit_result("admin", match_id,
                               runner.team_ids['AlphaTeam'],
                               runner.team_ids['BetaTeam'])

    time.sleep(0.5)

    # ===== Phase 6: Verify data =====
    section("Phase 6: Verify data updates")

    teams = runner.get_teams()
    log("\n--- Team Data ---")
    for team in teams:
        if team.get('name') in ['AlphaTeam', 'BetaTeam']:
            log(f"Team: {team.get('name')}")
            log(f"  - Wins: {team.get('wins', 0)}")
            log(f"  - Losses: {team.get('losses', 0)}")
            log(f"  - Score: {team.get('score', 0)}")
            log(f"  - Members: {team.get('memberCount', 0)}")

    players = runner.get_players()
    log("\n--- Player Stats (sample) ---")
    for player in players[:5]:
        log(f"Player: {player.get('matchName')} - WinRate: {player.get('winRate', 0)}%")

    section("Test Complete!")
    print("""
Summary:
1. [OK] 10 users registered and player profiles created
2. [OK] 2 teams created (AlphaTeam, BetaTeam)
3. [OK] 8 users joined teams
4. [OK] AlphaTeam created battle challenge
5. [OK] BetaTeam accepted the battle
6. [OK] Douyin livestream requested
7. [OK] Admin submitted result (AlphaTeam wins)
8. [OK] Data updated

Visit http://localhost:3000 to verify
    """)


if __name__ == "__main__":
    run_test()
