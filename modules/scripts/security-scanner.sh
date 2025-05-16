#!/usr/bin/env bash

run_security_scanner() {
  log_message "Run security scanner"
  local dirs=("$@")

  for dir in "${dirs[@]}"; do
    trivy fs \
      --scanners secret,misconfig \
      --exit-code 1 \
      "${dir}"
  done
}
