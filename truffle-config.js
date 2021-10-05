module.exports = {
    networks: {
        development: {
            host: '192.168.13.203',
            port: 8550,
            network_id: "11865", // "*" means match any network id
            gas: 4500000,
            websockets: false,
            from: "1e0dddfa3ad438a204ea08864f85bfb7615a83a3"
        }
    },
    compilers: {
        solc: {
            // TODO: bump to 8.8
            version: "0.7.6",
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
