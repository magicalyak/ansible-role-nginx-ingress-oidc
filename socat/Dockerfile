FROM debian:buster-slim

LABEL maintainer="NGINX Docker Maintainers <docker-maint@nginx.com>"

# Install socat
RUN set -x \
  && apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends --no-install-suggests -y apt-transport-https ca-certificates gnupg1 socat \
  && apt-get remove --purge --auto-remove -y gnupg1 \
  && rm -rf /var/lib/apt/lists/*

# Create custom startup script
ARG DOMAIN
ARG PROXY_AUTH
ARG PROXY_IP
ARG PROXY_PORT
ARG SOCAT_PORT
ENV DOMAIN=$DOMAIN
ENV PROXY_AUTH=$PROXY_AUTH
ENV PROXY_IP=$PROXY_IP
ENV PROXY_PORT=$PROXY_PORT
ENV SOCAT_PORT=$SOCAT_PORT

WORKDIR /
RUN printf "#!/bin/sh\n\n" > start.sh \
  && printf "socat -d -d -lf /var/log/socat.log TCP4-LISTEN:${SOCAT_PORT},reuseaddr,fork PROXY:${PROXY_IP}:${DOMAIN},proxyport=${PROXY_PORT},proxyauth=${PROXY_AUTH}" >> start.sh \
  && chmod +x start.sh \
  && touch /var/log/socat.log
RUN printf "#!/bin/sh\n\n" > start2.sh \
  && printf "socat -d -d -lf /var/log/socat.log TCP4-LISTEN:$SOCAT_PORT,reuseaddr,fork PROXY:$PROXY_IP:$DOMAIN,proxyport=$PROXY_PORT,proxyauth=$PROXY_AUTH" >> start2.sh \
  && chmod +x start2.sh

# Forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/socat.log

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["sh", "/start2.sh"]
