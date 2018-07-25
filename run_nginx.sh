#!/bin/bash
if [ "x${ECS_ALB_PROXY_ONLY}" != "x" ]; then
  echo "Replacing the Procfile/default.conf since ECS_ALB_PROXY_ONLY=${ECS_ALB_PROXY_ONLY}"
  cp -rf /app/Procfile.ecs_alb_only /app/Procfile
  cp -rf /app/default.conf.ecs_alb_only /etc/nginx/conf.d/default.conf
  echo "Setting the Virtual host endpoint: $VIRTUAL_HOST"
  sed -i "s!_VIRTUAL_HOST_!$VIRTUAL_HOST!g" /etc/nginx/conf.d/default.conf
  echo "Grabbing local ecs instance ip address"
  HOST_ADDRESS=$(wget --connect-timeout=5 -qO- http://169.254.169.254/latest/meta-data/local-ipv4)
  if [ ! -z "${HOST_ADDRESS}" ]; then
    echo "EC2 detected"
    sed -i "s!_HOST_ADDRESS_!$HOST_ADDRESS!g" /etc/nginx/conf.d/default.conf
  else
    sed -i "s!_HOST_ADDRESS_!localhost!g" /etc/nginx/conf.d/default.conf
  fi
  echo "Fixing up default_location file with health check path: $HEALTH_CHECK_PATH"
  sed -i "s!HEALTH_CHECK_PATH!$HEALTH_CHECK_PATH!g" /etc/nginx/vhost.d/default_location
  SHOULD_RETURN_HEALTHY='return 200 "healthy\\n";'
  echo "Returning healthy directly instead of redirecting."
  sed -i "s!_SHOULD_RETURN_HEALTHY_!$SHOULD_RETURN_HEALTHY!g" /etc/nginx/vhost.d/default_location
else

  echo "Fixing up default_location file with health check url: $HEALTH_CHECK_PATH"
  sed -i "s!HEALTH_CHECK_PATH!$HEALTH_CHECK_PATH!g" /etc/nginx/vhost.d/default_location
  sed -i "!_SHOULD_RETURN_HEALTHY_!d" /etc/nginx/vhost.d/default_location
fi

echo "Starting up NGINX"
forego start -r
