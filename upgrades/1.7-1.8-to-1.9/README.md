# Mongo DB upgrade from 1.7 or 1.8 to 1.9

Pryv.io 1.9 uses MongoDB 6.0, and a migration with `mongodump` / `mongorestore` steps is required.

1. Before upgrading Pryv.io, stop the services from directory `${PRYV_CONF_ROOT}`:
   `./stop-pryv`
2. Start MongoDB only:
   `docker-compose -f ${PRYV_CONF_ROOT}/pryv/pryv.yml up --detach mongodb`
3. Make sure there is no existing backup data in `${PRYV_CONF_ROOT}/pryv/mongodb/backup` as the content will be overwritten in the next step. Move existing backup data elsewhere.
4. Backup MongoDB data:
   `docker exec -t pryvio_mongodb /app/bin/mongodb/bin/mongodump -d pryv-node -o /app/backup/`
5. Stop MongoDB:
   `docker stop pryvio_mongodb`
6. Move MongoDB raw data to a backup directory, for example:
   `export MONGOBKP=${PRYV_CONF_ROOT}/mongo_raw_bkp_4.2/`
   `mkdir -p $MONGOBKP`
   `mv ${PRYV_CONF_ROOT}/pryv/mongodb/data/* $MONGOBKP`
7. Upgrade Pryv.io to v1.9.0, 
      start ONLY config-leader & config follower (not pryv)
8. Start MongoDB only:
   `docker-compose -f ${PRYV_CONF_ROOT}/pryv/pryv.yml up --detach mongodb`
9. Restore backed up MongoDB data:
   `docker exec -t pryvio_mongodb /app/bin/mongodb/bin/mongorestore /app/backup/`
10. Stop MongoDB:
   `docker stop pryvio_mongodb`
11. Start Pryv.io
    `./run-pryv`
