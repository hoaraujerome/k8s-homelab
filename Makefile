SHELL := /usr/bin/env bash

# Define targets
.PHONY: foundations images-infra-plan images-infra-deploy images-infra-destroy images-config-build cluster-infra-plan cluster-infra-deploy cluster-infra-destroy

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

cluster-infra-plan:
	./cluster/setup-cluster.sh plan

cluster-infra-deploy:
	./cluster/setup-cluster.sh deploy

cluster-infra-destroy:
	./cluster/setup-cluster.sh destroy
