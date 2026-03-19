# Build the manager binary
FROM ghcr.io/cybozu/golang:1.25-jammy AS builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY cmd/ cmd/
COPY api/ api/
COPY hooks/ hooks/
COPY controllers/ controllers/
COPY pkg/ pkg/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o manager cmd/nyamber-controller/main.go

FROM ghcr.io/cybozu/ubuntu:22.04@sha256:2a2bef15b8f481ce6c687c5080c68e9f6aae15d9f06fe2464b49c7c38efeac31
LABEL org.opencontainers.image.source=https://github.com/cybozu-go/nyamber

WORKDIR /
COPY --from=builder /workspace/manager .
USER 65532:65532

ENTRYPOINT ["/manager"]
