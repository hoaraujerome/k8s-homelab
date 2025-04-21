SHELL := /usr/bin/env bash

# Define targets
.PHONY: prereq plan deploy destroy

prereq:
	./prereq/bootstrap.sh

build:
	./building/build.sh

plan:
	./provisioning/provision.sh plan

deploy:
	./provisioning/provision.sh deploy

destroy:
	./provisioning/provision.sh destroy
