default: heroku-24

VERSION := 2.9.2
ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

clean:
	rm -rf src/ dist/

console:
	@echo "Console Help"
	@echo
	@echo "To vendor tcmalloc:"
	@echo "	bin/compile /app/ /cache/ /env/"
	@echo

	@docker run --rm -ti -v $(shell pwd):/buildpack \
		-e "STACK=heroku-24" \
		-e "VERSION=$(VERSION)" \
		-w /buildpack heroku/heroku:24-build \
		bash -c 'mkdir /app /cache /env; echo $(VERSION) > /env/TCMALLOC_VERSION; exec bash'

# Handle 2.9 which uses 2.9 as the tag but 2.9.0 as the version number.
src/gperftools-2.9.tar.gz:
	mkdir -p $$(dirname $@)
	curl -fsL https://github.com/gperftools/gperftools/releases/download/gperftools-2.9/gperftools-2.9.0.tar.gz -o $@

# Download missing source archives to ./src/
src/gperftools-%.tar.gz:
	mkdir -p $$(dirname $@)
	curl -fsL https://github.com/gperftools/gperftools/releases/download/gperftools-$*/gperftools-$*.tar.gz -o $@

.PHONY: heroku-24

# Build for heroku-24 stack
heroku-24: src/gperftools-$(VERSION).tar.gz
	docker pull heroku/heroku:24-build
	docker run --rm -it --volume="$(ROOT_DIR):/wrk" \
		heroku/heroku:24-build /wrk/build.sh $(VERSION) heroku-24

# Build recent releases for all supported stacks
all:
	$(MAKE) heroku-24 VERSION=2.9.1
	$(MAKE) heroku-24 VERSION=2.16
