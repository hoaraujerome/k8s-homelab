#!/usr/bin/env bash

log_message() {
  local message="${1}"
  echo "$(basename "${0}") - ${message}"
}
