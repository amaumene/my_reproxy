FROM golang:alpine AS builder

WORKDIR /app

RUN wget -O - https://api.github.com/repos/umputun/reproxy/releases/latest | grep 'tarball_url' | cut -d '"' -f 4 | xargs wget -O reproxy.tar.gz

RUN mkdir reproxy

RUN tar xaf reproxy.tar.gz -C reproxy --strip-components=1

WORKDIR /app/reproxy

RUN rm -rf vendor go.mod go.sum

RUN go mod init github.com/umputun/reproxy && go mod tidy

RUN cd app && CGO_ENABLED=0 go build -o reproxy -ldflags "-w -s"

FROM scratch

COPY --from=builder /app/reproxy/app/reproxy /app/reproxy

EXPOSE 8080/tcp
EXPOSE 8443/tcp

ENTRYPOINT [ "/app/reproxy" ]
