## -- Stage 1 -- Builder --
FROM debian AS builder

RUN apt-get update && \
    apt-get -y install build-essential libreadline-dev libffi-dev git pkg-config gcc-arm-none-eabi libnewlib-arm-none-eabi python3

RUN set -x && cd /tmp && \
    git clone --recurse-submodules https://github.com/micropython/micropython.git && \
    cd micropython/mpy-cross && \
    make && install -vps mpy-cross /usr/local/bin/ && \
    cd ../ports/unix && \
    make axtls && make && \
    make install && \
    cd /tmp && rm -rf micropython

## -- Stage 2 -- Dist container --
FROM debian

#RUN apt-get -y install sudo && echo "micropython ALL=NOPASSWD: ALL" > /etc/sudoers.d/micropython && chmod 440 /etc/sudoers.d/micropython

COPY --from=0 /usr/local/bin/* /usr/local/bin/

RUN useradd -m -d /src micropython
WORKDIR /src
USER micropython

CMD ["micropython"]

