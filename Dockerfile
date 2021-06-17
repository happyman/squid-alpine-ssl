FROM alpine:3.7

LABEL maintainer="happyman.eric@gmail.com"

#set enviromental values for certificate CA generation
ENV CN=squid.local \
    O=squid \
    OU=squid \
    C=US

#set proxies for alpine apk package manager
ARG all_proxy 

ENV http_proxy=$all_proxy \
    https_proxy=$all_proxy

COPY jesred-1.2pl1.tar.gz /
WORKDIR /
COPY start.sh /usr/local/bin/
COPY openssl.cnf.add /etc/ssl
COPY conf/squid*.conf /etc/squid/
COPY conf/jesred* /etc/

RUN apk add --no-cache \
    build-base \
    bash \
    squid=3.5.27-r1 \
    openssl=1.0.2t-r0 \
    ca-certificates && \
    update-ca-certificates && \
    cat /etc/ssl/openssl.cnf.add >> /etc/ssl/openssl.cnf && \
    tar xzvf jesred-1.2pl1.tar.gz && cd jesred-1.2pl1 && make && cp jesred /usr/local/bin && rm -r /jesred*  && \
    cd /etc && ln -s /etc/squid/jesred* . && chmod +x /usr/local/bin/start.sh

EXPOSE 3128
EXPOSE 4128

ENTRYPOINT ["/usr/local/bin/start.sh"]

