ARG GO_VERSION=1.24

FROM golang:${GO_VERSION}-bullseye AS builder

ARG IMAGE_VERSION=0.9.0
ARG PLUGIN
ENV CGO_ENABLED=0

WORKDIR /go/builder

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN make clean
RUN make IMAGE_VERSION=${IMAGE_VERSION} PLUGINS=${PLUGIN} build-plugins-static

FROM gcr.io/distroless/static

ARG PLUGIN
ENV PLUGIN=${PLUGIN}

COPY --from=builder /go/builder/build/bin/${PLUGIN} /${PLUGIN}

ENTRYPOINT ["/ulimit-adjuster"]
