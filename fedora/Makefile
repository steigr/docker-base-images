tag			:= steigr/fedora
version		:= rawhide
image		:= $(shell basename $(PWD))-$(version)-$(shell date +%Y%m%d).tar.xz

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

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
	printf 'FROM scratch\nMAINTAINER \\\n[Mathias Kaufmann <me@stei.gr>]\nENV container=docker\nADD $(shell ls $(shell basename $(current_dir))-$(version)-*.tar*) /' > Dockerfile

scratch:
	docker run --rm --interactive fedora:rawhide bash -x -s -- "$(version)" "$(release)" < scratch.sh > $(shell basename $(current_dir))-$(version)-$(shell date +%Y%m%d).tar.xz.new
	mv $(shell basename $(current_dir))-$(version)-$(shell date +%Y%m%d).tar.xz.new $(shell basename $(current_dir))-$(version)-$(shell date +%Y%m%d).tar.xz