FROM alpine:3.16

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
COPY ./start.sh /usr/local/bin/
COPY ./openssl.cnf.add /etc/ssl
COPY ./conf/squid*.conf /etc/squid/
COPY ./conf/jesred* /etc/
WORKDIR /

RUN apk add --no-cache \
    build-base \
    bash \
    squid \
    openssl \
    ca-certificates && \
    update-ca-certificates && \
    cat /etc/ssl/openssl.cnf.add >> /etc/ssl/openssl.cnf && \
    chmod 755 /usr/local/bin/start.sh && \
    tar xzvf jesred-1.2pl1.tar.gz && cd jesred-1.2pl1 && make && cp jesred /usr/local/bin && rm -r /jesred*  && \
    cd /etc && ln -s /etc/squid/jesred* .

EXPOSE 3128
EXPOSE 4128

ENTRYPOINT ["/usr/local/bin/start.sh"]

