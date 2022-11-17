FROM registry.k8s.io/pause:3.9 as pausebin
FROM zengxu/critools:v1.25.0 as crictlbin

FROM alpine:3.17

RUN set -ex \
    && apk update \
    && apk upgrade \
    && apk add --no-cache \
    bash \
    iproute2 \
    iptables \
    iputils \
    tcpdump \
    jq

ADD entrypoint.sh /

COPY --from=pausebin /pause /pause
COPY --from=crictlbin /usr/bin/crictl /usr/local/bin/crictl

ENTRYPOINT ["/entrypoint.sh"]
