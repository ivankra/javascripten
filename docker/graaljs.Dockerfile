FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/oracle/graaljs
ARG JS_REV=graal-25.0.0

WORKDIR /dist
RUN wget "https://github.com/oracle/graaljs/releases/download/$JS_REV/$(echo "$JS_REV" | sed -e 's/graal/graaljs/')-linux-$(uname -m | sed -e 's/x86_64/amd64/').tar.gz" && \
    tar xf graaljs-*.tar.gz && \
    rm -f graaljs-*.tar.gz && \
    ln -s graaljs-*/bin/js graaljs

ENV JS_BINARY=/dist/graaljs
RUN ${JS_BINARY} --version | egrep -o '[0-9.]+' >json.version && \
    du -bs /dist/graaljs-* | cut -f 1 >json.binary_size
CMD ${JS_BINARY}
