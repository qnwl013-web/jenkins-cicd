FROM nginx:alpine
# 안전한 디렉토리 복사를 위해 권한 설정
COPY --chown=nginx:nginx ./html /usr/share/nginx/html

