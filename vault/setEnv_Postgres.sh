#!/bin/bash

#
###  GET GLOBAL ENV VARIABLES
#
if [[ -z $VAULT_ADDR ]]; then
  export VAULT_ADDR=http://0.0.0.0:8200
fi
if [[ -z $DB_HOST ]]; then
  export DB_HOST="host.docker.internal:5432"
fi
if [ ! -z $1 ]; then
  export VAULT_TOKEN="${1}"
else
  echo "VAULT_TOKEN required to setup secrets"
  echo "Usage: ./setEnv_Postgres.sh <s.VAULT_TOKEN>"
  exit 1
fi

#
### VERIFY VAULT AVAILABILITY
#
echo -e "/n### VAULT STATUS ###/n"
vault status

if [[ $? == 0 ]]; then

#
###  CREATE SECRETS ENGINE FOR POSTGRESQL
#

    # Login
    echo -e "\n#\n### Vault Login ###\n#\n"
    vault login $VAULT_TOKEN

    # Create Database Secrets Engine
    echo -e "\n#\n### Creating Database Secrets Engine ###\n#\n"
    vault secrets enable database

    # Write Database Configuration
    echo -e "\n#\n### Writing POSTGRESQL Configuration for 'notes' DB ###\n#\n"
    vault write database/config/notes \
        plugin_name=postgresql-database-plugin \
        allowed_roles="notes-role" \
        connection_url="postgresql://{{username}}:{{password}}@${DB_HOST}/notes?sslmode=disable" \
        username="demo" \
        password="demopassword"

    # Create my-role to bind DB credentials to an action
    #creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    #    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    echo -e "\n#\n###  Creating 'notes-role' to Generate Dynamic Secrets for 'notes' DB ###\n#\n"
    vault write database/roles/notes-role \
        db_name=notes \
        creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
            GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\"; \
            GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\";" \
        default_ttl="1h" \
        max_ttl="24h"

    # Create credentials to verify things are working
    echo -e "\n#\n### Creating Dynamic Secret for 'notes' DB ###\n#\n"
    vault read database/creds/notes-role

else
    echo "Start Vault Server and set correct VAULT_ADDR and VAULT_TOKEN values"
fi
