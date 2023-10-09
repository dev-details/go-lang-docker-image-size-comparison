FROM golang:1.21 AS builder

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

WORKDIR /app
COPY go.mod .

COPY healthcheck/ ./healthcheck
COPY serve/ ./serve

WORKDIR /app/healthcheck
RUN go build -ldflags='-w -s -extldflags "-static"' \
    -o /dist/healthcheck .

WORKDIR /app/serve
RUN go build -ldflags='-w -s -extldflags "-static"' \
    -o /dist/serve .

FROM builder AS run-tests
RUN go test -v ./...

#
# Minimal from scratch image
#
FROM scratch AS scratch
COPY --chown=0:0 --chmod=755 --from=builder /dist /
USER 65534
HEALTHCHECK --interval=1s --timeout=3s --start-period=1s CMD ["/healthcheck"]
ENTRYPOINT ["/serve"]

#
# Distroless image
#
FROM gcr.io/distroless/static-debian12 AS distroless
COPY --chown=0:0 --chmod=755 --from=builder /dist /
USER nonroot:nonroot
HEALTHCHECK --interval=1s --timeout=3s --start-period=1s CMD ["/healthcheck"]
ENTRYPOINT ["/serve"]

#
# debian-slim image
#
FROM debian:bookworm-slim AS debian-slim
COPY --chown=0:0 --chmod=755 --from=builder /dist /
USER nobody:nogroup
HEALTHCHECK --interval=1s --timeout=3s --start-period=1s CMD ["/healthcheck"]
ENTRYPOINT ["/serve"]

#
# ubuntu image
#
FROM ubuntu:jammy AS ubuntu
COPY --chown=0:0 --chmod=755 --from=builder /dist /
USER nobody:nogroup
HEALTHCHECK --interval=1s --timeout=3s --start-period=1s CMD ["/healthcheck"]
ENTRYPOINT ["/serve"]

#
# Apline image
#
FROM alpine:latest AS alpine
COPY --chown=0:0 --chmod=755 --from=builder /dist /
USER 65534
HEALTHCHECK --interval=1s --timeout=3s --start-period=1s CMD ["/healthcheck"]
ENTRYPOINT ["/serve"]
