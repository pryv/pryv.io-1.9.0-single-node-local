# Pryv.io installation guide

This guide contains instructions to install a Pryv.io **single-node** platform.
It assumes you have prepared your machines with the [infrastructure procurement guide](https://api.pryv.com/customer-resources/infrastructure-procurement/) first.
​

## Table of contents <!-- omit in toc -->

- New centralized configuration scheme
- `pryv` directory
- Run the initialisation scripts
- Platform setup
  - Required variables
- System keys
- Leader-follower keys
- Config follower Docker authentication
- SSL certificates - custom provider
- Launching the Installation
  - Prerequisites check
  - Authenticate with the Pryv Docker registry
  - Config follower Docker authentication
  - Run
    - Reporting
  - SSL certificates - Let's Encrypt
  - Stop
  - Validation
  - Admin Panel
- Closing Remarks


## New centralized configuration scheme

The platform configurations are now stored on a single “leader” service. Each role fetches its configuration files from it upon installation (or configuration changes) using its “follower” service.

For a single-node setup, the leader and a single follower both run on the machine.


## `pryv` directory

In addition to the configuration files, we distribute scripts to launch and stop the services.

You should have received the configuration files, packaged in an archive (.tgz).

The following instructions need to be executed on the single-node machine:

- Please create a directory where all your Pryv data should live. We suggest something like `/var/pryv/` as it is used in all the provided scripts. If you cannot use this folder, we recommend either creating a symlink (`ln -s ${YOUR_FOLDER} /var/pryv`) or adapting the scripts.
- The absolute path to this location has to be stored under environment variable named `PRYV_CONF_ROOT`. By default it is set to `/var/pryv`, however it can be changed e.g. with usage of the script below,
- Copy the configuration archive to the root of the directory,
- Unarchive the configuration in place.

```bash
export PRYV_CONF_ROOT="/var/pryv"
mkdir $PRYV_CONF_ROOT
tar xvf template-single-node.tgz -C $PRYV_CONF_ROOT --strip-components=1 --same-owner
cd $PRYV_CONF_ROOT
```


## Run the initialisation scripts

Run the `init-leader` script which generates the initial `config-leader/conf/platform.yml` and `config-leader/conf/config-leader.json` files from their respective templates. Perform the same for the follower service by running `init-follower`.


## Platform setup

Define the platform-specific variables in `${PRYV_CONF_ROOT}/config-leader/conf/platform.yml`. The leader service will replace them in the template configuration files located in the `${PRYV_CONF_ROOT}/config-leader/data/` folder when run.

### Required variables

- `DOMAIN`
- `SINGLE_MACHINE_IP_ADDRESS`
- `REGISTER_ADMIN_KEY`
- `LICENSE_NAME`
- `SINGLE_MACHINE_PUBLIC_INTERFACE_IP_ADDRESS` (if your DNS does not start at first boot)
- `NAME_SERVER_ENTRIES` (if using Let's Encrypt for your SSL certificates)


## System keys

The configuration contains some system keys that are used between Pryv.io services. You will find them in the `${PRYV_CONF_ROOT}/config-leader/conf/config-leader.json` file, in a property called `internals`.
You need to replace each `REPLACE_ME` occurence with a strong key of random characters. We recommend using a string of alphanumeric characters of length between 20 and 50.


## Leader-follower keys

For each follower service, you must define a secret for it to authentify when fetching its configuration from the leader service.

In the leader service configuration file `${PRYV_CONF_ROOT}/config-leader/conf/config-leader.json`, you will find a map called `followers` with the each follower's secret set as key and its `url` and `role` set as values as shown below:

```json
    "followers": {
        "FOLLOWER_SINGLENODE_KEY": {
        "url": "http://pryvio_config_follower:6000",
        "role": "singlenode"
        }
    }
```

You **must** replace `FOLLOWER_SINGLENODE_KEY` with a strong cryptographic key. We recommend using a string of alphanumeric characters of length between 20 and 50.

For each follower, you will need to set the same key in its configuration file `${PRYV_CONF_ROOT}/config-follower/conf/config-follower.json`. It must be placed in the `leader` map as show below:

```json
    "leader": {
        "url": "http://config-leader:7000",
        "auth": "FOLLOWER_SINGLENODE_KEY"
    }
```


## SSL certificates - custom provider

If you don't have a particular SSL provider in mind and wish to use Let's Encrypt for your SSL certificate, you can skip this step

All services use Nginx to terminate inbound HTTPS connections. You should have obtained a wildcard certificate for your domain to that effect. You will need to store that certificate along with the CA chain into the appropriate locations. Please follow this [link](https://www.digicert.com/ssl-certificate-installation-nginx.htm) to find instructions on how to convert a certificate for nginx.

Your certificate files must be placed in these locations:

  - `${PRYV_CONF_ROOT}/config-leader/data/singlenode/nginx/conf/secret/${DOMAIN}-bundle.crt`
  - `${PRYV_CONF_ROOT}/config-leader/data/singlenode/nginx/conf/secret/${DOMAIN}-key.pem`


## Launching the Installation

### Prerequisites Check

Please run these commands and compare the output with values below.
You might have to use `docker-ce` and your versions can be newer:

    docker -v
    Docker version 17.05.0-ce, build 89658be

    docker-compose -v
    docker-compose version 1.18.0, build 8dd22a9

### Authenticate with the Pryv Docker registry

To launch the installation, you will first need to authenticate with the distribution host to retrieve the Pryv.io Docker images. You should have received a JSON file with credentials (`pryv-docker-key.json`) with the delivery of the configuration files.

To log in, type:

    cat pryv-docker-key.json | docker login -u _json_key --password-stdin https://eu.gcr.io

or for an older Docker engine

    docker login -u _json_key -p "$(cat pryv-docker-key.json)" https://eu.gcr.io

### Config follower Docker authentication

The follower service will reboot Pryv services when applying an update from the admin panel after performing a version upgrade. In order to download the new Docker images from the Pryv private repository, the container needs to have access to a valid authentication token.

Adapt the `config-follower/config-follower.yml` mounting point for the `.docker/config.json` file to the user with whom you have performed the `docker login` command.

### Run

Set the required permissions on data and log directories by running the following script:

    sudo ./ensure-permissions

Run the configuration leader service:

    ./run-config-leader

Then, run the configuration follower service, which will pull the necessary configuration files
 from the leader.

    ./run-config-follower

Now that the configuration is ready, you can launch the Pryv.io components:

    ./run-pryv

This command will download the Docker images that belong to your release from the Docker repository and launch the component. If all goes well, you'll see a number of running Docker containers when you start `docker ps`.


## Completing the installation

### Reporting information

Each Pryv.io module sends a report to Pryv upon start, containing the following contractual information:

- license key
- users count
- template version
- hostname
- role

If you decide to opt out, please contact your account manager @ Pryv to define another way to communicate this information.

### SSL certificates with Let's Encrypt

You can generate or renew a wildcard SSL certificate with Let's Encrypt by running the `renew-ssl-certificate` script on the leader machine. See [this guide](https://api.pryv.com/customer-resources/ssl-certificate/) for more details.

### Stopping the services

The scripts `stop-config-leader`, `stop-config-follower` and `stop-pryv` shut down the corresponding running services.

### Validation

Please refer to the [validation guide](https://api.pryv.com/customer-resources/platform-validation/) in the [customer resources](https://api.pryv.com/customer-resources/) to validate that your Pryv.io platform is up and running.

### Admin panel

Now that the platform is up and running, you can edit its platform settings through an admin panel available at: https://adm.${DOMAIN}

You can find the default credentials for the first authentication in the configuration leader's logs with:

    docker logs pryvio_config_leader 2>&1 | grep initial_user | tail -1

Which should output a line such as this (the default credentials are regenerated every time the service starts):

    2020-09-30T07:32:32.533Z - ESC[32minfoESC[39m: [config-leader:app] Initial user generated. Username: initial_user, password: e0c11c2989aea99

Once logged in, you can create your own admin user(s) via the 'Admin Users' page.


## Closing Remarks

If you need support, please contact your technical account manager @ Pryv or open a ticket on [our helpdesk](https://support.pryv.com/hc/en-us/requests/new). We're glad to help you with any questions you might have.
