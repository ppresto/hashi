#!/bin/bash

# Set Env Using Vault container in Dev Mode.
# docker run --network vault-net --cap-add=IPC_LOCK -e 'VAULT_DEV_ROOT_TOKEN_ID=my_root_token_id' -p 8200:8200 vault
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
  echo "Usage: ./setEnv.sh <s.VAULT_TOKEN>"
  exit 1
fi

# Check Vault status
vault status

if [[ $? == 0 ]]; then

  # Enable AWS secrets engine
  if [[ $(curl -s --header "X-Vault-Token:${VAULT_TOKEN}" ${VAULT_ADDR}/v1/sys/mounts | jq '."aws/"' 2>/dev/null) == "null" ]]; then
    vault secrets enable -path=aws aws
  else
    echo 'AWS Secrets Engine "/aws" already set'
  fi

# Write AWS secret key for 'ppresto' user
  vault write aws/config/root \
    access_key=AKIAI4SGLQPBX6CSENIQ \
    secret_key=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 \
    region=us-east-1

# Create credentials to verify things are working

else
  echo "Start Vault Server and set correct VAULT_ADDR and VAULT_TOKEN values"
fi
