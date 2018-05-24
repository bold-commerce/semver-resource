FROM golang:alpine as builder
COPY . /go/src/github.com/concourse/semver-resource
ENV CGO_ENABLED 0
RUN go build -o /assets/in github.com/concourse/semver-resource/in
RUN go build -o /assets/out github.com/concourse/semver-resource/out
RUN go build -o /assets/check github.com/concourse/semver-resource/check
WORKDIR /go/src/github.com/concourse/semver-resource
RUN set -e; for pkg in $(go list ./...); do \
		go test -o "/tests/$(basename $pkg).test" -c $pkg; \
	done

FROM alpine:edge AS resource
RUN apk add --no-cache bash tzdata ca-certificates git jq openssh
RUN git config --global user.email "git@localhost"
RUN git config --global user.name "git"
COPY --from=builder assets/ /opt/resource/
RUN chmod +x /opt/resource/*
