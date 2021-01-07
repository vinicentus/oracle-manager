module.exports = {
    networks: {
        development: {
            host: '127.0.0.1',
            port: 8080,
            network_id: "*", // Match any network id
            gas: 5000000,
            websockets: true
        }
    },
    compilers: {
        solc: {
            version: "0.7.0",
            settings: {
                optimizer: {
                    enabled: true, // Default: false
                    runs: 200      // Default: 200
                }
            }
        }
    },
    mocha: {
        useColors: true
    }
}