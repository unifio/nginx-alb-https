FROM jwilder/nginx-proxy:alpine

# Default health check url
ENV HEALTH_CHECK_PATH "/health_check_path"
COPY default_location /etc/nginx/vhost.d/
COPY run_nginx.sh /app/run_nginx.sh
COPY default.conf /app/default.conf.ecs_alb_only
COPY Procfile /app/Procfile.ecs_alb_only
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod a+x /app/docker-entrypoint.sh && chmod a+x /app/run_nginx.sh

CMD ["/app/run_nginx.sh"]

EXPOSE 80
