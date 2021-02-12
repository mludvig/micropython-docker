## -- Stage 1 -- Builder --
FROM debian AS builder

RUN apt-get update && \
    apt-get -y install build-essential libreadline-dev libffi-dev git pkg-config gcc-arm-none-eabi libnewlib-arm-none-eabi python3

RUN set -x && cd /tmp && \
    MICROPYTHON_VERSION="master" && \
    git clone --depth 1 --branch ${MICROPYTHON_VERSION} https://github.com/micropython/micropython.git && \
    cd micropython && \
    # Remove SoC specific submodules - they pull in half of the internet
    #git rm lib/pico-sdk lib/nxp_driver lib/tinyusb lib/nrfx lib/stm32lib && \
    git submodule update --init --recursive && \
    # Build mpy-cross - needed for the main binary build
    cd mpy-cross && make && install -vps mpy-cross /usr/local/bin/ && \
    cd ../ports/unix && \
    # Use mbedTLS instead of axTLS
    sed -i -e 's/^MICROPY_SSL_AXTLS.*/MICROPY_SSL_AXTLS = 0/' -e 's/^MICROPY_SSL_MBEDTLS.*/MICROPY_SSL_MBEDTLS = 1/' mpconfigport.mk && \
    make && make install

## -- Stage 2 -- Dist container --
FROM debian

COPY --from=builder /usr/local/bin/* /usr/local/bin/

RUN useradd -m -d /src micropython
WORKDIR /src
USER micropython

CMD ["micropython"]
