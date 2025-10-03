ARG BASE=jsz-debian
FROM $BASE

RUN apt-get update -y && apt-get install -y golang
