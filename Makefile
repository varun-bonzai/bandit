.PHONY: all build test check coverage deps clean

LIBS := \
github.com/purzelrakete/bandit \
github.com/purzelrakete/bandit/http

BINS := \
github.com/purzelrakete/bandit/api \
github.com/purzelrakete/bandit/example \
github.com/purzelrakete/bandit/job \
github.com/purzelrakete/bandit/plot

PKGS := $(LIBS) $(BINS)

all: deps build test

# don't install binaries into $GOPATH/bin.
build:
	go build -v $(LIBS)
	go build -o bandit-api github.com/purzelrakete/bandit/api
	go build -o bandit-example github.com/purzelrakete/bandit/example
	go build -o bandit-job github.com/purzelrakete/bandit/job
	go build -o bandit-plot github.com/purzelrakete/bandit/plot

test: check
	go test -v $(PKGS)

# lint and vet both return success (0) on error. make them error and report
check: deps
	go tool vet . 2>&1 | wc -l | { grep 0 || { go tool vet . && false; }; }
	if find . -name '*.go' | xargs golint | grep ":"; then false; else true; fi

# travis-ci currently does not work with coveralls. drone.io does.
coverage:
	goveralls -service drone.io $${COVERALLS_TOKEN:?}

deps:
	go get -v $(PKGS)
	go get github.com/axw/gocov/gocov
	go get -u github.com/golang/lint/golint # frequently updated, so -u
	go get github.com/mattn/goveralls

clean:
	go clean $(PKGS)
	find . -type f -perm -o+rx -name 'bandit-*' -delete # binaries
	find . -type f -name '*.svg' -delete # plots generated by bandit-plot
