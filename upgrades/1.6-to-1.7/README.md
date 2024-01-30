
# Audit logs migration from Pryv.io 1.6 to 1.7

Pryv.io 1.7 introduces indexed storage for audit logs which were kept in syslog files.

If you have activated audit logs for your Pryv.io platform, you can migrate them to the new Pryv.io 1.7 storage following this guide. 
For this to work, you must have already upgrade your platform to version 1.7.

## Process

1. If needed, change the `PRYV_CONF_ROOT` variable in `run-migration.sh`, it is set to `/var/pryv`. It marks the folder where you unpacked the configuration files.
2. Stop Pryv.io services: `cd /var/pryv && ./stop-pryv`
3. Start migration container: `/var/pryv/upgrades/from-1.6-to-1.7/run-migration.sh`
4. Start them back up: `cd /var/pryv && /var/pryv/run-pryv`
