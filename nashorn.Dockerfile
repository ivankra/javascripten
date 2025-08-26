FROM javascripten-debian:stable

ARG JS_REPO=https://github.com/openjdk/nashorn.git
ARG JS_COMMIT=main

WORKDIR /work
RUN git clone "$JS_REPO" . && git checkout "$JS_COMMIT"

RUN apt-get install -y --no-install-recommends openjdk-25-jdk-headless ant
RUN cd make/nashorn && ant jar

RUN mkdir /opt/nashorn && \
    cp /work/build/nashorn/dist/*.jar /opt/nashorn && \
    cp /work/build/nashorn/dependencies/*.jar /opt/nashorn && \
    echo >/opt/nashorn/nashorn \
      '#!/bin/bash'"\n" \
      'java --add-exports=jdk.internal.le/jdk.internal.org.jline.{reader,reader.impl,reader.impl.completer,terminal,keymap}=ALL-UNNAMED -cp "/opt/nashorn/*" org.openjdk.nashorn.tools.jjs.Main "$@"' && \
    chmod a+rx /opt/nashorn/nashorn && \
    ln -s /opt/nashorn/nashorn /usr/local/bin/nashorn

CMD /usr/local/bin/nashorn
