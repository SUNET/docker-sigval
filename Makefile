VERSION := 1.0.4
EIDAS_BUILD_ARGS := "--you --forgot --username --and --passw"
-include local.mk

all: build push

build: 
	./build.sh $(EIDAS_BUILD_ARGS) --version $(VERSION) -i sigval --tag $(VERSION)

push:
	docker tag sigval:$(VERSION) docker.sunet.se/sigval:$(VERSION)
	docker push docker.sunet.se/sigval:$(VERSION)
