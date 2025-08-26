FROM javascripten-debian:stable

WORKDIR /opt
RUN cd /opt && wget "https://github.com/oracle/graaljs/releases/download/graal-24.2.2/graaljs-24.2.2-linux-$(uname -m | sed -e 's/x86_64/amd64/').tar.gz" && \
    tar xf graaljs*.tar.gz && \
    ln -s /opt/graal*/bin/js /usr/local/bin/graaljs

ENV JS_BINARY_LINK=/usr/local/bin/graaljs
CMD ${JS_BINARY_LINK}
