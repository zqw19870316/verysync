FROM hub.atomgit.com/arm64v8/alpine
LABEL maintainer="www.mrdoc.fun"
ENV TZ=Asia/Shanghai \
    PORT=8886 \
    VUID=0
WORKDIR /app
COPY files/verysync-linux-amd64-*.tar.gz /tmp
COPY docker-entrypoint.sh /app
COPY qemu-aarch64-static /usr/bin/

RUN mkdir /usr/local/bin/gosu 
COPY files/gosu-amd64 /usr/local/bin/gosu

RUN apk add --no-cache tzdata bash \
    && tar -xzvf /tmp/verysync-linux-amd64-*.tar.gz -C /tmp \
    && chmod +x /tmp/verysync-linux-amd64-*/verysync \
    && mv /tmp/verysync-linux-amd64-*/verysync /usr/bin/ \
    && rm -rf /tmp \
    && mkdir -p /data \
    && chmod 777 /data \
    && addgroup -S nonverysync && adduser -S nonverysync -G nonverysync \
    && chmod +x /app/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/gosu \
    && gosu nobody true

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z 127.0.0.1 ${PORT}  || exit 1

ENTRYPOINT ["/app/docker-entrypoint.sh"]
  
#ENTRYPOINT ["sh","-c","gosu nonverysync /usr/bin/verysync -no-browser -home /data/.config -gui-address :${PORT}"] 
#ENTRYPOINT ["sh","-c","/usr/bin/verysync","-no-browser","-home","/data","-gui-address",":${PORT}"]
# CMD [":8886"]
