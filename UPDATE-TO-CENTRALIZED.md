# Upgrade to centralized guide

This guide describes the variables that you should put in place when upgrading your Pryv.io platform from a distributed configuration to a centralized one.


## Backup current configuration

Backup your latest configuration files. They should be located in your `${PRYV_CONF_ROOT}/pryv/*/conf/` folders.


## Platform variables

Based on your previous configuration, you must fill the platform variables which have been gathered in a single configuration file: `config-leader/conf/platform.yml`.  
You can either fill it directly from the inline commented hints of the configuration file or follow the instructions below to report your old values.

### Report old values

The following describes where to find the values in your current config in order to fill the `platform.yml` file.

The variables that are not mentioned are new and must be filled according to the comment hints or left as default.

- DOMAIN: register/conf/register.json - dns:domain
- REGISTER_ADMIN_KEY: register.json - auth:authorizedKeys (the one with the role "admin")
- LICENSE_NAME: new - obtain your code from your Pryv tech contact
- TEMPLATE_VERSION: new - do not edit
- EVENT_TYPES_URL: core.json - eventTypes:sourceURL
- TRUSTED_APPS: core.json - auth:trustedApps
- TRUSTED_AUTH_URLS: register.json - http:trustedAuthUrls
- PLATFORM_NAME: regsiter.json - service:name
- SUPPORT_URL: register.json - service:support
- TERMS_OF_USE_URL: register.json - service:terms
- SERVICE_INFO_ASSETS: new - edit if you use our open source apps & libs (https://github.com/pryv/assets-pryv.me)
- DNS_CUSTOM_ENTRIES: register.json - dns:staticDataInDomain, values outside of sw, mfa, reg, mail, co1/2/3/..., local, service, access, dns1/2
- DNS_ROOT_DOMAIN_A_RECORD: register.json - dns:domain_A
- EMAIL_ACTIVATION: core.json - service:email:enabled
- EMAIL_SENDER: mail.json - email:message:from
- EMAIL_TEMPLATES_DEFAULT_LANG: mail.json - templates:defaultLang
- EMAIL_SMTP_SETTINGS: mail.json - smtp
- EMAIL_SENDMAIL_SETTINGS: mail.json - sendmail (don't report sendmail:path)
- MFA_SESSIONS_TTL_SECONDS: service-mfa.json - sessions:ttlSeconds
- MFA_SMS_API_SETTINGS: service-mfa.json - sms
- SESSION_MAX_AGE: core.json - auth:sessionMaxAge
- PASSWORD_RESET_MAX_AGE: core.json - auth:passwordResetRequestMaxAge
- UPDATES_IGNORE_PROTECTED_FIELDS: core.json - updates:ignoreProtectedFields
- WEBHOOKS_SETTINGS: core.json - webhooks
- VERSIONING_SETTINGS: core.json - audit
- SSL_CAA_ISSUER: register.json - dns:certificateAuthorityAuthorization:issuer
- INVITATION_TOKENS: register.json - invitationTokens

### Single-node specific

- SINGLE_MACHINE_IP_ADDRESS: register.json - dns:staticDataInDomain:local:ip

### Cluster specific

- STATIC_WEB_IP_ADDRESS: register.json - dns:staticDataInDomain:sw:ip
- REG_MASTER_IP_ADDRESS: register.json - dns:staticDataInDomain:reg:ip
- REG_MASTER_VPN_IP_ADDRESS: reg-master.yml - services:redis:ports (value in front of ":6379:6379")
- REG_SLAVE_IP_ADDRESS: register.json - dns:staticDataInDomain:dns2:ip

#### Hostings

##### HOSTINGS_AND_CORES

The keys such as "hosting1" & "hosting2" should be replaced with the values at: register.json - net:aaservers  
The field property of the hosting object is similar to custom DNS entries, it should be set to match the value at: net:aaservers:HOSTING:base_url

For example:

register.json

```
  "net": {
    "aaservers": {
      "CORE_HOSTING_1": [
        {
          "base_url": "https://co1.DOMAIN/",
          "authorization": "CORE_SYSTEM_KEY"
        },
        {
          "base_url": "https://co2.DOMAIN/",
          "authorization": "CORE_SYSTEM_KEY"
        }
      ],
      
    },
  ...
  "dns": {
    "staticDataInDomain": {
      "co1": {
        "ip": HOSTING_1_CORE_1_IP
      },
      "co2": {
        "ip": HOSTING_1_CORE_2_IP
      }
    }
  }
```

Must be changed into:

platform.yml

```
  HOSTINGS_AND_CORES:
    CORE_HOSTING_1:
      co1: 
        ip: HOSTING_1_CORE_1_IP
    hosting2:
      co2:
        ip: HOSTING_1_CORE_2_IP
```

##### HOSTINGS_PROVIDERS

This part is optional, it allows to store some metadata associated with hostings, which will be displayed in https://reg.DOMAIN/hostings.  
For example: https://reg.pryv.me/hostings  
We will be dropping the `regions` and `zones` levels, leaving our customers to classify their hostings in their own fashion, but if you wish
to keep hostings metadata, you can report it as following:

register.json

```
{
  "regions": {
    REGION_1: {
      ...,
      "zones": {
        "hostings": {
          "hosting1": {
            "url": "https://www.hosting1.ch",
            "name": "Hosting 1",
            "description": "Europe - Switzerland"
          },
          "hosting2: {
            "url": "https://www.hosting2.ch",
            "name": "Hosting 2",
            "description": "Europe - France"
          }
        }
      }
    }
  }
}
```

platform.yml

```
  HOSTINGS_PROVIDERS:
    hosting1:
      url: https://www.hosting1.ch
      name: Hosting 1
      description: Europe - Switzerland
    hosting2:
      url: https://www.hosting2.ch
      name: Hosting 2
      description: Europe - France
```


## Custom files

If you have some custom settings that are out of the platform variables, you must report them on the template files located in `config-leader/data/`.  
You can get an idea of the custom settings you have stored by computing a diff between the new configuration and your backup.
