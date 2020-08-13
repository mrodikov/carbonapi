all: carbonapi mockbackend
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
        EXTRA_PKG_CONFIG_PATH ?= /opt/X11/lib/pkgconfig
endif
VERSION ?= $(shell git describe --abbrev=4 --dirty --always --tags)

GO ?= go

PKG_CARBONAPI=github.com/mrodikov/carbonapi/cmd/carbonapi
PKG_MOCKBACKEND=github.com/mrodikov/carbonapi/cmd/mockbackend
PKG_CARBONZIPPER=github.com/mrodikov/carbonapi/cmd/carbonzipper

carbonapi: $(shell find . -name '*.go' | grep -v 'vendor')
	PKG_CONFIG_PATH="$(EXTRA_PKG_CONFIG_PATH)" GO111MODULE=on $(GO) build -mod=vendor -v -tags cairo -ldflags '-X main.BuildVersion=$(VERSION)' $(PKG_CARBONAPI)

mockbackend: $(shell find . -name '*.go' | grep -v 'vendor')
	GO111MODULE=on $(GO) build -mod=vendor -v -ldflags '-X main.BuildVersion=$(VERSION)' $(PKG_MOCKBACKEND)

debug:
	PKG_CONFIG_PATH="$(EXTRA_PKG_CONFIG_PATH)" GO111MODULE=on $(GO) build -mod=vendor -v -tags cairo -ldflags '-X main.BuildVersion=$(VERSION)' -gcflags=all='-l -N' $(PKG_CARBONAPI)

nocairo:
	GO111MODULE=on $(GO) build -mod=vendor -ldflags '-X main.BuildVersion=$(VERSION)' $(PKG_CARBONAPI)

carbonzipper: $(shell find . -name '*.go' | grep -v 'vendor')
	GO111MODULE=on $(GO) build -mod=vendor --ldflags '-X main.BuildVersion=$(VERSION)' $(PKG_CARBONZIPPER)

test:
	PKG_CONFIG_PATH="$(EXTRA_PKG_CONFIG_PATH)" $(GO) test -mod=vendor -tags cairo ./... -race

test_nocairo:
	$(GO) test -mod=vendor ./... -race

vet:
	$(GO) vet

install:
	mkdir -p $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/usr/share/carbonapi/
	cp ./carbonapi $(DESTDIR)/usr/bin/
	cp ./cmd/carbonapi/carbonapi.example.yaml $(DESTDIR)/usr/share/carbonapi/

install_carbonzipper:
	mkdir -p $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/usr/share/carbonzipper/
	cp ./carbonzipper $(DESTDIR)/usr/bin/
	cp ./cmd/carbonzipper/example.conf $(DESTDIR)/usr/share/carbonzipper/

clean:
	rm -f carbonapi carbonzipper mockbackend
	rm -f *.deb
	rm -f *.rpm
