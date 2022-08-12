FROM debian:unstable
MAINTAINER 360 360@360.com

# 设置环境变量
ENV TOR_VER="maint-0.4.7"
ENV TERM=xterm \
    TOR_ORPORT=7000 \
    TOR_DIRPORT=9030 \
    TOR_DIR=/tor 

# 安装依赖
RUN apt-get update && apt-get install -y iproute2 && apt-get install -y tor && apt-get install -y sudo &&\
    build_temps="build-essential automake" && \ 
    build_deps="libssl-dev zlib1g-dev libevent-dev ca-certificates\
        dh-apparmor libseccomp-dev dh-systemd \
        git" && \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install $build_deps $build_temps \
        init-system-helpers \
        pwgen && \
    mkdir /src

# 安装对应版本的tor
COPY ./src/ /src/
RUN cd /src/tor && \
    git checkout ${TOR_VER} && \
    ./autogen.sh && \
    ./configure --disable-asciidoc && \
    make && \
    make install && \
    apt-get -y purge --auto-remove $build_temps && \
    apt-get clean && rm -r /var/lib/apt/lists/* && \
    rm -rf /src/*

# 复制基础的tor配置文件 torrc 和 torrc.da
COPY ./config/torrc* /etc/tor/

# 复制容器启动过程需要使用的脚本 docker-entrypoint 和 da_fingerprint
COPY ./scripts/ /usr/local/bin/

# 创建共享目录/tor
RUN mkdir ${TOR_DIR}

# 开放容器端口 ORPort, DirPort, ObfsproxyPort
EXPOSE 9001 9030 9051

# 容器启动默认执行的脚本
ENTRYPOINT ["docker-entrypoint"]

# 启动tor
CMD ["tor", "-f", "/etc/tor/torrc"]
