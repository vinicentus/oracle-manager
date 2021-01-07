# NUKE OLD BUILD
rm -rf build/

# MIGRATE SMART CONTRACTS
truffle migrate --network development

# DISTRIBUTE UNIFIED ABI FILE TO OTHER REPOS
python3 scripts/migrate.py

# CLEAN UP
rm -rf build/