FROM golang:1.15-buster

# Install prerequisites.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    libcurl3-dev \
    libleptonica-dev \
    liblog4cplus-dev \
    libopencv-dev \
    libtesseract-dev \
    wget

# Clone openalpr.
RUN git clone https://github.com/openalpr/openalpr /openalpr

# Setup the build directory.
run mkdir /openalpr/src/build
workdir /openalpr/src/build

# Compile.
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc .. && \
    make -j2 && \
    make install

ENV GO111MODULE=on

WORKDIR /go/src/app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN export VERSION=$(cat VERSION) && \
    go build -ldflags "-X github.com/opencars/alpr/pkg/version.Version=$VERSION" -o /go/bin/server ./cmd/server/main.go

WORKDIR /go/bin

COPY ./config ./config
EXPOSE 8080

CMD ["./server"]