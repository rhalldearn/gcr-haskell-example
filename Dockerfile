FROM ubuntu:18.04
RUN mkdir -p /opt/app/
ARG BINARY_PATH
WORKDIR /opt/app
# not a fan of this!
RUN apt-get update && apt-get install -y \
  ca-certificates \
  libgmp-dev
COPY "$BINARY_PATH" /opt/app/
COPY static /opt/app/static
# COPY config /opt/app/config
ENV PORT 8080
CMD ["/opt/app/app-exe"]