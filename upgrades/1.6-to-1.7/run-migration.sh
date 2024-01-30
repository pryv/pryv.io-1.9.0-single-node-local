#!/usr/bin/env bash

export PRYV_CONF_ROOT=/var/pryv

SCRIPT_FOLDER=$(cd $(dirname "$0"); pwd)
cd $SCRIPT_FOLDER

echo "Running Pryv/core component."

docker-compose -f audit-migration.yml up -d

docker exec pryvio_core_migration_1.7 /app/bin/scripts/migrations/audit1.6-1.7/run_in_container.sh

docker-compose -f audit-migration.yml down