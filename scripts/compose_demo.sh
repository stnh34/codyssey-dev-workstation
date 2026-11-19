#!/usr/bin/env bash
# Compose 보너스 실습: 실행 후 결과를 표준출력으로 남긴다. (workstation/compose 에서 실행)
export MSYS_NO_PATHCONV=1
r(){ echo "\$ $*"; eval "$@" 2>&1; echo; }
r 'cat .env'
r 'docker compose config'
r 'docker compose up -d --build'
sleep 8
r 'docker compose ps'
r 'curl -si http://localhost:8090/health'
r 'docker compose exec web printenv APP_ENV'
r 'docker compose exec checker wget -qO- http://web/health'
r 'docker compose exec checker nslookup web'
r 'docker compose logs checker'
r 'docker compose logs --tail 3 web'
r 'docker network ls'
echo "# 환경변수로 포트/모드를 바꿔서 재기동"
r 'WEB_PORT=8095 APP_ENV=staging docker compose up -d'
sleep 4
r 'docker compose ps web'
r 'curl -s http://localhost:8095/health'
r 'docker compose exec web printenv APP_ENV'
r 'docker compose down'
r 'docker compose ps -a'
