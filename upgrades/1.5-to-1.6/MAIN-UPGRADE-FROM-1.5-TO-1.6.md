
# Config upgrade from version 1.5.x to 1.6.0

This is the initial instructions for upgrading your Pryv.io platform from version 1.5 to 1.6.0. If you have an earlier version, please first update to Pryv.io 1.5.

## What is new

Please check what is new with Pryv.io 1.6 [here](https://api.pryv.com/change-log/).

## What upgrades need to be made

To upgrade Pryv.io to version 1.6, please follow these steps:

1. Before you start, make sure that you have 1 account per core that you will use in the end of this tutorial to test the upgrade.

2. Upgrade Pryv.io database from 3.6 to 4.2 
(use tutorial in file `DATABASE-UPGRADE-FROM-1.5-TO-1.6.md`)

3. Upgrade the Pryv.io config to add new system streams.
(use tutorial in file `UPDATE.md`)

4. Boot services in the single-node server from your Pryv.io root folder with 
    ```
    ./ensure-permissions-${ROLE}
    ./run-config-follower
    ./run-pryv
    ```
5. In the single-node server, check when the migration process is finished. It may take some time because all indexes have to be rebuilt. You can monitor the process with:

    Mongodb:

    ```
    tail -n 100 -f $PRYV_CONF_ROOT/pryv/mongodb/log/mongodb.log
    ```

    If there are many users, the process could timout. 
    If that is the case, please restart the services in $PRYV_CONF_ROOT with ./restart-pryv.  

    Core:

    ```
    docker logs -f --tail 50 pryvio_core
    ```

6. Validate changes by trying to:

    1. Login with the old user
    2. Register a new user

7. If everything is successful, you can remove database migration related containers and images.

    ```
    docker rm pryvio_mongodb_migration_step_1
    docker rm pryvio_mongodb_migration_step_2
    docker rmi eu.gcr.io/pryvio/mongodb:migration-4.0.20
    docker rmi eu.gcr.io/pryvio/mongodb:migration-4.2.9
    ```

More information about the new registration path, parameters and features could be found [here](https://api.pryv.com/customer-resources/system-streams/) 
and [here](https://api.pryv.com/reference-system/#account-creation)

**Congratulations!**