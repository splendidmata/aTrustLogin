FROM debian:11
LABEL authors="Kenvix"

ENTRYPOINT ["top", "-b"]