tag			:= steigr/coreos
version ?= alpha
release ?= current

all: push
	@true

push: tag
	docker push $(tag):$(version)
	docker push $(tag):latest

tag: build
	docker tag $(tag):$(version) $(tag):latest

build: scratch Dockerfile
	docker build -t $(tag):$(version) .

Dockerfile:
	printf 'FROM scratch\nMAINTAINER \\\n[Mathias Kaufmann <me@stei.gr>]\nENV container=docker\nADD $(shell ls $(shell basename $(PWD))-$(version)-*.tar*) /' > Dockerfile

scratch:
	docker run --rm --interactive fedora:rawhide bash -x -s -- "$(version)" "$(release)" < scratch.sh | tar xz

.PHONY: Dockerfile