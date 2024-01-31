# Local development with backloop dev

This setup is based on the pryv.io-1.9.0-single-node template files using backloop.dev domain and SSL certficates. 



## Prerequistory 

1- Docker & Docker-compose 
2- Login to pryv docker container repository (look for pryv-docker-key.json)
3- Set environement var `PRYV_CONF_ROOT` to match the directory with this file. 
  This can be done with the following from this directory

  ```
  export PRYV_CONF_ROOT=`pwd` 
  ```

4- (optional) Node.js if you want to automatically download the SSL certificates

## Install

1- SSL certificates 
  - AUTO (with node.js installed): Go in `config-leader/data/singlenode/nginx/conf/secret` and run 
    `BACKLOOP_DEV_CERTS_DIR=./ npx -p backloop.dev backloop.dev-update`
  - Manualy: Download the certificates files manially from [backloop.dev](https://backloop.dev) and place them in `config-leader/data/singlenode/nginx/conf/secret`
2- Renew SSL certificates when they expires after 2-3 months
3- Follow the INSTALL.md or UPDATE.md file and skip steps where domain, dns .. have already been configured

## Notes 
- This has been tested on ubuntu 22.04 with docker running as root 
- `config_leader` failed on first start beacause of a git initialization error, it started on the second boot

## What has been done

### config/leader/platform.yml
  - set `DOMAIN` => `backloop.dev`
  - set `SINGLE_MACHINE_IP_ADDRESS` => `127.0.0.1`
  - set `REGISTER_ADMIN_KEY` => `UnsecureRegisterAdminKey`
  - set `NAME_SERVER_ENTRIES` to `dns1.backloop.dev` & `dns2.backloop.dev` (should have no effect anyway)

### config-leader/conf/config-leader.json
  - replaced `FOLLOWER_SINGLENODE_KEY` with `UnsecureFollowerKey`

  - Internals: 
  ```
    "internals": {
      "SSO_COOKIE_SIGN_SECRET": "UnsecureSSOCookieSecret",
      "FILES_READ_TOKEN_SECRET": "UnsecurereadTokenSecret",
      "CORE_SYSTEM_KEY": "UnsecureCoreSystemKey",
      "CORE_MAIL_KEY": "UnsecureMailKey",
      "REGISTER_SYSTEM_KEY_1": "UnsecureRegisterSysemKey1"
    },
  ```

### in multiple scripts updated the setting of PRYV_CONF_ROOT 
  from: `export PRYV_CONF_ROOT=/var/pryv`  
  to: `export PRYV_CONF_ROOT="${PRYV_CONF_ROOT:=/var/pryv}"`

### adapted the host mounting point to match the user with whom you performed 'docker login'
in file `/Users/perki/wActiv/pryv.io-1.9.0-single-node-local/config-follower/config-follower.yml`
    set services / config-follower / volumes:
      - `/home/docker/.docker/config.json:${HOME}/.docker/config.json`
    added `HOME` to environement

 
