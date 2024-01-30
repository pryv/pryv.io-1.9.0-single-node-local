
# Pryv.io database upgrade from 1.5 to 1.6

This guide describes how to upgrade your MongoDB from 3.6 to 4.2 version. It is only valid if you have a Pryv.io platform with version 1.0.12 or core version 1.5.  
If you have an earlier version, please upgrade it to 1.5 version first.

## Backup current configuration

Connect to your single-node machine and backup your latest MongoDB configuration file. It should be located in your `${PRYV_CONF_ROOT}/pryv/mongodb/conf/` folder.

## Backup current database

Backup your latest mongo database. See [https://api.pryv.com/customer-resources/backup/](https://api.pryv.com/customer-resources/backup/)

## Upgrade

You may need to run commands in sudo, depending on your server setup.

1. Stop any running containers: in your {PRYV_CONF_ROOT} path run
    ```
    ./stop-pryv
    ```
2. Set your Pryv.io root folder
    ```
    export PRYV_CONF_ROOT=<your PRYV_CONF_ROOT path>
   
    For example:
    export PRYV_CONF_ROOT=/var/pryv
    ```
3. Go to the folder where **this** tutorial is and execute the first MongoDB upgrade step:  
    ```
    docker-compose -f mongo-upgrade-from-3.6-to-4.2.yml up --detach pryvio_mongodb_migration_step_1
    ```
4. Update MongoDB compatibility: 
    ```
    docker exec -it pryvio_mongodb_migration_step_1 /bin/sh /app/setFeatureCompatibilityVersion.sh
    ```
   The reponse should contain '"ok" : 1'. If it does not, you can check the logs with the commands below.
   ```
    (if you switch shells, don't forget to set PRYV_CONF_ROOT as you did in the first step):
    
    tail -f $PRYV_CONF_ROOT/pryv/mongodb/log/mongodb.log
    ```
5. Stop the migration container:
    ```
    docker stop pryvio_mongodb_migration_step_1
    ```
6. Execute the second MongoDB upgrade step:
    ```
    docker-compose -f mongo-upgrade-from-3.6-to-4.2.yml up --detach pryvio_mongodb_migration_step_2
    ```
7. Update mongo settings:
    ```
    docker exec -it pryvio_mongodb_migration_step_2 /bin/sh /app/convertToReplicaSet.sh
    ```
   If you get an error that it failed to connect to the localhost, you may need to a wait few seconds more until MongoDB fully starts.
8. Stop the second migration container:
    ```
    docker stop pryvio_mongodb_migration_step_2
    ```
9. Continue with the platform update steps from the file `MAIN-UPGRADE-FROM-1.5-TO-1.6.md`.