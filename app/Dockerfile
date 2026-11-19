# 기존 베이스 이미지: 공식 NGINX (alpine 변형, 경량)
FROM nginx:alpine

# 1) 메타데이터: 이미지 식별/관리용
LABEL org.opencontainers.image.title="codyssey-custom-nginx" \
      org.opencontainers.image.description="Codyssey workstation mission - custom static web server" \
      org.opencontainers.image.version="1.0"

# 2) 환경 변수: 실행 모드 표시 (설정과 코드 분리 연습)
ENV APP_ENV=dev

# 3) 서버 설정 교체: 커스텀 헤더 + /health 엔드포인트
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# 4) 정적 콘텐츠 교체
COPY site/ /usr/share/nginx/html/

# 5) 헬스체크: 컨테이너 상태를 docker ps 에서 healthy/unhealthy 로 확인
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health || exit 1

EXPOSE 80
