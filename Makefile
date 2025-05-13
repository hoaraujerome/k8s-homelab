SHELL := /usr/bin/env bash

# TODO review targets
# Define targets
.PHONY: foundations prereq build plan deploy destroy

foundations:
	./foundations/setup-foundations.sh

images-infra-plan:
	./images/setup-images.sh plan

images-infra-deploy:
	./images/setup-images.sh deploy

images-infra-destroy:
	./images/setup-images.sh destroy

images-config-build:
	./images/setup-images.sh build

plan:
	./provisioning/provision.sh plan

deploy:
	./provisioning/provision.sh deploy

destroy:
	./provisioning/provision.sh destroy
