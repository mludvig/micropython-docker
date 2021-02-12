## -- Stage 1 -- Builder --
FROM debian AS builder

RUN apt-get update && \
    apt-get -y install build-essential libreadline-dev libffi-dev git pkg-config gcc-arm-none-eabi libnewlib-arm-none-eabi python3

RUN set -x && cd /tmp && \
    MICROPYTHON_VERSION="master" && \
    git clone --recurse-submodules --depth 1 --branch ${MICROPYTHON_VERSION} https://github.com/micropython/micropython.git && \
    cd micropython/mpy-cross && \
    make && install -vps mpy-cross /usr/local/bin/ && \
    cd ../ports/unix && \
    make axtls && make && \
    make install

## -- Stage 2 -- Dist container --
FROM debian

COPY --from=builder /usr/local/bin/* /usr/local/bin/

RUN useradd -m -d /src micropython
WORKDIR /src
USER micropython

ENTRYPOINT /usr/local/bin/micropython
