#!/usr/bin/env bash

# Directory where application configuration files are supposed to be stored
export PRYV_CONF_ROOT="/var/pryv"

# log provided number of lines or 500
lines="${1:-500}"

echo "Fetching Pryv logs to pryv-services.log"
docker-compose -f pryv/pryv.yml logs --tail=$lines > pryv-services.log
