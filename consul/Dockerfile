# base image
FROM alpine:3.7

# consul version
ENV CONSUL_VERSION 1.5.0

# create base dir
RUN mkdir /consul

# install deps
RUN apk --no-cache add \
      bash \
      ca-certificates \
      wget

# download consul
RUN wget --quiet --output-document=/tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    unzip /tmp/consul.zip -d /consul && \
    rm -f /tmp/consul.zip && \
    chmod +x /consul/consul

# update PATH
ENV PATH="PATH=$PATH:$PWD/consul"

# add consul config
COPY ./config/consul-config.json /consul/config/config.json

EXPOSE 8300 8400 8500 8600

ENTRYPOINT ["consul"]
