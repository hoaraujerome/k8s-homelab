SHELL := /usr/bin/env bash

# Define targets
.PHONY: prereq

prereq:
	@echo "Setting up prerequisites..."
	./prereq/bootstrap.sh
