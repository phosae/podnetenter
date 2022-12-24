FROM registry.k8s.io/pause:3.9 as pausebin
FROM zengxu/critools:v1.25.0 as crictlbin
FROM zengxu/cnitool-bdad953d72e3a879d1f458c51dbf1923 as cnitoolbin

FROM ubuntu:focal-20221130

RUN set -ex \
    && apt update \
    && apt upgrade \
    && apt install -y \
    iproute2 \
    iptables \
    iputils-ping \
    iputils-arping \
    tcpdump \
    jq

ADD entrypoint.sh /

COPY --from=pausebin /pause /pause
COPY --from=crictlbin /usr/bin/crictl /usr/local/bin/crictl
COPY --from=cnitoolbin /ko-app/cnitool /usr/local/bin/cnitool

ENTRYPOINT ["/entrypoint.sh"]
