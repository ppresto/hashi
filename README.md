# hashi

# mkdir -p consul/data vault/data
# Start Vault

```
cd /Users/i838855/Projects/DevOps/hashi
docker-compose down                          # Make sure containers are removed
rm -rf vault/data/* consul/data/*            # Remove all data to start fresh
docker-compose up -d --build
docker-compose logs -f
```
# Open Browser Tabs
http://localhost:8500/ui

http://localhost:8200/ui

# Start Flask Notes App
# Open Tab

```
docker run -it -p3000:3000 --name=notes --rm --network=hashi_default -e VAULT_ADDR="http://vault:8200" ppresto/notes
```
# Login and look at default DB credentials being used
* http://localhost:3000/credentials
* Create “My DB Credentials” Note for Tracking
*
# Unseal Vault

```
docker exec -it hashi_vault_1 bash
vault operator init                # Copy keys and Root Token
vault operator unseal              # Unseal 3x with different keys
vault login <s.VAULT_TOKEN>        # Login to Vault
```

# Enable Auditing
vault audit enable file file_path=/vault/logs/audit.log
vault audit list   # local ./vault/logs/audit.log maps to container at /vault/logs/audit.log

#  Setup Database Secrets Engine and Populate Secrets

```
cd /Users/i838855/Projects/DevOps/hashi/vault
./setEnv_Postgres.sh <s.VAULT_TOKEN>
```

# Stop Flask App / Review run.sh / Start
```
docker kill notes
docker rm notes
```

# Review Container Start CMD[‘run.sh’]
```
docker run -it -p3000:3000 --name=notes --rm --network=hashi_default \
-e VAULT_TOKEN="s.<VAULT_TOKEN>" -e VAULT_ADDR="http://vault:8200" ppresto/notes
```

# Login to Flask App and Verify Vaults Dynamic Credentials are now being used
* http://localhost:3000/credentials
* Append “My DB Credentials” Note with latest credentials

# Restart Flask App to show they change every time
```
docker kill notes
docker rm notes
docker run -it -p3000:3000 --name=notes --rm --network=hashi_default -e VAULT_TOKEN="s.<VAULT_TOKEN>"-e VAULT_ADDR="http://vault:8200" ppresto/notes
```

* Append “My DB Credentials” Note with latest credentials
