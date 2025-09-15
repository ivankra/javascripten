FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/oracle/graaljs

WORKDIR /opt
RUN cd /opt && wget "https://github.com/oracle/graaljs/releases/download/graal-24.2.2/graaljs-24.2.2-linux-$(uname -m | sed -e 's/x86_64/amd64/').tar.gz" && \
    tar xf graaljs*.tar.gz && \
    ln -s /opt/graal*/bin/js /usr/local/bin/graaljs

ENV JS_BINARY=/usr/local/bin/graaljs
RUN ${JS_BINARY} --version | egrep -o '[0-9.]+' >version
CMD ${JS_BINARY}
