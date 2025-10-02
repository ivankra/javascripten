ARG BASE=jszoo-sh
FROM $BASE

ARG TARGETARCH

COPY dist/$TARGETARCH /dist
COPY bench /bench
RUN rm -rf /bench/octane /bench/__pycache__ /bench/data.py

WORKDIR /dist
