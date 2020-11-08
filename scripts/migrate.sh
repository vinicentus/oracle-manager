# REMOVE THE OLD BUILD DIR
rm -rf build/

# MIGRATE CONTRACTS TO THE BLOCKCHAIN
truffle migrate --network development

# COPY REFERENCES TO THE OTHER PROJECTS
# node ./scripts/transfer.js

# CLEAN UP GARBAGE
rm -rf build/
rm -rf bin/
rm -rf contracts/bin/