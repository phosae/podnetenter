FROM registry.k8s.io/pause:3.9 as pausebin
FROM zengxu/critools:v1.25.0 as crictlbin
FROM zengxu/cnitool-bdad953d72e3a879d1f458c51dbf1923 as cnitoolbin

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

COPY --from=pausebin /pause /usr/local/bin/pause
COPY --from=crictlbin /usr/bin/crictl /usr/local/bin/crictl
COPY --from=cnitoolbin /ko-app/cnitool /usr/local/bin/cnitool

ENTRYPOINT ["/entrypoint.sh"]
